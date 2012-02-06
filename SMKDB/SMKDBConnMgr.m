//
//  SMKDBConnMgr.m
//  SMKDB
//
//  Created by Paul Houghton on 2/5/12.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "SMKDBConnMgr.h"
#import "SMKDB_priv.h"
#import "SMKDBConn_postgres.h"
#import "SMKDBResults_postgres.h"
#import "SMKDBConn_mysql.h"
#import "SMKDBResults_mysql.h"
#import "SMKDBException.h"

#define SMKExcpt(...) [SMKDBException toss:__VA_ARGS__]


static id <SMKDBConnInfo> smkConnInfo;

@implementation SMKDBConnMgr
@synthesize info;

+(void) setInfoProvider:(id <SMKDBConnInfo>)info
{
    smkConnInfo = info;
}

+(id <SMKDBConn>)conn
{
    id <SMKDBConn> dbConn;
    
    switch ([smkConnInfo dbType]) {
        case DB_Postgess:
            dbConn = [[SMKDBConn_postgres alloc] initWithDoExceptions:TRUE];
            break;
            
        case DB_MySql:
            dbConn = [[SMKDBConn_mysql alloc] initWithDoExceptions:TRUE];
            break;
            
        default:
            SMKExcpt(@"Invalid db type %d",[smkConnInfo dbType]);
            return nil;
            break;
    }
    [dbConn connect:[smkConnInfo dbHost]
               port:[smkConnInfo dbPort] 
               user:[smkConnInfo dbUser]
           password:[smkConnInfo dbPass]
           database:[smkConnInfo dbDatabase]
            appName:[smkConnInfo dbApp]];
    
    return dbConn;
}

+(void)fetchAllRowsDictMtObj:(id)obj proc:(SEL)sel sql:(NSString *)sql, ...
{
    va_list(args);
    va_start(args, sql);
    id <SMKDBConn> dbConn = [SMKDBConnMgr conn];
    id <SMKDBResults> res = [dbConn queryFormat:sql arguments:args]
    va_end(args);
    
    [res fetchAllRowsDictMtObj:obj proc:sel];
}

+(void)fetchAllRowsArrayMtObj:(id)obj proc:(SEL)sel sql:(NSString *)sql, ...
{
    va_list(args);
    va_start(args, sql);
    id <SMKDBConn> dbConn = [SMKDBConnMgr conn];
    id <SMKDBResults> res = [dbConn queryFormat:sql arguments:args]
    va_end(args);
    
    [res fetchAllRowsArrayMtObj:obj proc:sel];
}

-(id) initWithInfo:(id<SMKDBConnInfo>)infoObj
{
    self = [super init];
    if( self ) {
        info = infoObj;
    }
    return self;
}

-(id <SMKDBConn>)conn
{
    id <SMKDBConn> dbConn;
    
    switch ([info dbType]) {
        case DB_Postgess:
            dbConn = [[SMKDBConn_postgres alloc] initWithDoExceptions:TRUE];
            break;
            
        case DB_MySql:
            dbConn = [[SMKDBConn_mysql alloc] initWithDoExceptions:TRUE];
            break;
            
        default:
            SMKExcpt(@"Invalid db type %d",[info dbType]);
            return nil;
            break;
    }
    [dbConn connect:[info dbHost]
               port:[info dbPort] 
               user:[info dbUser]
           password:[info dbPass]
           database:[info dbDatabase]
            appName:[info dbApp]];
    
    return dbConn;
}

-(void)fetchAllRowsDictMtObj:(id)obj proc:(SEL)sel sql:(NSString *)sql, ...
{
    va_list(args);
    va_start(args, sql);
    id <SMKDBConn> dbConn = [self conn];
    id <SMKDBResults> res = [dbConn queryFormat:sql arguments:args]
    va_end(args);
    
    [res fetchAllRowsDictMtObj:obj proc:sel];
}

-(void)fetchAllRowsArrayMtObj:(id)obj proc:(SEL)sel sql:(NSString *)sql, ...
{
    va_list(args);
    va_start(args, sql);
    id <SMKDBConn> dbConn = [self conn];
    id <SMKDBResults> res = [dbConn queryFormat:sql arguments:args]
    va_end(args);
    
    [res fetchAllRowsArrayMtObj:obj proc:sel];
}


@end
