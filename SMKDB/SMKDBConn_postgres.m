/**
 File:		SMKDBConn_postgres.m
 Project:	SMKDB 
 Desc:
 
 Notes:
 
 Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
 Created:     02/05/2012 04:36
 Copyright:   Copyright (c) 2012 Secure Media Keepers
              www.SecureMediaKeepers.com
              All rights reserved.
 
 Revision History: (See ChangeLog for details)
 
   $Author$
   $Date$
   $Revision$
   $Name$
   $State$
 
 $Id$
 
**/

#import "SMKDBConn_postgres.h"
#import "SMKDBTypeConv_postgres.h"
#import "SMKDBException.h"

#undef SMKDBExcept
#define SMKDBExcept(_fmt_,...) self.doExcept    \
? [SMKDBException raise:@"SMKDB" format:_fmt_,##__VA_ARGS__] \
: SMKLogError( _fmt_,##__VA_ARGS__ )

static NSString * sqlDateFmtStr = @"''yyyy-MM-dd HH:mm:ss''";
static NSString * paramDateFmtStr = @"yyyy-MM-dd HH:mm:ss";

static NSDateFormatter * sqlDateFormater = nil;
static NSDateFormatter * paramDateFormater = nil;

static NSMutableDictionary * serverTypeOidConverters = nil;

@implementation SMKDBConn_postgres
@synthesize serverId;
@synthesize conn;
@synthesize doExcept;
@synthesize binRslts;

-(id)init
{
  self = [super init];
  if( self ) {
    conn = NULL;
    doExcept = TRUE;
    binRslts = TRUE;
    if( serverTypeOidConverters == nil ) {
      serverTypeOidConverters = 
      [[NSMutableDictionary alloc]init];
    }
    if( sqlDateFormater == nil ) {
      sqlDateFormater = [[NSDateFormatter alloc]init];
      [sqlDateFormater setDateFormat:sqlDateFmtStr];
    }
    if( paramDateFormater == nil ) {
      paramDateFormater = [[NSDateFormatter alloc]init];
      [paramDateFormater setDateFormat:paramDateFmtStr];
    }
  }
  return self;
}

- (id)initWithDoExceptions:(BOOL)throwExceptions
{
  self = [super init];
  if (self) {
    conn = NULL;
    doExcept = throwExceptions;
    binRslts = TRUE;
    if( serverTypeOidConverters == nil ) {
      serverTypeOidConverters = 
      [[NSMutableDictionary alloc]init];
    }
    if( sqlDateFormater == nil ) {
      sqlDateFormater = [[NSDateFormatter alloc]init];
      [sqlDateFormater setDateFormat:sqlDateFmtStr];
    }
    if( paramDateFormater == nil ) {
      paramDateFormater = [[NSDateFormatter alloc]init];
      [paramDateFormater setDateFormat:paramDateFmtStr];
    }
  }
  return self;
}

-(void)setBinResults:(BOOL)tf
{
  binRslts = tf;
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
  /*
   for( int i  = 0; connKeys[ i ] != 0; ++ i ) {
   SMKLogDebug(@"PG Conn: %s %s",connKeys[i], connVals[i]);
   }
   */
  conn = PQconnectdbParams(connKeys, connVals, 0 );
  if( PQstatus(conn) == CONNECTION_OK ) {
    serverId = [NSString stringWithFormat:@"%s:%d",cHost,port];
    return TRUE;
  } else {
    if( doExcept ) {
      SMKDBExcept([self errorMessage]);
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
  const char * errMsg = PQerrorMessage(conn);
  SMKLogError(@"pg error %s", errMsg);
  return [[NSString alloc]initWithUTF8String:errMsg];
}

-(NSString *)resultsErrorMessage:(PGresult *)res
{
  return [[NSString alloc]initWithUTF8String:PQresultErrorMessage(res)];
}

-(NSString *)q:(id) val
{
  NSString * strVal;
  if( val == nil ) {
    return @"NULL";
    
  } else if( val == [NSNull null] ) {
    return @"NULL";
    
  } else if( [val isKindOfClass:[NSNumber class]] ) {
    NSNumber * numVal = (NSNumber *)val;
    return [numVal stringValue];
    
  } else if( [val isKindOfClass:[NSDate class]] ) {
    NSDate * dateVal = (NSDate *)val;
    return [sqlDateFormater stringFromDate:dateVal];
    
  } else if( [val isKindOfClass:[NSData class]] ) {
    NSData * dataVal = (NSData *)val;
    size_t conv_len = 0;
    unsigned char * escData 
    = PQescapeByteaConn([self conn],
                        [dataVal bytes], 
                        [dataVal length],
                        &conv_len);
    NSMutableString *  escStr = [[NSMutableString alloc] 
                                 initWithCapacity:conv_len + 16];
    [escStr appendFormat:@"E'%s'",escData];
    
    PQfreemem(escData);
    return escStr;
  
  } else if( [val isKindOfClass:[SMKDBInterval class]] ) {
    SMKDBInterval * v = val;
    strVal = [v stringValue];
  
  } else if( [val isKindOfClass:[NSString class]] ) {
    strVal = (NSString *)val;
  
  } else {
    strVal = [val description];
  }
  char * quoted = PQescapeLiteral([self conn], 
                                  [strVal UTF8String], 
                                  [strVal lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
  NSString * qNs = [[NSString alloc] initWithCString:quoted 
                                            encoding:NSUTF8StringEncoding];
  PQfreemem(quoted);
  return qNs;
}
-(NSString *)quote:(NSObject  *)val
{
  return [self q:val];
}

-(void)setServerOidConv
{
  if( [serverTypeOidConverters objectForKey:serverId] == nil ) {
    NSMutableDictionary * typInfoTable = [[NSMutableDictionary alloc]init];
    
    PGresult * tRslts = 
    PQexec(conn, "select oid, typname, typsend, typoutput from pg_type");
    int numRows = PQntuples(tRslts);
    for( int r = 0; r < numRows; ++ r ) {
      Oid typeOid;
      NSString * tmp = [NSString stringWithUTF8String:PQgetvalue(tRslts, r, 0)];
      typeOid = (Oid)[tmp integerValue];
      
      NSString * tName = [NSString stringWithUTF8String:PQgetvalue(tRslts, r, 1)];
      NSString * tSend = [NSString stringWithUTF8String:PQgetvalue(tRslts, r, 2)];
      NSString * tOut = [NSString stringWithUTF8String:PQgetvalue(tRslts, r, 3)];
      SMKDBTypeConv_postgres * tConv;
      tConv = [SMKDBTypeConv_postgres alloc];
      tConv = [tConv initTypeConv:tName 
                            tSend:tSend 
                             tOut:tOut];
      
      [typInfoTable setObject:tConv forKey:[NSNumber numberWithUnsignedInt:typeOid]];
    }
    [serverTypeOidConverters setObject:typInfoTable forKey:serverId];
  }
}
-(SMKDBResults_postgres *)query:(NSString *)sql
{
  // grab the output format values
  if( [serverTypeOidConverters objectForKey:serverId] == nil ) {
    [self setServerOidConv];
  }
  
  if( binRslts ) {
    return [self queryParams:sql params:nil];
  } else {
    PGresult * res;
    res = PQexec(conn, [sql UTF8String]);
    ExecStatusType resStatus = PQresultStatus(res); 
    if( resStatus != PGRES_TUPLES_OK
       && resStatus != PGRES_COMMAND_OK ) {
      // yuck
      if( doExcept ) {
        SMKDBExcept(@"%@\nsql:%@",[self resultsErrorMessage:res],sql);
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
  if( [serverTypeOidConverters objectForKey:serverId] == nil ) {
    [self setServerOidConv];
  }
  
  const char ** pValues = NULL;
  int * pLengths = NULL;
  int * pFormats = NULL;
  int pCnt = 0;
  
  if( params != nil ) {
    pValues = malloc(([params count] + 2) * sizeof(const char *));
    pLengths = malloc(([params count] + 2) * sizeof(int *));
    pFormats = malloc(([params count] + 2) * sizeof(int*));
    
    // this is a little harry, but ...
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
        
      } else if( [p isKindOfClass:[NSDate class]] ) {
        NSDate * dateVal = (NSDate *)p;
        NSString * tmp = [paramDateFormater stringFromDate:dateVal];
        pValues[pCnt] = [tmp UTF8String];
        pLengths[pCnt] = (int)[tmp lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        pFormats[pCnt] = 0;
        
      } else if( [p isKindOfClass:[NSString class]] ) {
        pValues[pCnt] = [p UTF8String];
        pLengths[pCnt] = (int)[p lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        pFormats[pCnt] = 0;
      } else { 
        SMKDBExcept(@"unsupport type in queryParams %@",[p className]);
      }
      ++ pCnt;
    }
  }
  PGresult * res;
  res = PQexecParams(conn, 
                     [sql UTF8String], 
                     pCnt, 
                     NULL, 
                     pValues, 
                     pLengths, 
                     pFormats, 
                     binRslts ? 1 : 0);
  
  if( pValues )
    free(pValues);
  if( pLengths )
    free(pLengths);
  if( pFormats )
    free(pFormats);
  
  ExecStatusType resStatus = PQresultStatus(res); 
  if( resStatus != PGRES_TUPLES_OK
     && resStatus != PGRES_COMMAND_OK ) {
    // yuck
    if( doExcept ) {
      SMKDBExcept(@"%@\nsql:%@",[self resultsErrorMessage:res],sql);
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
  return  FALSE;
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

-(SMKDBTypeConv_postgres *)typeConvForOid:(Oid)oid
{
  NSDictionary * svrConvTbl = 
  [serverTypeOidConverters objectForKey:serverId];
  return [svrConvTbl objectForKey:
          [NSNumber numberWithUnsignedInt:oid]];
}

-(void) dealloc
{
  if( conn != NULL ) {
    PQfinish(conn);
    conn = NULL;
  }
}
@end
