/**
 File:		SMKDBResults_mysql.h
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
#import <Foundation/Foundation.h>
#import "SMKDB.h"
#import <mysql.h>

@class SMKDBConn_mysql;

@interface SMKDBResults_mysql : NSObject <SMKDBResults>
@property (retain) SMKDBConn_mysql * myconn;
@property (assign) MYSQL_RES * myRes;
@property (retain) NSArray * resFieldNames;
@property (retain) NSArray * resFieldTypes;


-(id)initWithConn:(SMKDBConn_mysql *)conn results:(MYSQL_RES *)res;

-(SMKDBConn_mysql *)conn;

-(NSUInteger)numFields;
-(NSArray *)fieldNames;
-(NSArray *)fieldTypes;

-(NSMutableDictionary *)fetchRowDict;
-(NSMutableArray *)fetchRowArray;

-(NSString *)description;

@end
