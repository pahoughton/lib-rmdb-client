//
//  SMKDBConn_postgres.m
//  SMKDB
//
//  Created by Paul Houghton on 2/5/12.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "SMKDBConn_postgres.h"
#import "SMKDBException.h"

#define SMKExcpt(...) [SMKDBException toss:__VA_ARGS__]

@implementation SMKDBConn_postgres
@synthesize conn;
@synthesize doExcpt;

-(id)init
{
    self = [super init];
    if( self ) {
        conn = NULL;
        doExcpt = TRUE;
    }
    return self;
}

- (id)initWithDoExceptions:(BOOL)throwExceptions
{
    self = [super init];
    if (self) {
        conn = NULL;
        doExcpt = throwExceptions;
    }
    return self;
}

-(BOOL)connect:(const char *)cHost 
          port:(unsigned int)port 
         cUser:(const char *)usr 
         cPass:(const char *)pass
     cDatabase:(const char *)db
      cAppName:(const char *)appName
{
    const char * connKeys[16];
    const char * connVals[16];
    char portStr[32];
    
    size_t pCnt = 0;
    if( cHost != NULL ) {
        connKeys[ pCnt ] = "host";
        connVals[ pCnt ] = cHost;
        ++ pCnt;
    }
    
    if( port != 0 ) {
        (void)snprintf(portStr, sizeof(portStr), "%u",port);
        connKeys[ pCnt ] = "port";
        connVals[ pCnt ] = portStr;
        ++ pCnt;
    }
    if( db != NULL ) {
        connKeys[ pCnt ] = "dbname";
        connVals[ pCnt ] = db;
        ++ pCnt;
    }
    if( usr != NULL ) {
        connKeys[ pCnt ] = "user";
        connVals[ pCnt ] = usr;
        ++ pCnt;
    }
    if( pass != NULL ) {
        connKeys[ pCnt ] = "password";
        connVals[ pCnt ] = pass;
        ++ pCnt;
    }
    if( appName != NULL ) {
        connKeys[ pCnt ] = "application_name";
        connVals[ pCnt ] = appName;
        ++ pCnt;
    }
    
    connKeys[ pCnt ] = 0;
    connVals[ pCnt ] = 0;
    
    conn = PQconnectdbParams(connKeys, connVals, 0 );
    if( PQstatus(conn) == CONNECTION_OK ) {
        return TRUE;
    } else {
        if( doExcpt ) {
            SMKExcpt([self errorMessage]);
            return FALSE;
        } else {
            return FALSE;
        }
    }        
}

-(BOOL)connect:(NSString *)host 
          port:(unsigned int)port 
          user:(NSString *)user 
      password:(NSString *)pass
      database:(NSString *)database
       appName:(NSString *)appName
{
    return [self connect:[host UTF8String]
                    port:port
                   cUser:[user UTF8String]
                   cPass:[pass UTF8String]
               cDatabase:[database UTF8String]
                cAppName:[appName UTF8String]];
}

-(NSString *)errorMessage
{
    return [[NSString alloc]initWithUTF8String:PQerrorMessage(conn)];
}

-(NSString *)resultsErrorMessage:(PGresult *)res
{
    return [[NSString alloc]initWithUTF8String:PQresultErrorMessage(res)];
}

