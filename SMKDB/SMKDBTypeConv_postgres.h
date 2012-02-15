/**
  File:		SMKDBTypeConv_postgres.h
  Project:	SMKDB
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton  ___EMAIL___ <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/11/12  3:41 AM
  Copyright:    Copyright (c) 2012 Secure Media Keepers.
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

@interface PgConvArgs : NSObject
@property (assign) const char * data;
@property (assign) int dataLen;
@property (assign) int isNull;
@end

@protocol PgConverter <NSObject>
-(NSObject *)conv:(PgConvArgs *)convArgs;
@end

@interface SMKDBTypeConv_postgres : NSObject
@property (retain) NSString * tName;
@property (retain) NSString * tSend;
@property (retain) NSString * tOutput;
@property (assign) id <PgConverter> sendConv;
@property (assign) id <PgConverter> outConv;

-(id)initTypeConv:(NSString *)name 
            tSend:(NSString *)snd 
             tOut:(NSString *)tOut;

-(NSString *) description;

@end
