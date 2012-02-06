/**
    SMKDBResults_mysql_stmt.h
    SMKDB
  
    Created by Paul Houghton on 2/5/12.
    Copyright (c) 2012 Secure Media Keepers. All rights reserved.
  
**/

#import <Foundation/Foundation.h>
#import "SMKDBResults.h"
#import <mysql.h>

@class SMKDBConn_mysql;

@interface SMKDBResults_mysql_stmt : NSObject <SMKDBResults>
@property (assign) MYSQL_STMT * stmt;
@property (retain) SMKDBConn_mysql * myconn;
@property (retain) NSArray * resFieldNames;
@property (retain) NSArray * resFieldTypes;

-(id)initWithConn:(SMKDBConn_mysql *)conn statement:(MYSQL_STMT *)inStmt;


-(SMKDBConn_mysql *)conn;

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

-(void)fetchAllRowsDictMtRecProc:(id <SMKDBRecProcDict>)proc;
-(void)fetchAllRowsArrayMtRecProc:(id <SMKDBRecProcArray>)proc;

-(void)fetchAllRowsDictRecProc:(id <SMKDBRecProcDict>)proc;
-(void)fetchAllRowsArrayRecProc:(id <SMKDBRecProcArray>)proc;

-(void)fetchAllRowsDictMtObj:(id)obj proc:(SEL)sel;
-(void)fetchAllRowsArrayMtObj:(id)obj proc:(SEL)sel;

@end
