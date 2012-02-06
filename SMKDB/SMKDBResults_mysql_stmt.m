/**
    SMKDBResults_mysql_stmt.m
    SMKDB
  
    Created by Paul Houghton on 2/5/12.
    Copyright (c) 2012 Secure Media Keepers. All rights reserved.
  
**/

#import "SMKDBResults_mysql_stmt.h"

@implementation SMKDBResults_mysql_stmt
@synthesize stmt;
@synthesize myconn;
@synthesize resFieldNames;
@synthesize resFieldTypes;

-(id) initWithConn:(SMKDBConn_mysql *)conn statement:(MYSQL_STMT *)inStmt
{
    self = [super init];
    if( self ) {
        stmt = inStmt;
        myconn = conn;
    }
    return self;
}

-(void) dealloc
{
    if( stmt ) {
        mysql_stmt_close(stmt);
        stmt = NULL;
    }
}

-(SMKDBConn_mysql *)conn
{
    return myconn;
}

-(NSUInteger) numFields
{
    mysql_stmt_field_count(stmt);
}

-(NSArray *)fieldNames
{
    if( resFieldNames == nil ) {
        MYSQL_RES * myRes = mysql_stmt_result_metadata(stmt);
        NSUInteger numFlds = [self numFields];
        NSMutableArray * tmp = [[NSMutableArray alloc] 
                                initWithCapacity:numFlds];
        MYSQL_FIELD * resFldInfo = mysql_fetch_fields(myRes);
        
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
        MYSQL_RES * myRes = mysql_stmt_result_metadata(stmt);
        NSUInteger numFlds = [self numFields];
        NSMutableArray * tmp = [[NSMutableArray alloc] 
                                initWithCapacity:numFlds];
        MYSQL_FIELD * resFldInfo = mysql_fetch_fields(myRes);
        
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

@end
