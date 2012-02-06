/**
    SMKDBException.m
    SMKDB
  
    Created by Paul Houghton on 2/5/12.
    Copyright (c) 2012 Secure Media Keepers. All rights reserved.
  
**/

#import "SMKDBException.h"

@implementation SMKDBException

+(void) toss:(NSString *)msgFormat,...
{
    va_list(args);
    va_start(args, msgFormat);
    NSString * msg = [[NSString alloc] initWithFormat:msgFormat
                                            arguments:args];
    NSException * ex = [NSException alloc];
    [[ex initWithName:@"SMKDB" reason:msg userInfo:nil] raise];
}

@end
