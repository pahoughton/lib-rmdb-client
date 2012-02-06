/**
    SMKDBResults.m
    SMKDB
  
    Created by Paul Houghton on 2/2/12.
    Copyright (c) 2012 Secure Media Keepers. All rights reserved.
 **/

#import "SMKDB_priv.h"

@implementation SMKDBResults_priv
@synthesize conn;
@synthesize myRes;
@synthesize resFldCnt;
@synthesize resFldInfo;

-(id) initWithConn:(SMKDBConn *)connPriv rowByRow:(BOOL)rowByRow
{
    self = [super init];
    if( self ) {
        self.conn = connPriv;
        if( rowByRow ) {
            self.myRes = mysql_use_result(self.conn.priv.my);
        } else {
            self.myRes = mysql_store_result(self.conn.priv.my);
        }
        resFldCnt = mysql_num_fields(self.myRes);
        resFldInfo = mysql_fetch_fields(self.myRes);
    }
    return self;
}

-(void) dealloc
{
    if( myRes ) {
        mysql_free_result(myRes);
        myRes = 0;
    }
}

@end

@interface SMKDBResults(intern)
-(MYSQL_RES *)res;
-(MYSQL *)my;
@end


@implementation SMKDBResults
@synthesize priv;
@synthesize fieldNames;

-(id)init
{
    NSException * opps = [[NSException alloc] 
                          initWithName:@"SMKDB" 
                          reason:@"default init of SMKDBResults is invalid"
                          userInfo:nil];
    [opps raise];
    return nil;
}

-(id) initWithPriv:(SMKDBResults_priv *)myPriv
{
    self = [super init];
    if( self ) {
        self.priv = myPriv;
        NSMutableArray * tmp = [[NSMutableArray alloc] initWithCapacity:priv.resFldCnt];
        for( unsigned int i = 0; i < priv.resFldCnt; ++ i ) {
            [tmp addObject:[[NSString alloc] initWithBytes:priv.resFldInfo[i].name
                                                    length:priv.resFldInfo[i].name_length
                                                  encoding:NSUTF8StringEncoding]];
        }
        fieldNames = tmp;
    }
    return self;
}

-(SMKDBConn *)conn
{
    return self.priv.conn;
}

-(NSMutableDictionary *)fetchRowDict
{
    MYSQL_ROW myRow = mysql_fetch_row([self res]);
    if( myRow ) {
        unsigned long * myLengths = mysql_fetch_lengths([self res]);
        
        NSMutableDictionary * data 
        = [[NSMutableDictionary alloc] initWithCapacity:self.priv.resFldCnt];
        
        for( unsigned int f = 0; f < self.priv.resFldCnt; ++ f ) {
            id fldObj = nil;
            switch ( priv.resFldInfo[f].type ) {
                case MYSQL_TYPE_TINY_BLOB: 
                case MYSQL_TYPE_BLOB: 
                case MYSQL_TYPE_MEDIUM_BLOB: 
                case MYSQL_TYPE_LONG_BLOB: 
                    // binary
                    if( myLengths[f] != 0 ) {
                        NSData * t = [NSData dataWithBytes:myRow[f] length:myLengths[f]];
                        fldObj = t;
                    }
                    break;
                    
                default:
                    if( myLengths[f] != 0 ) {
                        NSString * s = nil;
                        s = [[NSString alloc] initWithBytes:myRow[f] 
                                                     length:myLengths[f] 
                                                   encoding:NSUTF8StringEncoding];
                        fldObj = s;
                    }
                    break;
            }
            [data setValue:fldObj 
                    forKey:[self.fieldNames objectAtIndex:f ]];
            
        }
        return data;
    }
    return nil;
}

// some duplication w/ fetchRowDict, but I prefer the performance advantage.
-(NSMutableArray *)fetchRowArray
{
    MYSQL_ROW myRow = mysql_fetch_row([self res]);
    if( myRow ) {
        unsigned long * myLengths = mysql_fetch_lengths([self res]);
        
        NSMutableArray * data = [[NSMutableArray alloc] initWithCapacity:self.priv.resFldCnt];
        
        for( unsigned int f = 0; f < self.priv.resFldCnt; ++ f ) {
            id fldObj = nil;
            switch ( priv.resFldInfo[f].type ) {
                case MYSQL_TYPE_TINY_BLOB: 
                case MYSQL_TYPE_BLOB: 
                case MYSQL_TYPE_MEDIUM_BLOB: 
                case MYSQL_TYPE_LONG_BLOB: 
                    // binary
                    if( myLengths[f] != 0 ) {
                        NSData * t = [NSData dataWithBytes:myRow[f] length:myLengths[f]];
                        fldObj = t;
                    }
                    break;
                    
                default:
                    if( myLengths[f] != 0 ) {
                        NSString * s = nil;
                        s = [[NSString alloc] initWithBytes:myRow[f] 
                                                     length:myLengths[f] 
                                                   encoding:NSUTF8StringEncoding];
                        fldObj = s;
                    }
                    break;
            }
            [data addObject:fldObj];
            
        }
        return data;
    }
    return nil;
}

-(BOOL)fetchRowsSelResults:(id)obj sel:(SEL)onMain :(BOOL)main
{
    return FALSE;
}

-(MYSQL_RES *)res
{
    return self.priv.myRes;
}

-(MYSQL *)my
{
    return self.priv.conn.priv.my;
}


@end
