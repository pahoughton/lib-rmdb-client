/**
 File:		SMKDBTests.m
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

#import "SMKDBTests.h"
#import "SMKDB.h"
#import "TestDBInfo.h"
#import <SMKLogger.h>

@interface TestDataRec : NSObject
@property (retain) NSString * filename;
@property (retain) NSDate * fileMod;
@property (retain) NSData * fileModTz;
@property (assign) NSUInteger fileSize;
@property (retain) NSData * imageData;
@property (assign) NSUInteger xres;
@property (assign) NSUInteger yres;
@property (assign) double dVal;
@property (retain) NSDecimalNumber * num;

@end

@implementation TestDataRec
@synthesize filename;
@synthesize fileMod;
@synthesize fileModTz;
@synthesize fileSize;
@synthesize imageData;
@synthesize xres;
@synthesize yres;
@synthesize dVal;
@synthesize num;

@end

@implementation SMKDBTests
@synthesize srcDataArray;
@synthesize curRecNum;
@synthesize resultsDone;

- (void)setUp
{
    [super setUp];
    resultsDone = FALSE;
    
    // a bit of SMKLogger work
    SMKLogger * lgr = [SMKLogger appLogger];
    SMKLogger * tee = [[SMKLogger alloc] initToStderr];
    [lgr setTeeLogger:tee];
    SMKLogError(@"Test tee logging now on");
    [SMKDBConnMgr setDefaultInfoProvider:[[TestDBInfo alloc] init]];
    srcDataArray = [[NSMutableArray alloc] init];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

-(void) insertImages
{
    id <SMKDBConn> db;
    
    @try {
        db = [SMKDBConnMgr getNewDbConn];
        // clean out the table
        [db queryBool:@"delete from test"];
        [db commit];
    }
    
    @catch (NSException * excpt) {
        SMKLogExcept(excpt);
        STFail(@"conn exception: %@", excpt);
        return; // cant test w/o a connection
    }
    
    // load all the images from /Library/Desktop Pictures
    NSFileManager * fm = [NSFileManager defaultManager];
    
    NSString * dir = @"/Library/Desktop Pictures";
    NSError * err;
    
    NSArray *content = [fm contentsOfDirectoryAtPath:dir error:&err];
    STAssertNotNil(content, @"No pictures in %@ error %@", dir, err);
    
    SMKLogDebug(@"files found: %lu in %@", [content count],dir);
     
    for (int i = 0; i < [content count]; ++i) {
        NSString * fn = [content objectAtIndex:i];
        if ([fn characterAtIndex:0] == '.') {
            continue;
        }
        TestDataRec * dataRec = [[TestDataRec alloc] init];
        dataRec.filename  = [dir stringByAppendingPathComponent:fn];
        
        NSDictionary * fnAttrs = [fm attributesOfItemAtPath:dataRec.filename 
                                                      error:nil];
        if( [[fnAttrs fileType] isEqualToString:NSFileTypeDirectory] ) {
            continue;
        }
        dataRec.imageData = [[NSData alloc] 
                             initWithContentsOfFile:dataRec.filename];
      
        // NSDate
        // FIXME really don't want to REQUIRE cocoa at this point - just dealing.
        NSImage * img = [[NSImage alloc] initWithData:dataRec.imageData];
        NSSize imgSize = [img size];
        dataRec.xres = imgSize.width;
        dataRec.yres = imgSize.height;
        dataRec.fileMod = [fnAttrs fileModificationDate];
        dataRec.fileSize = [fnAttrs fileSize];
        dataRec.dVal = dataRec.fileSize + [dataRec.fileMod timeIntervalSinceReferenceDate] + 0.52345;
        dataRec.num = [NSDecimalNumber decimalNumberWithString:@"125743.232"];
        STAssertEquals( [dataRec.imageData length],
                       dataRec.fileSize, 
                       @"image data size (%lu) <> file size (%lu)", 
                       [dataRec.imageData length],
                       dataRec.fileSize );
        
        // THE Acutall Test :)
        @try {
            if( ! [db queryBoolFormat:
                   @"insert into test ("
                   "test_vchar, test_date, test_timestamp, "
                   "test_xres, test_yres, test_double, test_numeric, test_blob "
                   ") values ("
                   "%@, %@, %@, %lu, %lu, %lf, %@, %@ )",
                   [db q:dataRec.filename],
                   [db q:dataRec.fileMod],
                   [db q:dataRec.fileMod],
                   dataRec.xres,
                   dataRec.yres,
                   dataRec.dVal,
                   dataRec.num,
                   [db quote:dataRec.imageData]] ) {
                STFail(@"ins error: %@", [db errorMessage]);
            }
            
        }
        @catch (NSException *exception) {
            SMKLogExcept(exception);
            STFail(@"insert failed: %@",exception );
            break;
        }               
        // fix tz date;
        dataRec.fileModTz = [dataRec.fileMod dateByAddingTimeInterval:(60*60*-6)];
        [srcDataArray addObject:dataRec];

    }   
    SMKLogDebug(@"Added %lu rows to test (I hope)", [srcDataArray count]);
}

-(void) testRecProc:(NSDictionary *)rec
{
    // SMKLogDebug(@"rec: %@", rec);
    if( rec != nil ) {
        TestDataRec * curData = [srcDataArray objectAtIndex:curRecNum];
        ++ curRecNum; 
        SMKLogDebug(@"Rec vals\n"
                    "       vchar %@\n"
                    "        date %@\n"
                    "   timestamp %@\n"
                    "        xres %@\n"
                    "        yres %@\n"
                    "      double %@\n"
                    "         num %@\n", 
                    [rec valueForKey:@"test_vchar"],
                    [rec valueForKey:@"test_date"],
                    [rec valueForKey:@"test_timestamp"],
                    [rec valueForKey:@"test_xres"],
                    [rec valueForKey:@"test_yres"],
                    [rec valueForKey:@"test_double"],
                    [rec valueForKey:@"test_numeric"] );
        
#define TEST_REC( _k, _v )			\
STAssertEqualObjects([rec valueForKey:_k],	\
                     _v,		        \
                     @"rec %lu field: %@ - %@ <> %@",	\
                     curRecNum,			\
                     _k,			\
                    [rec valueForKey:_k],	\
                    _v)
        
        TEST_REC(@"test_vchar", curData.filename );
        TEST_REC(@"test_date", curData.fileMod);
        TEST_REC(@"test_timestamp", curData.fileModTz);
        TEST_REC(@"test_xres", [[NSNumber numberWithUnsignedInteger:curData.xres] 
                                stringValue]);
        TEST_REC(@"test_yres", [[NSNumber numberWithUnsignedInteger:curData.yres] 
                                stringValue]);
        NSData * recBlob = [rec valueForKey:@"test_blob"];
        if( ! [recBlob isEqualToData:curData.imageData] ) {
            SMKLogError(@"blob diff - size: %lu <> %lu", 
                        [recBlob length], 
                        [ curData.imageData length] );
            STAssertTrue(FALSE, @"blobs different");
        }
    } else {
        resultsDone = TRUE;
        SMKLogDebug(@"verified %lu records", curRecNum);
        STAssertEquals(curRecNum, [srcDataArray count], 
                       @"diff num recs: %lu <> %lu", 
                       curRecNum,
                       [srcDataArray count]);
    }
}

-(void) retrieveImages
{
    // now Lets get it back and compare
  self.curRecNum = 0;
  SEL rpSel = @selector(testRecProc:);
  SMKLogDebug(@"test self %@ proc sel %p", self, rpSel);
  /*
    [SMKDBConnMgr fetchAllRowsDictMtObj:self 
                                   proc:rpSel
                                    sql:
     @"select test_id, test_vchar, test_date, test_timestamp, "
     "test_xres, test_yres, test_double, test_numeric, test_blob "
     "from test order by test_id"];
   */
}