-(NSString *)quote:(NSString *)strVal
{
    char * quoted = PQescapeLiteral([self conn], 
                                    [strVal UTF8String], 
                                    [strVal lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    NSString * qNs = [[NSString alloc] initWithCString:quoted encoding:NSUTF8StringEncoding];
    PQfreemem(quoted);
    return qNs;
}

-(NSString *)quoteNum:(NSNumber *)numVal
{
    return [numVal stringValue];
}

-(SMKDBResults_postgres *)query:(NSString *)sql
{
    PGresult * res;
    res = PQexec(conn, [sql UTF8String]);
    if( PQresultStatus(res) != PGRES_TUPLES_OK
       && PQresultStatus(res) != PGRES_COMMAND_OK ) {
        // yuck
        if( doExcpt ) {
            SMKExcpt(@"%@\nsql:%@",[self resultsErrorMessage:res],sql);
            return  nil;
        } else {
            return nil;
        }
    } else {
        SMKDBResults_postgres * pgRes;
        pgRes = [[SMKDBResults_postgres alloc]initWithRes:res conn:self];
        return pgRes;
    }
}
// i.e. @"select %s,%d,%@",cstr,int,obj
-(SMKDBResults_postgres *)queryFormat:(NSString *)sql
                            arguments:(va_list)args
{
    NSString * fmtSql = [[NSString alloc] initWithFormat:sql arguments:args];    
    return [self query:fmtSql];
}
-(SMKDBResults_postgres *)queryFormat:(NSString *)sql,...
{
    va_list args;
    va_start(args, sql);
    NSString * fmtSql = [[NSString alloc] initWithFormat:sql arguments:args];
    va_end(args);
    
    return [self query:fmtSql];
}

// i.e. @"select a where b = $1";
-(SMKDBResults_postgres *)queryParams:(NSString *)sql params:(NSArray *)params
{
    const char  ** pValues = malloc(([params count] + 2) * sizeof(const char *));
    int * pLengths = malloc(([params count] + 2) * sizeof(int *));
    int * pFormats = malloc(([params count] + 2) * sizeof(int*));

    // this is a little harry, but ...
    int pCnt = 0;
    for( id p in params) {
        if( [p isKindOfClass:[NSData class]] ) {
            pValues[pCnt] = (const char *)[p bytes];
            pLengths[pCnt] = (int)[p length];
            pFormats[pCnt] = 1;
        
        } else if( [p isKindOfClass:[NSNumber class]] ) {
            NSString * tmp = [p stringValue];
            pValues[pCnt] = [tmp UTF8String];
            pLengths[pCnt] = (int)[tmp lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            pFormats[pCnt] = 0;
            
        } else if( [p isKindOfClass:[NSString class]] ) {
            pValues[pCnt] = [p UTF8String];
            pLengths[pCnt] = (int)[p lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            pFormats[pCnt] = 0;
        } else { 
            SMKExcpt(@"unsupport type in queryParams %@",[p className]);
        }
    }
    PGresult * res;
    res = PQexecParams(conn, 
                       [sql UTF8String], 
                       (int)[params count], 
                       NULL, 
                       pValues, 
                       pLengths, 
                       pFormats, 
                       1);

    free(pValues);
    free(pLengths);
    free(pFormats);
    
    if( PQresultStatus(res) != PGRES_TUPLES_OK
       && PQresultStatus(res) != PGRES_COMMAND_OK ) {
        // yuck
        if( doExcpt ) {
            SMKExcpt(@"%@\nsql:%@",[self resultsErrorMessage:res],sql);
            return  nil;
        } else {
            return nil;
        }
    } else {
        SMKDBResults_postgres * pgRes;
        pgRes = [[SMKDBResults_postgres alloc]initWithRes:res conn:self];
        return pgRes;
    }
    return nil;
}

// these are for update / insert i.e. no results expected or wanted
-(BOOL)queryBool:(NSString *)sql
{
    SMKDBResults_postgres * res = [self query:sql];
    if( res != nil ) {
        return TRUE;
    }
    return FALSE;
}
// i.e. @"select %s,%d,%@",cstr,int,obj
-(BOOL)queryBoolFormat:(NSString *)sql
             arguments:(va_list)args
{
    NSString * fmtSql = [[NSString alloc] initWithFormat:sql arguments:args];    
    return [self queryBool:fmtSql];
}
-(BOOL)queryBoolFormat:(NSString *)sql,...
{
    va_list args;
    va_start(args, sql);
    NSString * fmtSql = [[NSString alloc] initWithFormat:sql arguments:args];
    va_end(args);
    
    return [self queryBool:fmtSql];
}
// i.e. @"select a where b = $1";
-(BOOL)queryBoolParams:(NSString *)sql params:(NSArray *)params
{
    SMKDBResults_postgres * res = [self queryParams:sql params:params];
    if( res != nil ) {
        return TRUE;
    }
    return FALSE;
}

-(void)beginTransaction
{
    (void)[self queryBool:@"BEGIN TRANSACTION"];
}
-(void)rollback
{
    (void)[self queryBool:@"ROLLBACK"];    
}
-(void)commit
{
    (void)[self queryBool:@"COMMIT"];        
}


-(void) dealloc
{
    if( conn != NULL ) {
        PQfinish(conn);
        conn = NULL;
    }
}
@end
