/**
 File:		SMKDBTests.h
 Project:	SMKDB 
 Desc:
 
 
 Notes:
 
 Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
 Created:     02/03/2012 04:36
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
//
//  SMKDBTests.h
//  SMKDBTests
//
//  Created by Paul Houghton on 2/3/12.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface SMKDBTests : SenTestCase
@property (retain) NSMutableArray * srcDataArray;
@property (assign) NSUInteger curRecNum;
@property (assign) BOOL resultsDone;
@end
