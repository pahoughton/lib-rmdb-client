/**
 File:		SMKDBConnInfo.h
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
#import <Foundation/Foundation.h>

@protocol SMKDBConnInfo <NSObject>
enum SMKDB_TYPE {
    DB_Postgess = 0,
    DB_MySql = 1,
    DB_SqlLite = 2,
    DB_Sybase = 3,
    DB_Oracle = 4
};

-(enum SMKDB_TYPE)dbType;

-(NSString *)dbHost;
-(unsigned int)dbPort;
-(NSString *)dbUser;
-(NSString *)dbPass;
-(NSString *)dbDatabase;
-(NSString *)dbApp;
-(BOOL)recProcOnMainTread;

@end
