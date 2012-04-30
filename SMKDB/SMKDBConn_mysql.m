/**
 File:		SMKDBConn_mysql.m
 Project:	SMKDB 
 Desc:
 
 
 Notes:
 
 Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
 Created:     02/02/2012 04:36
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

#import "SMKDBConn_mysql.h"
#import <mysql.h>
#import <SMKCommon.h>
#import "SMKDBResults_mysql_stmt.h"

static NSString * sqlDateFmtStr = @"''yyyy-MM-dd HH:mm:ss''";
static NSDateFormatter * sqlDateFormater = nil;

@implementation SMKDBConn_mysql
@synthesize my;
@synthesize doExcept;
@synthesize lastErrorId;
@synthesize binRslt;

-(id)internalInit:(BOOL)throwExcept
{
    self.doExcept = throwExcept;
    lastErrorId = 0;
    if( sqlDateFormater == nil ) {
        sqlDateFormater = [[NSDateFormatter alloc]init];
        [sqlDateFormater setDateFormat:sqlDateFmtStr];
    }
    self.my = mysql_init(NULL);
    if( ! self.my ) {
        SMKThrow(@"mysql_init failed");
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

-(void)setBinResults:(BOOL)tf
{
    binRslt = tf;
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
        SMKThrow([self errorMessage]);
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

-(NSString *)q:(NSObject *)val
{
    NSString * strVal;
    
    if( [val isKindOfClass:[NSNumber class]] ) {
        NSNumber * numVal = (NSNumber *)val;
        return [numVal stringValue];
        
    } else if( [val isKindOfClass:[NSDate class]] ) {
        NSDate * dateVal = (NSDate *)val;
        return [sqlDateFormater stringFromDate:dateVal];
        
    } else if( [val isKindOfClass:[NSData class]] ) {
        NSData * dataVal = (NSData *)val;
        
        char * strBuf = malloc(sizeof( char ) 
                               * [dataVal length] 
                               * 3);
        unsigned long hexLen;
        hexLen = mysql_hex_string( strBuf, 
                               [dataVal bytes], 
                               [dataVal length]);
        NSMutableString * strRes = [[NSMutableString alloc] 
                                    initWithCapacity:hexLen + 8];
        [strRes appendFormat:@"X'%s'",strBuf];
        free(strBuf);
        return strRes;
    } else if( [val isKindOfClass:[NSString class]] ) {
        strVal = (NSString *)val;
    } else {
        strVal = [val description];
    }

    char * strBuf = malloc(sizeof( char ) * 
                           [strVal lengthOfBytesUsingEncoding:NSUTF8StringEncoding] * 3);
    (void)mysql_real_escape_string(my, 
                                   strBuf, 
                                   [strVal UTF8String], 
                                   [strVal lengthOfBytesUsingEncoding:
                                    NSUTF8StringEncoding]);
    
    // NSString * resStr = [NSString stringWithUTF8String:strBuf];
    NSString * resStr = [NSString stringWithFormat:@"'%s'",strBuf];
    free(strBuf);
    return resStr;
}

-(NSString *)quote:(NSObject *)val
{
    return [self q:val];
}

-(NSString *)quoteNum:(NSNumber *)numVal
{
    return [numVal stringValue];
}

#pragma mark Query
-(BOOL)queryBool:(NSString *)sql
{    
    SMKLogDebug(@"mysql queryBool:sql: '%@'", sql);
    int ret = mysql_real_query([self my], 
                               [sql UTF8String], 
                               [sql lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    if( ret == 0 ) {
        return TRUE;
    } else {
        self.lastErrorId = mysql_errno([self my]);
        SMKThrow([self errorMessage]);
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
    // SMKLogDebug(@"mysql queryBoolFormat:arguments sql: '%@'", sql);
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
    if( [self queryBool:sql] ) {
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
    SMKThrow(@"queryParams unsupporte");
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
        SMKThrow([self errorMessage]);
    }
    if( mysql_stmt_prepare(stmt, 
                           [fixSql UTF8String], 
                           [fixSql lengthOfBytesUsingEncoding:
                            NSUTF8StringEncoding]) ) {
                               SMKThrow([self errorMessage]);
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
            SMKThrow(@"unsupported param type");
        }
        ++ pNum;
    }
    if( mysql_stmt_bind_param(stmt, bind) ) {
        SMKThrow([self errorMessage]);
    }
    if( mysql_stmt_execute(stmt) ) {
        SMKThrow([self errorMessage]);        
    }
    SMKDBResults_mysql_stmt * stmtRes;
    stmtRes = [[SMKDBResults_mysql_stmt alloc] initWithConn:self
                                                  statement:stmt];
    return stmtRes;
     */
}

-(void)beginTransaction
{
    (void)[self queryBool:@"BEGIN TRANSACTION"]; 
}
-(void)rollback
{
    (void)mysql_rollback([self my]);
}

-(void)commit
{
    (void)mysql_commit([self my]);
}


@end
