//
//  SMKDBInterval.h
//  SMKDB
//
//  Created by Paul Houghton on 120409.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMKDBIntervalFormatter : NSFormatter
@end

@interface SMKDBInterval : NSObject <NSCopying>
@property (assign) double   seconds;
@property (assign) int32_t  days;
@property (assign) int32_t  months;
-(id)initWithMonths:(int32_t)m days:(int32_t)d secs:(double)s;

-(void)setWithString:(NSString *)str;
-(NSString *)stringValue;

@end
