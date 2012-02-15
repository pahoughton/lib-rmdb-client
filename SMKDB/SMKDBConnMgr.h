/**
 File:		SMKDBConnMgr.h
 Project:	SMKDB 
 Desc:
 
   Provides Connections and helper interface to a sql database. 
   A SMKDBConnInfo object is required to provide connection details
   such as host, user, password ...
 
 Usage Example:
    [SMKDBConnMgr setInfoProvider:YourConnInfoObject];
    SMKDBConn * db = [SMKDBConnMgr conn];
    [db query:@"insert into test (name) values ( %@ )",[db q:@"Paul"]];
 
    @interface MyObj : NSObject <SMKDBRecProc>
    @property (retain) NSMutableArray * recSafe;
    @end 
 
    // this calls your object's method for each record and one last time with a nil
    [SMKDBConnMgr fetchAllRowsDictMtObj:yourUiObj 
                                   proc:yourUiRecProcMethodSelector
                                recSafe:&recSafe
                                    sql:@"select * from test where name = %@",[db q:@"paul"]];
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
#import <Foundation/Foundation.h>
#import "SMKDB.h"

@protocol SMKDBRecProc <NSObject>

@end

@interface SMKDBConnMgr : NSObject
@property (retain) id <SMKDBConnInfo> connInfo;
@property (retain) id <SMKDBConn> conn;
@property (retain) NSOperationQueue * opQueue;

+(void) setDefaultInfoProvider:(id <SMKDBConnInfo>)infoObj;
+(id <SMKDBConn>)getNewDbConn;


-(id) init;
-(id) initWithInfo:(id <SMKDBConnInfo>)info;
-(id <SMKDBConn>)getNewDbConn;
-(id <SMKDBConn>)connect;

/**
 quote object to be used in a sql string 
 stirngs are returned with surrounding quotes (')
 NSDates are formated for the database.
 Binary data is converted as needed.
 [ ... @".... values ( %@, %@, %@, %@ )",[db q:aString], 
                                         [db q:aDate], 
                                         [db q:aData], 
                                         [db q:aNumber]];
 */
-(NSString *)q:(NSObject *)val;

// runs selectors on Main Thread
-(void)fetchAllRowsDictMtObj:(id <SMKDBRecProc>)obj 
                        proc:(SEL)sel
                         sql:(NSString *)sql
                   arguments:(va_list)vargs NS_FORMAT_FUNCTION(3,0);

-(void)fetchAllRowsArrayMtObj:(id <SMKDBRecProc>)obj 
                         proc:(SEL)sel
                          sql:(NSString *)sql
                    arguments:(va_list)vargs NS_FORMAT_FUNCTION(3,0);

-(void)fetchAllRowsDictMtObj:(id <SMKDBRecProc>)obj 
                        proc:(SEL)sel
                         sql:(NSString *)sql,... NS_FORMAT_FUNCTION(3,4);

-(void)fetchAllRowsArrayMtObj:(id <SMKDBRecProc>)obj 
                         proc:(SEL)sel
                          sql:(NSString *)sql,... NS_FORMAT_FUNCTION(3,4);


// runs selectors on ANY Thread
-(void)fetchAllRowsDictObj:(id <SMKDBRecProc>)obj 
                      proc:(SEL)sel
                       sql:(NSString *)sql
                 arguments:(va_list)vargs NS_FORMAT_FUNCTION(3,0);

-(void)fetchAllRowsArrayObj:(id <SMKDBRecProc>)obj 
                       proc:(SEL)sel
                        sql:(NSString *)sql
                  arguments:(va_list)vargs NS_FORMAT_FUNCTION(3,0);

-(void)fetchAllRowsDictObj:(id <SMKDBRecProc>)obj 
                      proc:(SEL)sel
                       sql:(NSString *)sql,... NS_FORMAT_FUNCTION(3,4);

-(void)fetchAllRowsArrayObj:(id <SMKDBRecProc>)obj 
                       proc:(SEL)sel
                        sql:(NSString *)sql,... NS_FORMAT_FUNCTION(3,4);
@end
