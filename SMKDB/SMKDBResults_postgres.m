//
//  SMKDBResults_postgres.m
//  SMKDB
//
//  Created by Paul Houghton on 2/5/12.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "SMKDBResults_postgres.h"
#import "SMKDBRecProcMtObj.h"

@implementation SMKDBResults_postgres
@synthesize myRes;
@synthesize pgConn;
@synthesize resFieldNames;
@synthesize resFieldClasses;
@synthesize fetchRowNum;

-(id)initWithRes:(PGresult *)res conn:(SMKDBConn_postgres *)conn
{
    self = [super init];
    if( self ) {
        myRes = res;
        pgConn = conn;
        fetchRowNum = 0;
    }
    return self;
}


-(SMKDBConn_postgres *)conn{
    return pgConn;
}

-(NSUInteger)numFields
{
    return  [[NSNumber numberWithInt:PQnfields(myRes)] unsignedIntegerValue];
}

-(NSArray *)fieldNames
{
    if( resFieldNames == nil ) {
        int numFlds = (int)[self numFields];
        NSMutableArray * names = [[NSMutableArray alloc] initWithCapacity:numFlds];
        int f = 0;
        for( ; f < numFlds; ++ f ) {
            [names addObject:[NSString stringWithUTF8String:PQfname(myRes, f)]];
        }
        resFieldNames = names;
    }
    return resFieldNames;
}

-(NSArray *)fieldTypes
{
    if( resFieldClasses == nil ) {
        int fnum = 0;
        int numFlds = (int)[self numFields];
        NSMutableArray * types = [[NSMutableArray alloc] initWithCapacity:numFlds];
        for( ; fnum < numFlds; ++ fnum ) {
            if( PQfformat(myRes, fnum) == 0 ) {
                [types addObject:[[NSString alloc] init]];
            } else {
                [types addObject:[[NSData alloc] init]];
            }
        }
    }
    return resFieldClasses;
}

-(NSMutableDictionary *)fetchRowDict
{
    if( fetchRowNum < PQntuples(myRes) ) {
        NSArray * fNames = [self fieldNames];
        
        NSMutableDictionary * rec = [[NSMutableDictionary alloc] 
                                     initWithCapacity:[fNames count]];
        int fNum = 0;
        for( NSString * fldName in fNames ) {
            if( PQfformat(myRes, fNum) == 0 ) {
                //string
                if( PQgetisnull(myRes, fetchRowNum, fNum)
                   || PQgetlength(myRes, fetchRowNum, fNum) ) {
                    [rec setObject:[[NSString alloc] init] 
                            forKey:[resFieldNames objectAtIndex:fNum]];
                } else {
                    [rec setObject:[[NSString alloc] 
                                    initWithUTF8String:
                                    PQgetvalue(myRes, fetchRowNum, fNum)] 
                         forKey:[resFieldNames objectAtIndex:fNum]];
                }
            } else {
                // data
                if( PQgetisnull(myRes, fetchRowNum, fNum)
                   || PQgetlength(myRes, fetchRowNum, fNum) ) {
                    [rec setObject:[[NSData alloc] init] 
                            forKey:[resFieldNames objectAtIndex:fNum]];
                } else {
                    [rec setObject:[NSData 
                                    dataWithBytes: PQgetvalue(myRes, fetchRowNum, fNum)
                                    length:PQgetlength(myRes, fetchRowNum, fNum)]
                            forKey:[resFieldNames objectAtIndex:fNum]];
                }
            }
        }
        ++ fetchRowNum;
        return rec;
    } else {
        return nil;
    }
}
-(NSMutableArray *)fetchRowArray
{
    if( fetchRowNum < PQntuples(myRes) ) {
        NSArray * fNames = [self fieldNames];
        
        NSMutableArray * rec = [[NSMutableArray alloc] 
                                initWithCapacity:[fNames count]];
        int fNum = 0;
        for( NSString * fldName in fNames ) {
            if( PQfformat(myRes, fNum) == 0 ) {
                //string
                if( PQgetisnull(myRes, fetchRowNum, fNum)
                   || PQgetlength(myRes, fetchRowNum, fNum) ) {
                    [rec addObject:[[NSString alloc] init]];
                } else {
                    [rec addObject:[[NSString alloc] 
                                    initWithUTF8String:
                                     PQgetvalue(myRes, fetchRowNum, fNum)]]; 
                }
            } else {
                // data
                if( PQgetisnull(myRes, fetchRowNum, fNum)
                   || PQgetlength(myRes, fetchRowNum, fNum) ) {
                    [rec addObject:[[NSData alloc] init]];
                } else {
                    [rec addObject:[NSData 
                                    dataWithBytes: PQgetvalue(myRes, fetchRowNum, fNum)
                                    length:PQgetlength(myRes, fetchRowNum, fNum)]];
                }
            }
        }
        ++ fetchRowNum;
        return rec;
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


-(void)dealloc
{
    if( myRes ) {
        PQclear( myRes );
        myRes = NULL;
    }
}
@end
