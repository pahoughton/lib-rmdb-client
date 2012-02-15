/**
 File:		SMKDBResults.h
 Project:	SMKDB 
 Desc:
 
 Notes:
 
 Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
 Created:     02/02/2012 04:36
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

@protocol SMKDBConn;
@protocol SMKDBRecProcDict;
@protocol SMKDBRecProcArray;

@protocol SMKDBResults <NSObject>

-(id <SMKDBConn>)conn;

-(NSUInteger)numFields;
-(NSArray *)fieldNames;
-(NSArray *)fieldTypes;
/*
 Each objectis a NSDictionary with the following keys:
   @"name"
   @"class"
   @"length"

-(NSArray *)fieldInfo;
*/

-(NSMutableDictionary *)fetchRowDict;
-(NSMutableArray *)fetchRowArray;

@end
