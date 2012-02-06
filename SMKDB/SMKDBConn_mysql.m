//
//  SMKDBConn_mysql.m
//  SMKDB
//
//  Created by Paul Houghton on 2/5/12.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "SMKDBConn_mysql.h"
#import <mysql.h>
#import "SMKDBException.h"
#import "SMKDBResults_mysql_stmt.h"

#define SMKExcpt(...) [SMKDBException toss:__VA_ARGS__]


@implementation SMKDBConn_mysql
@synthesize my;
@synthesize doExcept;
@synthesize lastErrorId;

-(id)internalInit:(BOOL)throwExcept
{
    self.doExcept = throwExcept;
    self.my = mysql_init(NULL);
    if( self.my ) {
        SMKExcpt(@"mysql_init failed");
    }
    return self;
}
-(id)initWithDoExceptions:(BOOL)throwExceptions
{
    self = [super init];
    return( self ? [self internalInit:throwExceptions] : nil );
}

-(id) init
{
    self = [super init];
    return( self ? [self internalInit:TRUE] : nil );    
}


-(void) dealloc
{
    if( self.my ) {
        mysql_close(self.my);
        self.my = nil;
    }
}

#pragma mark Connection
-(BOOL)connect:(const char *)cHost 
          port:(unsigned int)port 
         cUser:(const char *)usr 
         cPass:(const char *)pass 
     cDatabase:(const char *)db
      cAppName:(const char *)appName
{
    MYSQL * myConn = mysql_real_connect([self my], 
                                        cHost, 
                                        usr, 
                                        pass, 
                                        db, 
                                        port, 
                                        NULL, 
                                        CLIENT_REMEMBER_OPTIONS
                                        | CLIENT_MULTI_RESULTS );
    if( myConn != NULL ) {
        return TRUE;
    } else {
        self.lastErrorId = mysql_errno([self my]);
        SMKExcpt([self errorMessage]);
    }
    return FALSE;
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
#pragma mark Error
-(NSString *)errorMessage
{
    if( mysql_errno([self my]) ) {
        NSString * err;
        err = [[NSString alloc]initWithUTF8String:mysql_error([self my])];
        return err;
    } else {
        return nil;
    }
}

-(NSString *)quote:(NSString *)strVal
{
    char * strBuf = malloc(sizeof( char ) * 
                           [strVal lengthOfBytesUsingEncoding:NSUTF8StringEncoding] * 3);
    (void)mysql_real_escape_string(my, 
                                   strBuf, 
                                   [strVal UTF8String], 
                                   [strVal lengthOfBytesUsingEncoding:
                                    NSUTF8StringEncoding]);
    
    NSString * resStr = [NSString stringWithUTF8String:strBuf];
    free(strBuf);
    return resStr;
}

-(NSString *)quoteNum:(NSNumber *)numVal
{
    return [numVal stringValue];
}

#pragma mark Query
-(BOOL)queryBool:(NSString *)sql
{
    int ret = mysql_real_query([self my], 
                               [sql UTF8String], 
                               [sql lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    if( ret == 0 ) {
        return TRUE;
    } else {
        self.lastErrorId = mysql_errno([self my]);
        SMKExcpt([self errorMessage]);
    }
    return FALSE;
}

-(BOOL)queryBoolFormat:(NSString *)sql arguments:(va_list)args
{
    NSString * fmtSql = [[NSString alloc] initWithFormat:sql arguments:args];    
    return [self queryBool:fmtSql];
}

-(BOOL)queryBoolFormat:(NSString *)sql, ...
{
    va_list args;
    va_start(args, sql);
    NSString * fmtSql = [[NSString alloc] initWithFormat:sql arguments:args];
    va_end(args);
    
    return [self queryBool:fmtSql];
}

-(BOOL)queryBoolParams:(NSString *)sql params:(NSArray *)params
{
    (void)[self queryParams:sql params:params];
    return TRUE;
}

-(SMKDBResults_mysql *)query:(NSString *)sql
{
    if( [self query:sql] ) {
        SMKDBResults_mysql * res =
        [[SMKDBResults_mysql alloc] 
         initWithConn:self
         results:mysql_use_result([self my])];
        return res;
    }
    return nil;
}

-(SMKDBResults_mysql *)queryFormat:(NSString *)sql
                         arguments:(va_list)args
{
    if( [self queryBoolFormat:sql arguments:args] ) {
        SMKDBResults_mysql * res =
        [[SMKDBResults_mysql alloc] 
         initWithConn:self
         results:mysql_use_result([self my])];
        return res;
    }
    return nil;
}
-(SMKDBResults_mysql *)queryFormat:(NSString *)sql,...
{
    va_list(args);
    va_start(args, sql);
    SMKDBResults_mysql * res = [self queryFormat:sql arguments:args];
    va_end(args);
    return res;
}

-(SMKDBResults_mysql_stmt *)queryParams:(NSString *)sql 
                                 params:(NSArray *)params;
{
    SMKExcpt(@"queryParams unsupporte");
    return nil;
    /*
    // NSRegularExpressionSearch
    NSRange wholeString;
    wholeString.location = 0;
    wholeString.length = [sql length];
    
    // this should replace $1 $2 $12 with ? ? ? 
    NSString * fixSql 
    = [sql stringByReplacingOccurrencesOfString:@"\\$[0-9]+" 
                                     withString:@"?" 
                                        options:NSRegularExpressionSearch
                                          range:wholeString];
    MYSQL_STMT * stmt = mysql_stmt_init([self my]);
    
    if( stmt == NULL ) {
        SMKExcpt([self errorMessage]);
    }
    if( mysql_stmt_prepare(stmt, 
                           [fixSql UTF8String], 
                           [fixSql lengthOfBytesUsingEncoding:
                            NSUTF8StringEncoding]) ) {
                               SMKExcpt([self errorMessage]);
                           }
    MYSQL_BIND * bind = malloc([params count] * 2 * sizeof(MYSQL_BIND));
    memset(bind,0, sizeof( MYSQL_BIND) * [params count]);
    size_t pNum = 0;
    for( id p in params ) {
        if( [p isKindOfClass:[NSString class]] ) {
            NSString * pStr = p;
            bind[pNum].buffer_type = MYSQL_TYPE_STRING;
            bind[pNum].buffer = (void*)[pStr UTF8String];
            bind[pNum].buffer_length = [pStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding]; 
            
        } else if( [p isKindOfClass:[NSData class]] ) {
            NSData * pData = p;
            bind[pNum].buffer_type = MYSQL_TYPE_BLOB;
            bind[pNum].buffer = (void*)[pData bytes];
            bind[pNum].buffer_length = [pData length];
        } else {
            SMKExcpt(@"unsupported param type");
        }
        ++ pNum;
    }
    if( mysql_stmt_bind_param(stmt, bind) ) {
        SMKExcpt([self errorMessage]);
    }
    if( mysql_stmt_execute(stmt) ) {
        SMKExcpt([self errorMessage]);        
    }
    SMKDBResults_mysql_stmt * stmtRes;
    stmtRes = [[SMKDBResults_mysql_stmt alloc] initWithConn:self
                                                  statement:stmt];
    return stmtRes;
     */
}

@end
