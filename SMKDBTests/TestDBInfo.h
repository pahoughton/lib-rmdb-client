//
//  TestDBInfo.h
//  SMKDB
//
//  Created by Paul Houghton on 2/6/12.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

//  Logic unit tests contain unit test code that is designed to be linked into an independent test executable.

#import "SMKDB.h"

@interface TestDBInfo : NSObject <SMKDBConnInfo>
-(enum SMKDB_TYPE)dbType;

-(NSString *)dbHost;
-(unsigned int)dbPort;
-(NSString *)dbUser;
-(NSString *)dbPass;
-(NSString *)dbDatabase;
-(NSString *)dbApp;
-(BOOL)recProcOnMainTread;

@end
