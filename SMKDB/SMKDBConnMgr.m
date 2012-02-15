/**
 File:		SMKDBConnMgr.m
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
#import "SMKDBConnMgr.h"
#import "SMKDB_priv.h"
#import "SMKDBConn_postgres.h"
#import "SMKDBResults_postgres.h"
#import "SMKDBConn_mysql.h"
#import "SMKDBResults_mysql.h"
#import "SMKDBException.h"



static id <SMKDBConnInfo> smkConnInfo;

@implementation SMKDBConnMgr
@synthesize connInfo;
@synthesize conn;
@synthesize opQueue;

#pragma mark Class Methods
+(void) setDefaultInfoProvider:(id <SMKDBConnInfo>)info
{
    static NSString * lkName = @"smkConnInfoLock";
    
    NSLock * dfltConnInfoLock = [[NSLock alloc] init];
    [dfltConnInfoLock setName:lkName];
    [dfltConnInfoLock lock];
    smkConnInfo = info;
    [dfltConnInfoLock unlock];
}

+(id <SMKDBConn>)getNewDbConn
{
    id <SMKDBConn> dbConn = nil;
    
    switch ([smkConnInfo dbType]) {
        case DB_Postgess:
            dbConn = [[SMKDBConn_postgres alloc] initWithDoExceptions:TRUE];
            break;
            
        case DB_MySql:
            dbConn = [[SMKDBConn_mysql alloc] initWithDoExceptions:TRUE];
            break;
            
        default:
            SMKDBExcept(@"Invalid db type %d",[smkConnInfo dbType]);
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



-(id) init
{
    self = [super init];
    if( self ) {
        connInfo = smkConnInfo;
        conn = nil;
        opQueue = [[NSOperationQueue alloc]init];
    }
    return self;
}

-(id) initWithInfo:(id<SMKDBConnInfo>)infoObj
{
    self = [super init];
    if( self ) {
        connInfo = infoObj;
        conn = nil;
        opQueue = [[NSOperationQueue alloc]init];
    }
    return self;
}


-(id <SMKDBConn>)getNewDbConn
{
    id <SMKDBConn> dbConn = nil;
    
    switch ([connInfo dbType]) {
        case DB_Postgess:
            dbConn = [[SMKDBConn_postgres alloc] initWithDoExceptions:TRUE];
            break;
            
        case DB_MySql:
            dbConn = [[SMKDBConn_mysql alloc] initWithDoExceptions:TRUE];
            break;
            
        default:
            SMKDBExcept(@"Invalid db type %d",[connInfo dbType]);
            return nil;
            break;
    }
    [dbConn connect:[connInfo dbHost]
               port:[connInfo dbPort] 
               user:[connInfo dbUser]
           password:[connInfo dbPass]
           database:[connInfo dbDatabase]
            appName:[connInfo dbApp]];
    
    return dbConn;
}

-(id <SMKDBConn>)connect
{
    if( conn == nil ) {
        [self setConn:[self getNewDbConn]];
    }
    return conn;
}

-(NSString *)q:(NSObject *)val
{
    if( conn == nil ) {
        [self connect];
    }
    
    return [conn q:val];
}

-(void)queueGatherer:(SMKDBGatherer *)gath
{
    [opQueue addOperation:gath];
}

// runs selectors on Main Thread
-(void)fetchAllRowsDictMtObj:(id <SMKDBRecProc>)obj
                        proc:(SEL)sel
                         sql:(NSString *)sql
                   arguments:(va_list)vargs
{
    NSString * query = [[NSString alloc] initWithFormat:sql arguments:vargs];
    [self queueGatherer:[[SMKDBGatherer alloc] initWithConn:[self getNewDbConn] 
                                                        sql:query
                                                    recType:SMKDB_REC_DICT 
                                             procMainThread:TRUE 
                                                    procObj:obj 
                                                    procSel:sel]];
}

-(void)fetchAllRowsArrayMtObj:(id <SMKDBRecProc>)obj 
                         proc:(SEL)sel
                          sql:(NSString *)sql
                    arguments:(va_list)vargs
{
    NSString * query = [[NSString alloc] initWithFormat:sql arguments:vargs];
    [self queueGatherer:[[SMKDBGatherer alloc] initWithConn:[self getNewDbConn] 
                                                        sql:query 
                                                    recType:SMKDB_REC_ARRAY
                                             procMainThread:TRUE 
                                                    procObj:obj 
                                                    procSel:sel]];
}

-(void)fetchAllRowsDictMtObj:(id <SMKDBRecProc>)obj 
                        proc:(SEL)sel
                         sql:(NSString *)sql,...
{
    va_list args;
    va_start(args, sql);
    [self fetchAllRowsDictMtObj:obj proc:sel sql:sql arguments:args];
    va_end(args);
    
}

-(void)fetchAllRowsArrayMtObj:(id <SMKDBRecProc>)obj 
                         proc:(SEL)sel
                          sql:(NSString *)sql,...
{
    va_list args;
    va_start(args, sql);
    [self fetchAllRowsArrayMtObj:obj proc:sel sql:sql arguments:args];
    va_end(args);
}


// runs selectors on Any Thread
-(void)fetchAllRowsDictObj:(id <SMKDBRecProc>)obj 
                        proc:(SEL)sel
                         sql:(NSString *)sql
                   arguments:(va_list)vargs
{
    NSString * query = [[NSString alloc] initWithFormat:sql arguments:vargs];
    [self queueGatherer:[[SMKDBGatherer alloc] initWithConn:[self getNewDbConn] 
                                                        sql:query 
                                                    recType:SMKDB_REC_DICT 
                                             procMainThread:FALSE
                                                    procObj:obj 
                                                    procSel:sel]];
}

-(void)fetchAllRowsArrayObj:(id <SMKDBRecProc>)obj 
                         proc:(SEL)sel
                          sql:(NSString *)sql
                    arguments:(va_list)vargs
{
    NSString * query = [[NSString alloc] initWithFormat:sql arguments:vargs];
    [self queueGatherer:[[SMKDBGatherer alloc] initWithConn:[self getNewDbConn] 
                                                        sql:query 
                                                    recType:SMKDB_REC_ARRAY
                                             procMainThread:FALSE
                                                    procObj:obj 
                                                    procSel:sel]];
}

-(void)fetchAllRowsDictObj:(id <SMKDBRecProc>)obj 
                        proc:(SEL)sel
                         sql:(NSString *)sql,...
{
    va_list args;
    va_start(args, sql);
    [self fetchAllRowsDictObj:obj proc:sel sql:sql arguments:args];
    va_end(args);
    
}

-(void)fetchAllRowsArrayObj:(id <SMKDBRecProc>)obj 
                         proc:(SEL)sel
                          sql:(NSString *)sql,...
{
    va_list args;
    va_start(args, sql);
    [self fetchAllRowsArrayObj:obj proc:sel sql:sql arguments:args];
    va_end(args);
}

@end
