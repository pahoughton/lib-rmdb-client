/**
 File:		SMKDBResults_postgres.h
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
#import <Foundation/Foundation.h>
#import "SMKDB.h"
#import <libpq-fe.h>

@class SMKDBConn_postgres;


@interface SMKDBResults_postgres : NSObject <SMKDBResults>
@property (assign) PGresult * myRes;
@property (assign) SMKDBConn_postgres * pgConn;
@property (retain) NSMutableArray * resFieldInfo;
@property (retain) NSMutableArray * resFieldNames;
@property (retain) NSMutableArray * resFieldClasses;
@property (assign) int numberOfFields;
@property (assign) int numberOfRows;
@property (assign) int fetchRowNum;

-(id)initWithRes:(PGresult *)res conn:(SMKDBConn_postgres *) conn;

-(SMKDBConn_postgres *)conn;

-(NSUInteger)numFields;
-(NSArray *)fieldNames;
-(NSArray *)fieldTypes;
/*
 Each objectis a NSDictionary with the following keys:
 @"name"
 @"class"
 @"length"
 
 -(NSArray *)fieldInfo;
 */

-(NSMutableDictionary *)fetchRowDict;
-(NSMutableArray *)fetchRowArray;

@end
