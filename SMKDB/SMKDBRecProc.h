/**
    SMKDBRecProc.h
    SMKDB
  
    Created by Paul Houghton on 2/5/12.
    Copyright (c) 2012 Secure Media Keepers. All rights reserved.

**/

#import <Foundation/Foundation.h>

@protocol SMKDBRecProcArray <NSObject>

-(void)dbRecProc:(NSArray *)rec;

@end

@protocol SMKDBRecProcDict <NSObject>

-(void) dbRecProc:(NSDictionary *)rec;

@end
