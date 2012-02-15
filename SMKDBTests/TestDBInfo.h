/**
 File:		TestDBInfo.h
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
