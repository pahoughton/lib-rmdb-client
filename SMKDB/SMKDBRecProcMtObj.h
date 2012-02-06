/**
    SMKDBRecProcMtObj.h
    SMKDB
  
    Created by Paul Houghton on 2/5/12.
    Copyright (c) 2012 Secure Media Keepers. All rights reserved.
  
**/

#import <Foundation/Foundation.h>

#import "SMKDBRecProc.h"

@interface SMKDBRecProcDictMtObj : NSObject <SMKDBRecProcDict>
@property (assign) id <SMKDBRecProcDict> myProc;

-(id) initWithRecProc:(id <SMKDBRecProcDict>)proc;

-(void) dbRecProc:(NSDictionary *)rec;

@end

@interface SMKDBRecProcArrayMtObj : NSObject <SMKDBRecProcArray>
@property (assign) id <SMKDBRecProcArray> myProc;

-(id) initWithRecProc:(id <SMKDBRecProcArray>)proc;

-(void) dbRecProc:(NSArray *)rec;

@end

