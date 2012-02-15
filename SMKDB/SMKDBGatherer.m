/**
  File:		SMKDBGatherer.m
  Project:	SMKDB
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/8/12  3:56 AM
  Copyright:    Copyright (c) 2012 Secure Media Keepers.
                All rights reserved.

  Revision History: (See ChangeLog for details)
  
    $Author$
    $Date$
    $Revision$
    $Name$
    $State$

  $Id$

**/
#import "SMKDBGatherer.h"

@implementation SMKDBGatherCollector : NSObject
@synthesize recProcObj;
@synthesize recProcSel;
@synthesize db;
@synthesize sql;

-(id)initWithConn:(id<SMKDBConn>)conn 
              sql:(NSString *)querySql 
          procObj:(NSObject *)obj 
          procSel:(SEL)objSel
{
    self = [super init];
    if( self ) {
        recProcObj = obj;
        recProcSel = objSel;
        db = conn;
        sql = querySql;
    }
    return self;    
}

-(void)procQuery
{
    [SMKDBException raise:@"SMKDB" format:@"%@ procQuery should not be used",[self className]];
}
@end

@implementation SMKDBGathCollDict
-(void)procQuery
{
    id <SMKDBResults> results = [self.db query:self.sql];
    NSMutableDictionary * rec;
    while( (rec = [results fetchRowDict]) ) {
        [self.recProcObj performSelector:self.recProcSel withObject:rec];
    }
    [self.recProcObj performSelector:self.recProcSel withObject:nil];
    [self setDb:nil];
    [self setSql:nil];
    [self setRecProcObj:nil];
}
@end

@implementation SMKDBGathCollArray
-(void)procQuery
{
    id <SMKDBResults> results = [self.db query:self.sql];
    NSMutableArray * rec;
    while( (rec = [results fetchRowArray]) ) {
        [self.recProcObj performSelector:self.recProcSel withObject:rec];
    }
    [self.recProcObj performSelector:self.recProcSel withObject:nil];
    [self setDb:nil];
    [self setSql:nil];
    [self setRecProcObj:nil];
}
@end

@implementation SMKDBGathCollMtDict
-(void)procQuery
{
    id <SMKDBResults> results = [self.db query:self.sql];
    NSMutableDictionary * rec;
    while( (rec = [results fetchRowDict]) ) {
        [self.recProcObj performSelectorOnMainThread:self.recProcSel 
                                          withObject:rec 
                                       waitUntilDone:FALSE];
    }
    [self.recProcObj performSelectorOnMainThread:self.recProcSel withObject:nil waitUntilDone:FALSE];
    [self setDb:nil];
    [self setSql:nil];
    [self setRecProcObj:nil];
}
@end

@implementation SMKDBGathCollMtArray
-(void)procQuery
{
    id <SMKDBResults> results = [self.db query:self.sql];
    NSMutableArray * rec;
    while( (rec = [results fetchRowArray]) ) {
        [self.recProcObj performSelectorOnMainThread:self.recProcSel 
                                          withObject:rec 
                                       waitUntilDone:FALSE];
    }
    [self.recProcObj performSelectorOnMainThread:self.recProcSel withObject:nil waitUntilDone:FALSE];
    [self setDb:nil];
    [self setSql:nil];
    [self setRecProcObj:nil];
}
@end

@implementation SMKDBGatherer
@synthesize coll;

-(id)initWithConn:(id<SMKDBConn>)conn 
              sql:(NSString *)querySql 
          recType:(enum SMKDBResultsType)type 
   procMainThread:(BOOL)onMt 
          procObj:(NSObject *)obj 
          procSel:(SEL)objSel
{
    self = [super init];
    if( self ) {
        if( onMt ) {
            if( type == SMKDB_REC_DICT ) {
                coll = [SMKDBGathCollMtDict alloc];
            } else {
                coll = [SMKDBGathCollMtArray alloc];
            }
        } else {
            if( type == SMKDB_REC_DICT ) {
                coll = [SMKDBGathCollDict alloc];
            } else {
                coll = [SMKDBGathCollArray alloc];
            }        
        }
        coll = [coll initWithConn:conn sql:querySql procObj:obj procSel:objSel];
    }
    return self;
}


-(void)main
{
    if( coll == nil ) {
        return;
    } else {
        [coll procQuery];
    }
    coll = nil;
}

@end
