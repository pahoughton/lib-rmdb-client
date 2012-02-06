//
//  SMKDBTests.m
//  SMKDBTests
//
//  Created by Paul Houghton on 2/3/12.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "SMKDBTests.h"
#import "SMKDB.h"
#import "TestDBInfo.h"

/** Application Entry Point **/
@interface Application : NSObject
@end

@implementation Application

-(void)appEntryPoint
{
    // one time tell about the DB
}

@end

/** Some UI Class that needs DB Data **/
@interface MyUIthing : NSObject
@property (retain) NSMutableArray * myRecs;
@end

@implementation MyUIthing
@synthesize myRecs;

-(void)titleRecProc:(NSDictionary *) rec
{
    if( rec != nil ) {
        [myRecs addObject:rec];
    } else {
        // all done
        NSLog(@"received %lu records\n %@",[myRecs count],myRecs);
    }
}

-(void)grabSomeDBData:(NSNumber *)vidId
{
}
@end




@implementation SMKDBTests

- (void)setUp
{
    [super setUp];
    [SMKDBConnMgr setInfoProvider:[[TestDBInfo alloc] init]];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

-(void) testRecProc:(NSDictionary *)rec
{
    
}

- (void)testExample
{
    [SMKDBConnMgr 
     fetchAllRowsDictMtObj:self 
     proc:@selector(titleRecProc:) 
     sql:@"select test_id, test_vchar, test_date, test_timestamp "
     "from video_titles where vid_id = %@",
     vidId ];
    SMKDBConn * conn = [[SMKDBConn alloc] init];
    if( [conn connect:"localhost" 
                 port:0 
                cUser:"test" 
                cPass:"test" 
            cDatabase:"test"] ) {
        SMKDBResults * res = [conn query:
                              @"select test_id, test_vchar, test_date,test_timestamp from test"];
        NSMutableDictionary * rec;
        while ((rec = [res fetchRowDict]) ) {
            NSLog(@"Row: %@",rec);
        }
    }

    STFail(@"Unit tests are not implemented yet in SMKDBTests");
}

@end
