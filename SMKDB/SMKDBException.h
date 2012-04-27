/**
 File:		SMKDBException.h
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
#import <SMKLogger.h>
#define SMKDBExcept(_fmt_,...)     [SMKDBException raise:@"SMKDB" format:_fmt_,##__VA_ARGS__]

@interface SMKDBException : NSException

- (id)initWithName:(NSString *)aName 
            reason:(NSString *)aReason 
          userInfo:(NSDictionary *)aUserInfo;

@end
