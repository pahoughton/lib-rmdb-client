/**
 File:		SMKDBResults_postgres.m
 Project:	SMKDB 
 Desc:
 
 Notes:
 
 Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
 Created:     02/05/2012 04:36
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

#import "SMKDBResults_postgres.h"
#import "SMKDBConn_postgres.h"
#import "SMKDBTypeConv_postgres.h"

@interface PGFieldInfo : NSObject
@property (assign) int fNum;
@property (assign) int fFormat;
@property (assign) Oid fType;
@property (retain) NSString * fName;
@property (retain) SMKDBTypeConv_postgres * typeConv;
@property (retain) id <PgConverter> conv;
-(NSString *)description;
@end

@implementation PGFieldInfo

@synthesize fNum;
@synthesize fFormat;
@synthesize fType;
@synthesize fName;
@synthesize typeConv;
@synthesize conv;
-(NSString *)description
{
    return [NSString stringWithFormat:
            @"%@ %d %d %u %@",
            fName,
            fNum,
            fFormat,
            fType,
            [conv class] ];
            
}
@end


@implementation SMKDBResults_postgres
@synthesize myRes;
@synthesize pgConn;
@synthesize resFieldInfo;
@synthesize resFieldNames;
@synthesize resFieldClasses;
@synthesize numberOfFields;
@synthesize numberOfRows;
@synthesize fetchRowNum;

-(void) getResultsInfo 
{
    if( resFieldInfo == nil ) {
        
        resFieldInfo = [[NSMutableArray alloc] initWithCapacity:numberOfFields];
        resFieldNames = [[NSMutableArray alloc] initWithCapacity:numberOfFields];
        resFieldClasses = [[NSMutableArray alloc] initWithCapacity:numberOfFields];
        for( int fNum = 0; fNum < numberOfFields; ++ fNum ) {
            const char * pqfName = PQfname(myRes, fNum);
            Oid pqfType = PQftype(myRes, fNum);
            int pqfFormat = PQfformat(myRes, fNum);
            NSString * fName = [[NSString alloc] initWithCString:pqfName encoding:NSUTF8StringEncoding];
            
            PGFieldInfo * finfo = [[PGFieldInfo alloc] init];
            [finfo setFNum:fNum];
            [finfo setFFormat:pqfFormat];
            [finfo setFType:pqfType];
            [finfo setFName:fName];
            [finfo setTypeConv:[pgConn typeConvForOid:pqfType]];
            if( pqfFormat == 1 ) {
                [finfo setConv:[[finfo typeConv] sendConv]];
            } else {
                [finfo setConv:[[finfo typeConv] outConv]];
            }
            // SMKLogDebug(@"Field: %@", finfo);

            [resFieldNames addObject:fName];
            [resFieldInfo addObject:finfo];
            // for now
            [resFieldClasses addObject:[[NSObject alloc] init]];
        }
    }    
}
-(id)initWithRes:(PGresult *)res conn:(SMKDBConn_postgres *)conn
{
    self = [super init];
    if( self ) {
        myRes = res;
        pgConn = conn;
        fetchRowNum = 0;
        numberOfRows = PQntuples(myRes);
        numberOfFields = PQnfields(res);
        resFieldInfo = nil;
        resFieldNames = nil;
        resFieldClasses = nil;
        [self getResultsInfo];
    }
    return self;
}


-(SMKDBConn_postgres *)conn{
    return pgConn;
}

-(NSUInteger)numFields
{
    return numberOfFields;
}

-(NSArray *)fieldNames
{
    if( resFieldNames == nil ) {
        [self getResultsInfo];
    }
    return resFieldNames;
}

-(NSArray *)fieldTypes
{
    if( resFieldClasses == nil ) {
        [self getResultsInfo];
    }
    return resFieldClasses;
}

-(NSMutableDictionary *)fetchRowDict
{
    if( fetchRowNum < PQntuples(myRes) ) {
        NSMutableDictionary * rec = [[NSMutableDictionary alloc] 
                                     initWithCapacity:numberOfFields];

        PgConvArgs * convArgs = [[PgConvArgs alloc]init];
        for( PGFieldInfo * info in resFieldInfo ) {

            [convArgs setDataLen:PQgetlength(myRes, fetchRowNum, [info fNum])];
            [convArgs setData:PQgetvalue(myRes, fetchRowNum, [info fNum])];
            [convArgs setIsNull:PQgetisnull(myRes, fetchRowNum, [info fNum])];
            
            if( [convArgs isNull] || [convArgs dataLen] == 0 ) {
                [rec setObject:[[SMKDBNull alloc]init] forKey:[info fName]];
            } else {
                NSObject * objVal = [[info conv] conv:convArgs];
                [rec setObject:objVal forKey:[info fName]];
            }
        }
        ++ fetchRowNum;
        return rec;
    } else {
        resFieldNames = nil;
        resFieldClasses = nil;
        resFieldInfo = nil;
        return nil;
    }
}
-(NSMutableArray *)fetchRowArray
{
    if( fetchRowNum < PQntuples(myRes) ) {
        
        NSMutableArray * rec = [[NSMutableArray alloc] 
                                initWithCapacity:[resFieldInfo count]];
        PgConvArgs * convArgs = [[PgConvArgs alloc]init];
        for( PGFieldInfo * info in resFieldInfo ) {
            
            [convArgs setDataLen:PQgetlength(myRes, fetchRowNum, [info fNum])];
            [convArgs setData:PQgetvalue(myRes, fetchRowNum, [info fNum])];
            [convArgs setIsNull:PQgetisnull(myRes, fetchRowNum, [info fNum])];
            
            
            if( [convArgs isNull] || [convArgs dataLen] == 0 ) {
                [rec addObject:[[SMKDBNull alloc]init]];
            } else {
                NSObject * objVal = [[info conv] conv:convArgs];
                [rec addObject:objVal];
            }
        }
        ++ fetchRowNum;
        return rec;
    } else {
        resFieldNames = nil;
        resFieldClasses = nil;
        resFieldInfo = nil;
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
        [desc appendFormat:@"  %@\n"];
    }
    return desc;
}


-(void)dealloc
{
    if( myRes ) {
        PQclear( myRes );
        myRes = NULL;
    }
}
@end
