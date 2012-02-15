/**
 File:		TestDBInfo.m
 Project:	SMKDB 
 Desc:
 
 
 Notes:
 
 Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
 Created:     02/06/2012 04:36
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
#import "TestDBInfo.h"

@implementation TestDBInfo
-(enum SMKDB_TYPE)dbType
{
    return DB_Postgess;
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
