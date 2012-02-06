//
//  SMKDBConn_mysql.h
//  SMKDB
//
//  Created by Paul Houghton on 2/5/12.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMKDBConn.h"
#import <mysql.h>
#import "SMKDBResults_mysql.h"
#import "SMKDBResults_mysql_stmt.h"

@interface SMKDBConn_mysql : NSObject <SMKDBConn>
@property (assign) MYSQL * my;
@property (assign) BOOL doExcept;
@property (assign) int lastErrorId;

// noted the default init will throw Exceptions
-(id)initWithDoExceptions:(BOOL)throwExceptions;

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

-(NSString *)quote:(NSString *)strVal;
-(NSString *)quoteNum:(NSNumber *)numVal;

-(SMKDBResults_mysql *)query:(NSString *)sql;
// i.e. @"select %s,%d,%@",cstr,int,obj
-(SMKDBResults_mysql *)queryFormat:(NSString *)sql
                      arguments:(va_list)args;
-(SMKDBResults_mysql *)queryFormat:(NSString *)sql,...;
// i.e. @"select a where b = $1";
-(id <SMKDBResults>)queryParams:(NSString *)sql 
                         params:(NSArray *)params;

// these are for update / insert i.e. no results expected or wanted
-(BOOL)queryBool:(NSString *)sql;
// i.e. @"select %s,%d,%@",cstr,int,obj
-(BOOL)queryBoolFormat:(NSString *)sql
             arguments:(va_list)args;
-(BOOL)queryBoolFormat:(NSString *)sql,...;
// i.e. @"select a where b = $1";
-(BOOL)queryBoolParams:(NSString *)sql params:(NSArray *)params;

// transaction processing
-(void)beginTransaction;
-(void)rollback;
-(void)commit;


@end
