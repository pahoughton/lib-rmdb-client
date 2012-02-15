/**
 File:		SMKDBConn.h
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

@protocol SMKDBResults;

@protocol SMKDBConn <NSObject>

// noted the default init will throw Exceptions
-(id)initWithDoExceptions:(BOOL)throwExceptions;

-(void) setBinResults:(BOOL)tf;

-(BOOL)connect:(const char *)cHost 
          port:(unsigned int)port 
         cUser:(const char *)usr 
         cPass:(const char *)pass
     cDatabase:(const char *)db
      cAppName:(const char *)appName;

-(BOOL)connect:(NSString *)host 
          port:(unsigned int)port 
          user:(NSString *)user 
      password:(NSString *)pass
      database:(NSString *)database
       appName:(NSString *)appName;

-(NSString *)errorMessage;

// q is short name quote
-(NSString *)q:(NSObject *) val;
-(NSString *)quote:(NSObject *) val;

-(id <SMKDBResults>)query:(NSString *)sql;
// i.e. @"select %s,%d,%@",cstr,int,obj
-(id <SMKDBResults>)queryFormat:(NSString *)sql
                      arguments:(va_list)args;
-(id <SMKDBResults>)queryFormat:(NSString *)sql,... NS_FORMAT_FUNCTION(1,2);
// i.e. @"select a where b = $1";
-(id <SMKDBResults>)queryParams:(NSString *)sql params:(NSArray *)params;

// these are for update / insert i.e. no results expected or wanted
-(BOOL)queryBool:(NSString *)sql;
// i.e. @"select %s,%d,%@",cstr,int,obj
-(BOOL)queryBoolFormat:(NSString *)sql
             arguments:(va_list)args;
-(BOOL)queryBoolFormat:(NSString *)sql,... NS_FORMAT_FUNCTION(1,2);
// i.e. @"select a where b = $1";
-(BOOL)queryBoolParams:(NSString *)sql params:(NSArray *)params;

// transaction processing
-(void)beginTransaction;
-(void)rollback;
-(void)commit;

@end