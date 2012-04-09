/**
  File:		SMKDBTypeConv_postgres.m
  Project:	SMKDB
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/11/12  3:41 AM
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
#import "SMKDBTypeConv_postgres.h"
#import <SMKLogger.h>
#import "SMKDBInterval.h"
#import <libpq-fe.h>


#pragma mark Converters

@interface PgConv_abstimesend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_abstimesend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
    return [[NSData alloc] initWithBytes:[convArgs data]
                                  length:[convArgs dataLen]];
}
@end


@interface PgConv_anyarray_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_anyarray_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_array_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_array_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_bit_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_bit_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_boolsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_boolsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
    if( [convArgs data][0] == 0 ) {
        return [[NSString alloc] initWithString:@"false"];
    } else {
        return [[NSString alloc] initWithString:@"true"];
    }
}
@end


@interface PgConv_box_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_box_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_bpcharsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_bpcharsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_byteasend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_byteasend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_cash_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_cash_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_charsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_charsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_cidr_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_cidr_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_cidsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_cidsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_circle_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_circle_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_cstring_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_cstring_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_date_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_date_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
    NSAssert([convArgs dataLen] == 4, @"date len != 4 %d", [convArgs dataLen]);
    int32_t intVal = ntohl(*(int32_t *)[convArgs data]);
    int64_t i64 = intVal;
    i64 = i64 * 24 * 60 * 60;
    // postgres ref date seems to be 1,1,2000 where obj c likes 1,1,2001 
    // so lets give this a shot
    NSDate * ref = [NSDate dateWithString:@"2000-01-01 00:00:00 +0000"];
    NSDate * dt = [[NSDate alloc] initWithTimeInterval:i64 sinceDate:ref];
    // SMKLogDebug(@"date:\n  %@\n  %u %lu %lf %@", dt,intVal, i64, [ref timeIntervalSinceReferenceDate], ref );
    return dt; 
}
@end


@interface PgConv_float4send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_float4send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        const char * val = [convArgs data];
        union  {
            Float32     f;
            uint32_t  i;
        } swap;
        swap.f = *(Float32 *)val;
        swap.i = ntohl(swap.i);
        return [[NSNumber alloc] initWithFloat:swap.f];
}
@end


@interface PgConv_float8send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_float8send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        const char * val = [convArgs data];
        union {
            double  f;
            uint64_t i;
        } swap;
        // MAYBE ....
        uint32_t h32;
        uint32_t l32;
        memcpy(&h32, val, 4);
        memcpy(&l32, val + 4, 4);
        h32 = ntohl(h32);
        l32 = ntohl(l32);
        int64_t intVal = h32;
        intVal <<= 32;
        intVal |= l32;
        swap.i = intVal;
        return [[NSNumber alloc] initWithDouble:swap.f];
}
@end


@interface PgConv_inet_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_inet_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_int2send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_int2send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        int16_t val = ntohs(*(int16_t *)[convArgs data]);
        return [[NSNumber alloc] initWithShort:val];
}
@end


@interface PgConv_int2vectorsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_int2vectorsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_int4send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_int4send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
    // SMKLogDebug(@"%p %d %d", [convArgs data], [convArgs dataLen], [convArgs isNull]);
    int32_t val = ntohl(*(int32_t *)[convArgs data]);
    return [[NSNumber alloc] initWithInt:val];
}
@end


@interface PgConv_int8send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_int8send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        uint32_t h32 = 0;
        uint32_t l32 = 0;
        const char * val = [convArgs data];
        memcpy(&h32, val, 4);
        memcpy(&l32, val + 4, 4);
        h32 = ntohl(h32);
        l32 = ntohl(l32);
        int64_t i64 = h32;
        i64 <<= 32;
        i64 |= l32;
        return [[NSNumber alloc] initWithInteger:i64];
}
@end

@interface PgConv_integer_send : NSObject <PgConverter>
@property (retain) PgConv_int2send * int2;
@property (retain) PgConv_int4send * int4;
@property (retain) PgConv_int8send * int8;

-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_integer_send
@synthesize int2;
@synthesize int4;
@synthesize int8;

-(NSObject *)conv:(PgConvArgs *)convArgs
{
        switch ( [convArgs dataLen] ) {
            case sizeof( int16_t ):
                return [int2 conv:convArgs];
                
            case sizeof( int32_t ):
                return [int4 conv:convArgs];
                
            case sizeof( int64_t ):
                return [int8 conv:convArgs];
                
            default:
                return [[NSNumber alloc] init];
        }
}
@end



@interface PgConv_interval_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_interval_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
  if( [convArgs dataLen] == 16 ) {
    uint32_t h32 = 0;
    uint32_t l32 = 0;
    const char * val = [convArgs data];
    memcpy(&h32, val, 4);
    memcpy(&l32, val + 4, 4);
    h32 = ntohl(h32);
    l32 = ntohl(l32);
    int64_t i64 = h32;
    i64 <<= 32;
    i64 |= l32;
    int32_t day;
    int32_t mnth;
    memcpy(&day, val + 8, 4);
    day = ntohl(day);
    memcpy(&mnth, val + 12, 4);
    mnth = ntohl(mnth);
    // int64_t sec = i64;
    double  timeVal = i64;
    timeVal = timeVal / 1000000;
    //NSLog(@"interval len t:%lld %f %d %d",i64,timeVal, day,mnth);
    return [[SMKDBInterval alloc]initWithMonths:mnth days:day secs:timeVal];
  }
  return [[NSData alloc] initWithBytes:[convArgs data]
                                length:[convArgs dataLen]];
}
@end


@interface PgConv_line_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_line_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_lseg_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_lseg_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_macaddr_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_macaddr_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_namesend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_namesend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_numeric_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_numeric_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
#define PG_NUMERIC_NEG	0x4000
    const char * val = [convArgs data];
    const int16_t * int16Vals = (const int16_t *)val;
    int16_t ndigits = ntohs(*int16Vals); ++int16Vals;
    int16_t weight = ntohs(*int16Vals); ++int16Vals;
    int16_t sign = ntohs(*int16Vals); ++int16Vals;
    int16_t dscale = ntohs(*int16Vals); ++int16Vals;
    char buffer[512];
    char * bp = buffer;
    if( sign == PG_NUMERIC_NEG ) {
        *bp++ = '-';
    }
    int16_t digUsed = 0;
    if( ndigits > 0  && weight >= 0 ) {
        // first digit is different (no leading zeros
        int16_t digit = ntohs(int16Vals[digUsed]);
        ++ digUsed;
        bool putIt = 0;
        int dig = digit / 1000;
        if( dig > 0 ) {
            putIt = 1;
            digit -= dig * 1000;
            *bp++ = dig + '0';
        }
        dig = digit / 100;
        digit -= dig * 100;
        if( putIt ) {
            *bp++ = dig +'0';
        } else if( dig > 0 ) {
            *bp++ = dig +'0';
            putIt = 1;
        }
        dig = digit / 10;
        digit -= dig * 10;
        if( putIt ) {
            *bp++ = dig +'0';
        } else if( dig > 0 ) {
            *bp++ = dig +'0';
        }
        *bp++ = digit + '0';
    }
    for( ; digUsed <= weight; ++ digUsed ) {
        int16_t digit = (digUsed < ndigits ) ? ntohs(int16Vals[digUsed]): 0;
        int dig = digit / 1000;
        digit -= dig * 1000;
        *bp++ = dig + '0';
        
        dig = digit / 100;
        digit -= dig * 100;
        *bp++ = dig +'0';
        
        dig = digit / 10;
        digit -= dig * 10;
        *bp++ = dig +'0';
        
        *bp++ = digit + '0';
    }
    if( weight < 0 ) {
        *bp++ = '0';
        digUsed = weight + 1;
    }
    if( dscale > 0 ) {
        *bp++ = '.';
        char * endcp = bp + dscale;
        for( int ds = 0; ds < dscale; ds += 4 ) {
            int16_t digit = (digUsed < ndigits ) ? ntohs(int16Vals[digUsed]): 0;
            int dig = digit / 1000;
            digit -= dig * 1000;
            *bp++ = dig + '0';
            
            dig = digit / 100;
            digit -= dig * 100;
            *bp++ = dig +'0';
            
            dig = digit / 10;
            digit -= dig * 10;
            *bp++ = dig +'0';
            
            *bp++ = digit + '0';
        }
        *endcp = 0;
    } else {
        *bp = 0;
    }
    NSString * numStr = [NSString stringWithUTF8String:buffer];
    return [[NSDecimalNumber alloc] initWithString:numStr];
}
@end


@interface PgConv_oidsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_oidsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_oidvectorsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_oidvectorsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_path_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_path_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_point_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_point_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_poly_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_poly_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_record_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_record_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_regclasssend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_regclasssend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_regconfigsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_regconfigsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_regdictionarysend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_regdictionarysend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_regoperatorsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_regoperatorsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_regopersend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_regopersend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_regproceduresend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_regproceduresend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_regprocsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_regprocsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_regtypesend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_regtypesend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_reltimesend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_reltimesend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_textsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_textsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSString alloc] initWithBytes:[convArgs data]
                                        length:[convArgs dataLen]
                                      encoding:NSUTF8StringEncoding];
}
@end


@interface PgConv_tidsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_tidsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_time_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_time_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_timestamp_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_timestamp_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        uint32_t h32 = 0;
        uint32_t l32 = 0;
        const char * val = [convArgs data];
        memcpy(&h32, val, 4);
        memcpy(&l32, val + 4, 4);
        h32 = ntohl(h32);
        l32 = ntohl(l32);
        int64_t i64 = h32;
        i64 <<= 32;
        i64 |= l32;
        NSDate * ref = [NSDate dateWithString:@"2000-01-01 00:00:00 +0000"];
        double dTsVal = i64;
        dTsVal /= 1000000;
        NSDate * rdt = [NSDate dateWithTimeInterval:dTsVal sinceDate:ref];
        
        return rdt;
}
@end


@interface PgConv_timestamptz_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_timestamptz_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        uint32_t h32 = 0;
        uint32_t l32 = 0;
        const char * val = [convArgs data];
        memcpy(&h32, val, 4);
        memcpy(&l32, val + 4, 4);
        h32 = ntohl(h32);
        l32 = ntohl(l32);
        int64_t i64 = h32;
        i64 <<= 32;
        i64 |= l32;
        NSDate * ref = [NSDate dateWithString:@"2000-01-01 00:00:00 +0000"];
        double dTsVal = i64;
        dTsVal /= 1000000;
        NSDate * rdt = [NSDate dateWithTimeInterval:dTsVal sinceDate:ref];
        
        return rdt;
}
@end


@interface PgConv_timetz_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_timetz_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_tintervalsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_tintervalsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
  return [[NSData alloc] initWithBytes:[convArgs data]
                                length:[convArgs dataLen]];
}
@end


@interface PgConv_tsquerysend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_tsquerysend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_tsvectorsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_tsvectorsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_txid_snapshot_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_txid_snapshot_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_unknownsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_unknownsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_uuid_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_uuid_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_varbit_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_varbit_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_varcharsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_varcharsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_xidsend : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_xidsend
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_xml_send : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_xml_send
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSData alloc] initWithBytes:[convArgs data]
                                      length:[convArgs dataLen]];
}
@end


@interface PgConv_byteaout : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_byteaout
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        size_t binLen = 0;
        unsigned char * binary = PQunescapeBytea((const unsigned char *)[convArgs data], &binLen);
        NSData * data = [[NSData alloc] initWithBytes:binary length:binLen];
        PQfreemem(binary);
        SMKLogDebug(@"bin conv fLen %d tLen %u",[convArgs dataLen], binLen);
        return data;
}
@end


@interface PgConv_textout : NSObject <PgConverter>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@implementation PgConv_textout
-(NSObject *)conv:(PgConvArgs *)convArgs
{
        return [[NSString alloc] initWithBytes:[convArgs data]
                                        length:[convArgs dataLen]
                                      encoding:NSUTF8StringEncoding];
}
@end



#pragma mark Implementation

static NSDictionary * converterDict = nil;
static PgConv_textout * conv_text_out = nil;
static PgConv_textsend * conv_text_send = nil;
static PgConv_int4send * conv_int4_send = nil;
static PgConv_int8send * conv_int8_send = nil;
static PgConv_integer_send * conv_integer_send = nil;

@implementation PgConvArgs
@synthesize data;
@synthesize dataLen;
@synthesize isNull;
@end


@implementation SMKDBTypeConv_postgres
@synthesize tName;
@synthesize tSend;
@synthesize tOutput;
@synthesize sendConv;
@synthesize outConv;


-(void) convDictInit
{
    conv_text_out = [[PgConv_textout alloc] init];
    conv_text_send = [[PgConv_textsend alloc] init];
    conv_int4_send = [[PgConv_int4send alloc] init];
    conv_int8_send = [[PgConv_int8send alloc] init];
    conv_integer_send = [[PgConv_integer_send alloc] init];
    
    converterDict = 
    [NSDictionary dictionaryWithObjectsAndKeys:
     conv_text_out, @"abstimeout",
     conv_text_out, @"aclitemout",
     conv_text_out, @"any_out",
     conv_text_out, @"anyarray_out",
     conv_text_out, @"anyelement_out",
     conv_text_out, @"anyenum_out",
     conv_text_out, @"anynonarray_out",
     conv_text_out, @"array_out",
     conv_text_out, @"bit_out",
     conv_text_out, @"boolout",
     conv_text_out, @"box_out",
     conv_text_out, @"bpcharout",
     [[PgConv_byteaout alloc] init], @"byteaout",
     conv_text_out, @"cash_out",
     conv_text_out, @"charout",
     conv_text_out, @"cidout",
     conv_text_out, @"cidr_out",
     conv_text_out, @"circle_out",
     conv_text_out, @"cstring_out",
     conv_text_out, @"date_out",
     conv_text_out, @"float4out",
     conv_text_out, @"float8out",
     conv_text_out, @"gtsvectorout",
     conv_text_out, @"inet_out",
     conv_text_out, @"int2out",
     conv_text_out, @"int2vectorout",
     conv_text_out, @"int4out",
     conv_text_out, @"int8out",
     conv_text_out, @"internal_out",
     conv_text_out, @"interval_out",
     conv_text_out, @"language_handler_out",
     conv_text_out, @"line_out",
     conv_text_out, @"lseg_out",
     conv_text_out, @"macaddr_out",
     conv_text_out, @"nameout",
     conv_text_out, @"numeric_out",
     conv_text_out, @"oidout",
     conv_text_out, @"oidvectorout",
     conv_text_out, @"opaque_out",
     conv_text_out, @"path_out",
     conv_text_out, @"point_out",
     conv_text_out, @"poly_out",
     conv_text_out, @"record_out",
     conv_text_out, @"regclassout",
     conv_text_out, @"regconfigout",
     conv_text_out, @"regdictionaryout",
     conv_text_out, @"regoperatorout",
     conv_text_out, @"regoperout",
     conv_text_out, @"regprocedureout",
     conv_text_out, @"regprocout",
     conv_text_out, @"regtypeout",
     conv_text_out, @"reltimeout",
     conv_text_out, @"smgrout",
     conv_text_out, @"textout",
     conv_text_out, @"tidout",
     conv_text_out, @"time_out",
     conv_text_out, @"timestamp_out",
     conv_text_out, @"timestamptz_out",
     conv_text_out, @"timetz_out",
     conv_text_out, @"tintervalout",
     conv_text_out, @"trigger_out",
     conv_text_out, @"tsqueryout",
     conv_text_out, @"tsvectorout",
     conv_text_out, @"txid_snapshot_out",
     conv_text_out, @"unknownout",
     conv_text_out, @"uuid_out",
     conv_text_out, @"varbit_out",
     conv_text_out, @"varcharout",
     conv_text_out, @"void_out",
     conv_text_out, @"xidout",
     conv_text_out, @"xml_out",
     
     [[PgConv_abstimesend alloc] init], @"abstimesend",
     [[PgConv_anyarray_send alloc] init], @"anyarray_send",
     [[PgConv_array_send alloc] init], @"array_send",
     [[PgConv_bit_send alloc] init], @"bit_send",
     [[PgConv_boolsend alloc] init], @"boolsend",
     [[PgConv_box_send alloc] init], @"box_send",
     conv_text_send, @"bpcharsend",
     [[PgConv_byteasend alloc] init], @"byteasend",
     [[PgConv_cash_send alloc] init], @"cash_send",
     conv_text_send, @"charsend",
     [[PgConv_cidr_send alloc] init], @"cidr_send",
     conv_integer_send, @"cidsend",
     [[PgConv_circle_send alloc] init], @"circle_send",
     [[PgConv_cstring_send alloc] init], @"cstring_send",
     [[PgConv_date_send alloc] init], @"date_send",
     [[PgConv_float4send alloc] init], @"float4send",
     [[PgConv_float8send alloc] init], @"float8send",
     [[PgConv_inet_send alloc] init], @"inet_send",
     [[PgConv_int2send alloc] init], @"int2send",
     [[PgConv_int2vectorsend alloc] init], @"int2vectorsend",
     conv_int4_send, @"int4send",
     conv_int8_send, @"int8send",
     [[PgConv_interval_send alloc] init], @"interval_send",
     [[PgConv_line_send alloc] init], @"line_send",
     [[PgConv_lseg_send alloc] init], @"lseg_send",
     [[PgConv_macaddr_send alloc] init], @"macaddr_send",
     conv_text_send, @"namesend",
     [[PgConv_numeric_send alloc] init], @"numeric_send",
     conv_integer_send, @"oidsend",
     [[PgConv_oidvectorsend alloc] init], @"oidvectorsend",
     [[PgConv_path_send alloc] init], @"path_send",
     [[PgConv_point_send alloc] init], @"point_send",
     [[PgConv_poly_send alloc] init], @"poly_send",
     [[PgConv_record_send alloc] init], @"record_send",
     conv_integer_send, @"regclasssend",
     conv_integer_send, @"regconfigsend",
     [[PgConv_regdictionarysend alloc] init], @"regdictionarysend",
     conv_integer_send, @"regoperatorsend",
     conv_integer_send, @"regopersend",
     conv_integer_send, @"regproceduresend",
     conv_integer_send, @"regprocsend",
     conv_integer_send, @"regtypesend",
     [[PgConv_reltimesend alloc] init], @"reltimesend",
     conv_text_send, @"textsend",
     [[PgConv_tidsend alloc] init], @"tidsend",
     [[PgConv_time_send alloc] init], @"time_send",
     [[PgConv_timestamp_send alloc] init], @"timestamp_send",
     [[PgConv_timestamptz_send alloc] init], @"timestamptz_send",
     [[PgConv_timetz_send alloc] init], @"timetz_send",
     [[PgConv_tintervalsend alloc] init], @"tintervalsend",
     [[PgConv_tsquerysend alloc] init], @"tsquerysend",
     [[PgConv_tsvectorsend alloc] init], @"tsvectorsend",
     [[PgConv_txid_snapshot_send alloc] init], @"txid_snapshot_send",
     [[PgConv_unknownsend alloc] init], @"unknownsend",
     [[PgConv_uuid_send alloc] init], @"uuid_send",
     [[PgConv_varbit_send alloc] init], @"varbit_send",
     conv_text_send, @"varcharsend",
     conv_integer_send, @"xidsend",
     conv_text_send, @"xml_send",
     
                     nil];
}
-(id)initTypeConv:(NSString *)name 
            tSend:(NSString *)snd 
             tOut:(NSString *)tOut
{
    self = [super init];
    if( self ) {
        if( converterDict == nil ) {
            [self convDictInit];
        }
        tName = name;
        tSend = snd;
        tOutput = tOut;
        sendConv = [converterDict objectForKey:tSend];        
        outConv = [converterDict objectForKey:tOutput];
    }
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@ %@",tName, tSend, tOutput];
}
@end
