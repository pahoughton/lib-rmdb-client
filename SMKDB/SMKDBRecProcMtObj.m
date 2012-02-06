/**
    SMKDBRecProcMtObj.m
    SMKDB
  
    Created by Paul Houghton on 2/5/12.
    Copyright (c) 2012 Secure Media Keepers. All rights reserved.
  
**/

#import "SMKDBRecProcMtObj.h"

@implementation SMKDBRecProcDictMtObj
@synthesize myProc;
-(id)initWithRecProc:(id<SMKDBRecProcDict>)proc
{
    self = [super init];
    if( self ) {
        myProc = proc;
    }
    return self;
}

-(void)dbRecProc:(NSDictionary *)rec
{
    [myProc dbRecProc:rec];    
}
@end

@implementation SMKDBRecProcArrayMtObj
@synthesize myProc;
-(id)initWithRecProc:(id<SMKDBRecProcArray>)proc
{
    self = [super init];
    if( self ) {
        myProc = proc;
    }
    return self;
}

-(void)dbRecProc:(NSArray *)rec
{
    [myProc dbRecProc:rec];    
}
@end

