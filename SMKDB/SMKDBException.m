/**
 File:		SMKDBException.m
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

#import "SMKDBException.h"
#import <SMKLogger.h>

@implementation SMKDBException

- (id)initWithName:(NSString *)aName 
            reason:(NSString *)aReason 
          userInfo:(NSDictionary *)aUserInfo
{
    // hack in my SMKDB tag
    NSString *myReason = 
    [[NSMutableString alloc]initWithFormat:@"SMKDB %@", aReason];
    self = [super initWithName:aName reason:myReason userInfo:aUserInfo];
    return self;
    
}

@end
