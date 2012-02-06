//
//  SMKDBResults_postgres.h
//  SMKDB
//
//  Created by Paul Houghton on 2/5/12.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMKDB.h"
#import <libpq-fe.h>

@class SMKDBConn_postgres;

@interface SMKDBResults_postgres : NSObject <SMKDBResults>
@property (assign) PGresult * myRes;
@property (assign) SMKDBConn_postgres * pgConn;
@property (retain) NSArray * resFieldNames;
@property (retain) NSArray * resFieldClasses;
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

-(void)fetchAllRowsDictMtRecProc:(id <SMKDBRecProcDict>)proc;
-(void)fetchAllRowsArrayMtRecProc:(id <SMKDBRecProcArray>)proc;

-(void)fetchAllRowsDictRecProc:(id <SMKDBRecProcDict>)proc;
-(void)fetchAllRowsArrayRecProc:(id <SMKDBRecProcArray>)proc;

-(void)fetchAllRowsDictMtObj:(id)obj proc:(SEL)sel;
-(void)fetchAllRowsArrayMtObj:(id)obj proc:(SEL)sel;

@end