- (void)testExample
{
  id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
  id <SMKDBResults> rslt;
  rslt = [db query:@"SELECT cast( '-2 day' as interval )"];
  NSArray * rec = [rslt fetchRowArray];
  SMKDBInterval * val =[rec objectAtIndex:0];
  NSLog(@"val  %@", val);
  SMKDBInterval * test = [[SMKDBInterval alloc]init];
  [test setWithString:@" 1 yr 2 mons 3 days 03:10:05"];
  STAssertEquals(test.months,  14,@"months");
  STAssertEquals(test.days,     3,@"days");
  STAssertEquals(test.seconds, (3*60*60)+(10*60)+5.0,@"secs");
  NSLog(@"test: %@",test);
  
  [test setWithString:@"23:05"];
  STAssertEquals(test.months,   0,@"months");
  STAssertEquals(test.days,     0,@"days");
  STAssertEquals(test.seconds, (23*60)+5.0,@"secs");
  NSLog(@"test: %@",test);
  
  [test setSeconds:35.23576];
  NSLog(@"test: %@",test);
  
  /*
    [self insertImages];
    [self retrieveImages];

    int maxLoops = 12; // i.e. 1 min
    for( int l = 0; l < maxLoops && ! resultsDone; ++ l ) {
        SMKLogDebug(@"done yet? %d", l );
        NSDate *fiveSecs = [NSDate dateWithTimeIntervalSinceNow:5.0];
        [[NSRunLoop currentRunLoop] runUntilDate:fiveSecs];
    }
    STAssertTrue(resultsDone, @"Not done yet???? recs %lu", curRecNum);
   */
}

@end
