/**
 File:		SMKDBResults_mysql.m
 Project:	SMKDB 
 Desc:
 
 
 Notes:
 
 Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
 Created:     02/02/2012 04:36
 Copyright:   Copyright (c) 2012 Secure Media Keepers
              www.SecureMediaKeepers.com
              All rights reserved.
 
 Revision History: (See ChangeLog for details)
 
   $Author$
   $Date$
   $Revision$
   $Name$
   $State$
 
 $Id$
 
**/
#import "SMKDBResults_mysql.h"


@implementation SMKDBResults_mysql
@synthesize myconn;
@synthesize myRes;
@synthesize resFieldNames;
@synthesize resFieldTypes;

-(id)initWithConn:(SMKDBConn_mysql *)conn results:(MYSQL_RES *)res
{
    self = [super init];
    if( self ) {
        myconn = conn;
        myRes = res;
    }
    return self;
}

-(void) dealloc
{
    if( myRes ) {
        mysql_free_result(myRes);
        myRes = NULL;
    }
}

-(SMKDBConn_mysql *)conn
{
    return myconn;
}

-(NSUInteger)numFields
{
    return mysql_num_fields(self.myRes);
}

-(NSArray *)fieldNames
{
    if( resFieldNames == nil ) {
        NSUInteger numFlds = [self numFields];
        NSMutableArray * tmp = [[NSMutableArray alloc] 
                                initWithCapacity:numFlds];
        MYSQL_FIELD * resFldInfo = mysql_fetch_fields(self.myRes);

        for( unsigned int i = 0; i < numFlds; ++ i ) {
            [tmp addObject:
             [NSString stringWithUTF8String:resFldInfo[i].name]];
        }
        resFieldNames = tmp;
    }
    return resFieldNames;
}

-(NSArray *)fieldTypes
{
    if( resFieldTypes == nil ) {
        NSUInteger numFlds = [self numFields];
        NSMutableArray * tmp = [[NSMutableArray alloc] 
                                initWithCapacity:numFlds];
        MYSQL_FIELD * resFldInfo = mysql_fetch_fields(self.myRes);
        
        for( unsigned int i = 0; i < numFlds; ++ i ) {
            switch ( resFldInfo[i].type ) {
                case MYSQL_TYPE_TINY_BLOB: 
                case MYSQL_TYPE_BLOB: 
                case MYSQL_TYPE_MEDIUM_BLOB: 
                case MYSQL_TYPE_LONG_BLOB: 
                    [tmp addObject:[[NSData alloc] init]];
                    break;
                default:
                    [tmp addObject:[[NSString alloc] init]];
                    break;
            }
        }
        resFieldTypes = tmp;
    }
    return resFieldTypes;
}

-(NSMutableDictionary *)fetchRowDict
{
    MYSQL_ROW myRow = mysql_fetch_row(self.myRes);
    if( myRow ) {
        NSUInteger numFlds = [self numFields];
        NSArray * fldNames = [self fieldNames];
        MYSQL_FIELD * resFldInfo = mysql_fetch_fields(self.myRes);
        unsigned long * myLengths = mysql_fetch_lengths(self.myRes);
        NSMutableDictionary * data 
        = [[NSMutableDictionary alloc] initWithCapacity:numFlds];
    
        for( unsigned int f = 0; f < numFlds; ++ f ) {
            id fldObj = nil;
            switch ( resFldInfo[f].type ) {
                case MYSQL_TYPE_TINY_BLOB: 
                case MYSQL_TYPE_BLOB: 
                case MYSQL_TYPE_MEDIUM_BLOB: 
                case MYSQL_TYPE_LONG_BLOB: 
                    if( myLengths[f] != 0 ) {
                        NSData * t = [NSData 
                                      dataWithBytes:myRow[f] 
                                      length:myLengths[f]];
                        fldObj = t;
                    } else {
                        fldObj = [[NSData alloc]init];
                    }
                    break;
                default:
                    if( myLengths[f] != 0 ) {
                        NSString * s;
                        s = [[NSString alloc] 
                             initWithBytes:myRow[f] 
                             length:myLengths[f] 
                             encoding:NSUTF8StringEncoding];
                        fldObj = s;
                    } else {
                        fldObj = [[NSString alloc] init];
                    }
            }
            [data setObject:fldObj forKey:[fldNames objectAtIndex:f]];
        }
        return  data;
    } else {
        return nil;
    }
}

-(NSMutableArray *)fetchRowArray
{
    MYSQL_ROW myRow = mysql_fetch_row(self.myRes);
    if( myRow ) {
        NSUInteger numFlds = [self numFields];
        MYSQL_FIELD * resFldInfo = mysql_fetch_fields(self.myRes);
        unsigned long * myLengths = mysql_fetch_lengths(self.myRes);
        NSMutableArray * data 
        = [[NSMutableArray alloc] initWithCapacity:numFlds];
        
        for( unsigned int f = 0; f < numFlds; ++ f ) {
            id fldObj = nil;
            switch ( resFldInfo[f].type ) {
                case MYSQL_TYPE_TINY_BLOB: 
                case MYSQL_TYPE_BLOB: 
                case MYSQL_TYPE_MEDIUM_BLOB: 
                case MYSQL_TYPE_LONG_BLOB: 
                    if( myLengths[f] != 0 ) {
                        NSData * t = [NSData 
                                      dataWithBytes:myRow[f] 
                                      length:myLengths[f]];
                        fldObj = t;
                    } else {
                        fldObj = [[NSData alloc]init];
                    }
                    break;
                default:
                    if( myLengths[f] != 0 ) {
                        NSString * s;
                        s = [[NSString alloc] 
                             initWithBytes:myRow[f] 
                             length:myLengths[f] 
                             encoding:NSUTF8StringEncoding];
                        fldObj = s;
                    } else {
                        fldObj = [[NSString alloc] init];
                    }
            }
            [data addObject:fldObj];
        }
        return  data;
    } else {
        return nil;
    }
}

-(NSString *)description
{
    NSMutableString * desc = [NSMutableString stringWithFormat:
                              @"%@: fields: %lu\n",
                              [self className],
                              [self numFields]];
    for( NSString * fld in [self fieldNames] ) {
        [desc appendFormat:@"  %@\n",fld];
    }
    return desc;
}

@end
