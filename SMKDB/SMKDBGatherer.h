/**
  File:		SMKDBGatherer.h
  Project:	SMKDB
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/8/12  3:56 AM
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
#import "SMKDB.h"

@interface SMKDBGatherCollector : NSObject 
@property (retain) NSObject *      recProcObj;
@property (assign) SEL             recProcSel;
@property (retain) id <SMKDBConn>  db;
@property (retain) NSString *      sql;

-(id)initWithConn:(id <SMKDBConn>)conn
              sql:(NSString *)querySql
          procObj:(NSObject *)obj
          procSel:(SEL)objSel;

-(void)procQuery;

@end

@interface SMKDBGathCollDict : SMKDBGatherCollector
-(void)procQuery;
@end

@interface SMKDBGathCollArray : SMKDBGatherCollector
-(void)procQuery;
@end

@interface SMKDBGathCollMtDict : SMKDBGatherCollector
-(void)procQuery;
@end

@interface SMKDBGathCollMtArray : SMKDBGatherCollector
-(void)procQuery;
@end

@interface SMKDBGatherer : NSOperation
@property (retain,readonly) SMKDBGatherCollector * coll;

enum SMKDBResultsType {
    SMKDB_REC_ARRAY,
    SMKDB_REC_DICT
};

-(id)initWithConn:(id <SMKDBConn>)conn
              sql:(NSString *)querySql
          recType:(enum SMKDBResultsType)type
   procMainThread:(BOOL)onMt
          procObj:(NSObject *)obj
          procSel:(SEL)objSel;

-(void)main;

@end
