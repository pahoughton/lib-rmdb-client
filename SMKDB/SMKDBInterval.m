//
//  SMKDBInterval.m
//  SMKDB
//
//  Created by Paul Houghton on 120409.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "SMKDBInterval.h"
#import "SMKCommon.h"

@implementation SMKDBIntervalFormatter
-(NSString *)stringForObjectValue:(id)anObject
{
  NSString * str = nil;
  if( [anObject isKindOfClass:[SMKDBInterval class]] ) {
    SMKDBInterval * it = anObject;
    str = it.stringValue;
  }
  return str;
}
- (BOOL)getObjectValue:(id *)anObject 
             forString:(NSString *)string 
      errorDescription:(NSString **)error
{
  SMKDBInterval * it = [[SMKDBInterval alloc]init ];
  BOOL ret = FALSE;
  @try {
    [it setWithString: string];
    *anObject = it;
    ret = TRUE;
  }
  @catch (NSException *exception) {
    *error = [exception description];
  }
  return ret;
}




@end
@implementation SMKDBInterval
@synthesize seconds = _seconds;
@synthesize days    = _days;
@synthesize months  = _months;

-(id)initWithMonths:(int32_t)m days:(int32_t)d secs:(double)s
{
  self = [super init];
  if( self ) {
    [self setMonths:m];
    [self setDays:d];
    [self setSeconds:s];
  }
  return self;
}
-(id)copyWithZone:(NSZone *)zone
{
  SMKDBInterval * copy = [[[self class] allocWithZone:zone]init];
  [copy setSeconds:self.seconds];
  [copy setDays:self.days];
  [copy setMonths:self.months];
  return copy;
}
-(void)setWithString:(NSString *)str
{
  NSError * err;
  NSRegularExpression * regex;
  regex = [NSRegularExpression 
           regularExpressionWithPattern:
           @"( *([0-9]+) +y[a-z]*)?"
           "( *([0-9]+) +m[a-z]*)?"
           "( *([0-9]+) +d[a-z]*)?"
           "( *((-?[0-9]+):)?(-?[0-9]+):([0-9\\.]+))?" 
           options:NSRegularExpressionCaseInsensitive
           error:&err];
  NSArray * matches = [regex matchesInString:str options:0 range:(NSRange){0,[str length]}];
  NSTextCheckingResult * match = [matches objectAtIndex:0];
  if( match.numberOfRanges >= 11 ) {
    NSRange mRng;
    NSString * subStr;
    int32_t myMonths = 0;
    int32_t myDays   = 0;
    double  mySecs   = 0;
    
    mRng  = [match rangeAtIndex:2];
    if( mRng.location != NSNotFound ) {
      subStr = [str substringWithRange:mRng];
      myMonths = ([subStr intValue] * 12);
    }
    mRng = [match rangeAtIndex:4];
    if( mRng.location != NSNotFound ) {
      myMonths += [[str substringWithRange:mRng] intValue];
    }
    mRng = [match rangeAtIndex:6];
    if( mRng.location != NSNotFound ) {
      myDays = [[str substringWithRange:mRng]intValue];
    }
    mRng  = [match rangeAtIndex:8];
    if( mRng.location != NSNotFound ) {
      mySecs += ([[str substringWithRange:mRng] intValue] * 60 * 60);
    }
    mRng  = [match rangeAtIndex:10];
    if( mRng.location != NSNotFound ) {
      mySecs += ([[str substringWithRange:mRng] intValue] * 60);
    }
    mRng  = [match rangeAtIndex:11];
    if( mRng.location != NSNotFound ) {
      mySecs += [[str substringWithRange:mRng] floatValue];
    }
    [self setMonths:myMonths];
    [self setDays:myDays];
    [self setSeconds:mySecs];
  } else {
    SMKThrow( @"parse error '%@'",str );
  }
  /*
  NSLog(@"Matches: %@",matches);
  for( NSTextCheckingResult * match in matches ){
    NSLog(@"%lu %lu %lu",match.numberOfRanges, match.range.location,match.range.length);
    for( NSUInteger i = 1; i < match.numberOfRanges; ++ i ) {
      NSRange mrng = [match rangeAtIndex:i];
      NSString * sub = [str substringWithRange:mrng];
      NSLog(@"%lu %lu %lu '%@'",
            i, mrng.location, mrng.length, sub);
    }
  }
   */
}
-(NSString *)stringValue
{
  NSMutableString * str = [[NSMutableString alloc] init];
  
  int32_t yrs = 0;
  int32_t mth = self.months;
  if( mth > 12 ) {
    yrs = mth / 12;
    mth = mth % 12;
  }
  if( yrs ) {
    [str appendFormat:@"%d years ",yrs];
  }
  if( mth ) {
    [str appendFormat:@"%d months ",mth];
  }
  if( self.days ) {
    [str appendFormat:@"%d days ",self.days];
  }
  if( self.seconds ) {
    int64_t hrs = self.seconds;
    float fract = self.seconds - hrs;
    uint32_t min = (hrs % (60*60))/60;
    uint32_t sec = (hrs % 60);
    hrs = hrs / (60*60);
    
    if( hrs ) {
      [str appendFormat:@"%02lld:%02d",hrs,min];
    
    } else if( fract == 0 ) {
      [str appendFormat:@"%02d:%02d",min,sec];
    } else {
      fract += sec;
      [str appendFormat:@"%02d:%02.3f",min,fract];
    }
  } else {
    if( [str length] ) {
      [str deleteCharactersInRange:(NSRange){ [str length]-1,1 }];
    } else {
      [str appendString:@"00:00:00"];
    }
  }
  return str;
}
-(NSString *)description
{
  return [NSString stringWithFormat:
          @"%@ <%p> %d mons %d days %f secs\n  %@",
          [self className],
          self,
          self.months,
          self.days,
          self.seconds,
          [self stringValue]];
}
@end
