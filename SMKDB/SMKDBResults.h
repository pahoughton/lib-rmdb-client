/**
 SMKDBResults.h
 SMKDB
 
 Created by Paul Houghton on 2/2/12.
 Copyright (c) 2012 Secure Media Keepers. All rights reserved.
 **/ 

#import <Foundation/Foundation.h>

@protocol SMKDBConn;
@protocol SMKDBRecProcDict;
@protocol SMKDBRecProcArray;

@protocol SMKDBResults <NSObject>

-(id <SMKDBConn>)conn;

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
