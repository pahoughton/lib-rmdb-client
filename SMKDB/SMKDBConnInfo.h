/**
    SMKDBConnInfo.h
    SMKDB
  
    Created by Paul Houghton on 2/5/12.
    Copyright (c) 2012 Secure Media Keepers. All rights reserved.
  
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
