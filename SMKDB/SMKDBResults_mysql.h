//
//  SMKDBResults_mysql.h
//  SMKDB
//
//  Created by Paul Houghton on 2/5/12.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

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

-(void)fetchAllRowsDictMtRecProc:(id <SMKDBRecProcDict>)proc;
-(void)fetchAllRowsArrayMtRecProc:(id <SMKDBRecProcArray>)proc;

-(void)fetchAllRowsDictRecProc:(id <SMKDBRecProcDict>)proc;
-(void)fetchAllRowsArrayRecProc:(id <SMKDBRecProcArray>)proc;

-(void)fetchAllRowsDictMtObj:(id)obj proc:(SEL)sel;
-(void)fetchAllRowsArrayMtObj:(id)obj proc:(SEL)sel;


@end
