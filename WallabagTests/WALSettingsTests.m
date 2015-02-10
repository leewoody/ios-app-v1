//
//  WALSettingsTests.m
//  Wallabag
//
//  Created by Kevin Meyer on 30.05.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WALSettings.h"

@interface WALSettingsTests : XCTestCase
@property (strong) WALSettings* settings;
@end

@implementation WALSettingsTests

- (void)setUp
{
    [super setUp];
	self.settings = [[WALSettings alloc] init];
}

- (void)tearDown
{
	self.settings = nil;
    [super tearDown];
}

- (void)testUserID {
	XCTAssert(self.settings.userID >= 0);
}

- (void)testV2 {
	XCTAssertEqual(self.settings.isVersionV2, NO);
	
	[self.settings setVersionV2:YES];
	XCTAssertEqual(self.settings.isVersionV2, YES);
	
	[self.settings setVersionV2:NO];
	XCTAssertEqual(self.settings.isVersionV2, NO);
}

- (void)testIsValidV1 {
	XCTAssertFalse(self.settings.isValid);

	[self.settings setVersionV2:NO];
	XCTAssertFalse(self.settings.isValid);

	self.settings.apiToken = @"test";
	self.settings.wallabagURL = [NSURL URLWithString:@"https://example.com/"];
	XCTAssert(self.settings.isValid);
	
	self.settings.apiToken = @"";
	XCTAssertFalse(self.settings.isValid);
	
	self.settings.apiToken = @"testToken";
	self.settings.wallabagURL = [NSURL URLWithString:@""];
	XCTAssertFalse(self.settings.isValid);
}

- (void)testIsValidV2 {
	XCTAssertFalse(self.settings.isValid);
	
	[self.settings setVersionV2:YES];
	XCTAssertFalse(self.settings.isValid);
	
	self.settings.wallabagURL = [NSURL URLWithString:@"https://example.com/"];
	XCTAssert(self.settings.isValid);
	
	self.settings.wallabagURL = [NSURL URLWithString:@""];
	XCTAssertFalse(self.settings.isValid);
}

@end
