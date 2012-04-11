/**
  File:		SMKDBNull.h
  Project:	SMKDB
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton  ___EMAIL___ <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/13/12  10:08 AM
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

#define SMK_NULL2NIL( _o_ ) (_o_ == [NSNull null] ? nil : _o_)

#define SMKisNULL( _o_ ) \
(_o_ == nil \
 || (NSNull*)_o_ == [NSNull null] \
 || ([_o_ isKindOfClass:[NSString class]] && [(NSString *)_o_ length] == 0) )

@interface SMKDBNull : NSNull

@end
