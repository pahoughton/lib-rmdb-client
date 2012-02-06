//
//  SMKDBResults_mysql.m
//  SMKDB
//
//  Created by Paul Houghton on 2/5/12.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "SMKDBResults_mysql.h"
#import "SMKDBRecProcMtObj.h"

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
        NSArray * fldNames = [self fieldNames];
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

-(void)fetchAllRowsDictMtRecProc:(id <SMKDBRecProcDict>)proc
{
    NSMutableDictionary * rec;
    SMKDBRecProcDictMtObj * redirObj = [[SMKDBRecProcDictMtObj alloc] initWithRecProc:proc];
    
    while( (rec = [self fetchRowDict]) != nil ) {
        [redirObj performSelectorOnMainThread:@selector(dbRecProc:) 
                                   withObject:rec 
                                waitUntilDone:FALSE];
    }
    [redirObj performSelectorOnMainThread:@selector(dbRecProc:) 
                               withObject:nil 
                            waitUntilDone:FALSE];
}

-(void)fetchAllRowsArrayMtRecProc:(id <SMKDBRecProcArray>)proc
{
    NSMutableArray * rec;
    SMKDBRecProcArrayMtObj * redirObj = [[SMKDBRecProcArrayMtObj alloc] initWithRecProc:proc];
    
    while( (rec = [self fetchRowArray]) != nil ) {
        [redirObj performSelectorOnMainThread:@selector(dbRecProc:) 
                                   withObject:rec 
                                waitUntilDone:FALSE];
    }
    [redirObj performSelectorOnMainThread:@selector(dbRecProc:) 
                               withObject:nil 
                            waitUntilDone:FALSE];
    
}

-(void)fetchAllRowsDictRecProc:(id <SMKDBRecProcDict>)proc
{
    NSMutableDictionary * rec;
    while( (rec = [self fetchRowDict]) != nil ) {
        [proc performSelector:@selector(dbRecProc:) withObject:rec];
    }
    [proc performSelector:@selector(dbRecProc:) withObject:nil];
}
-(void)fetchAllRowsArrayRecProc:(id <SMKDBRecProcArray>)proc
{
    NSMutableArray * rec;
    while( (rec = [self fetchRowArray]) != nil ) {
        [proc performSelector:@selector(dbRecProc:) withObject:rec];
    }
    [proc performSelector:@selector(dbRecProc:) withObject:nil];
}

-(void)fetchAllRowsDictMtObj:(id)obj proc:(SEL)sel
{
    NSMutableDictionary * rec;
    while( (rec = [self fetchRowDict]) != nil ) {
        [obj performSelectorOnMainThread:sel withObject:rec waitUntilDone:FALSE];
    }
    [obj performSelectorOnMainThread:sel withObject:nil waitUntilDone:FALSE];
}
-(void)fetchAllRowsArrayMtObj:(id)obj proc:(SEL)sel
{
    NSMutableArray * rec;
    while( (rec = [self fetchRowArray]) != nil ) {
        [obj performSelectorOnMainThread:sel withObject:rec waitUntilDone:FALSE];
    }
    [obj performSelectorOnMainThread:sel withObject:nil waitUntilDone:FALSE];    
}


@end
