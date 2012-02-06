/**
    SMKDBException.h
    SMKDB
  
    Created by Paul Houghton on 2/5/12.
    Copyright (c) 2012 Secure Media Keepers. All rights reserved.
  
**/

#import <Foundation/Foundation.h>

@interface SMKDBException : NSObject

+(void) toss:(NSString *)msgFormat,...;

@end
