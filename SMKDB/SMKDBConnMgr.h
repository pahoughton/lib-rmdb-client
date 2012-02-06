//
//  SMKDBConnMgr.h
//  SMKDB
//
//  Created by Paul Houghton on 2/5/12.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMKDB.h"
@interface SMKDBConnMgr : NSObject
@property (retain) id <SMKDBConnInfo> info;

+(void) setInfoProvider:(id <SMKDBConnInfo>)infoObj;

+(id <SMKDBConn>)conn;

+(void)fetchAllRowsDictMtObj:(id)obj 
                        proc:(SEL)sel
                         sql:(NSString *)sql,...;

+(void)fetchAllRowsArrayMtObj:(id)obj 
                         proc:(SEL)sel
                          sql:(NSString *)sql,...;


// use as an 'instance
-(id) initWithInfo:(id <SMKDBConnInfo>)info;
-(id <SMKDBConn>)conn;
-(void)fetchAllRowsDictMtObj:(id)obj 
                        proc:(SEL)sel
                         sql:(NSString *)sql,...;

-(void)fetchAllRowsArrayMtObj:(id)obj 
                         proc:(SEL)sel
                          sql:(NSString *)sql,...;
@end
