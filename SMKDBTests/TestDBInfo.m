//
//  TestDBInfo.m
//  SMKDB
//
//  Created by Paul Houghton on 2/6/12.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "TestDBInfo.h"

@implementation TestDBInfo
-(enum SMKDB_TYPE)dbType
{
    return DB_MySql;
}

-(NSString *)dbHost
{
    return @"localhost";
}
-(unsigned int)dbPort
{
    return 0;
}
-(NSString *)dbUser
{
    return @"test";
}
-(NSString *)dbPass
{
    return @"test";
}
-(NSString *)dbDatabase
{
    return @"test";
}
-(NSString *)dbApp
{
    return @"SMKDBUnitTest";
}
-(BOOL)recProcOnMainTread
{
    return TRUE;
}

@end
