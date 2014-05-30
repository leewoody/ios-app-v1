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

- (void)testHomeFeedURL_domainWithHTTP_correctFeedURL
{
	self.settings.wallabagURL = [NSURL URLWithString:@"http://example.com/"];
	self.settings.userID = 1;
	self.settings.apiToken = @"abc123";
	
	NSString *expectedResult = @"http://example.com/index.php?feed&type=home&user_id=1&token=abc123";
	
	XCTAssertNotNil([self.settings getHomeFeedURL]);
	
	NSString *resultString = [self.settings getHomeFeedURL].absoluteString;
	XCTAssert([expectedResult isEqualToString:resultString], @"Expected: %@ Got: %@", expectedResult, resultString);
}

- (void)testHomeFeedURL_domainWithHTTPS_correctFeedURL
{
	self.settings.wallabagURL = [NSURL URLWithString:@"https://example.com/"];
	self.settings.userID = 1;
	self.settings.apiToken = @"abc123";
	
	NSString *expectedResult = @"https://example.com/index.php?feed&type=home&user_id=1&token=abc123";
	
	XCTAssertNotNil([self.settings getHomeFeedURL]);
	
	NSString *resultString = [self.settings getHomeFeedURL].absoluteString;
	XCTAssert([expectedResult isEqualToString:resultString], @"Expected: %@ Got: %@", expectedResult, resultString);
}

- (void)testHomeFeedURL_withTrailingSlashInBaseURL_correctFeedURL
{
	self.settings.wallabagURL = [NSURL URLWithString:@"https://example.com/wallabag/"];
	self.settings.userID = 1;
	self.settings.apiToken = @"abc123";
	
	NSString *expectedResult = @"https://example.com/wallabag/index.php?feed&type=home&user_id=1&token=abc123";
	
	XCTAssertNotNil([self.settings getHomeFeedURL]);
	
	NSString *resultString = [self.settings getHomeFeedURL].absoluteString;
	XCTAssert([expectedResult isEqualToString:resultString], @"Expected: %@ Got: %@", expectedResult, resultString);
}

- (void)testHomeFeedURL_withoutTrailingSlashInBaseURL_correctFeedURL
{
	self.settings.wallabagURL = [NSURL URLWithString:@"https://example.com/wallabag"];
	self.settings.userID = 1;
	self.settings.apiToken = @"abc123";
	
	NSString *expectedResult = @"https://example.com/wallabag/index.php?feed&type=home&user_id=1&token=abc123";
	
	XCTAssertNotNil([self.settings getHomeFeedURL]);
	
	NSString *resultString = [self.settings getHomeFeedURL].absoluteString;
	XCTAssert([expectedResult isEqualToString:resultString], @"Expected: %@ Got: %@", expectedResult, resultString);
}

- (void)testHomeFeedURL_subdomainWithTrailingSlash_correctFeedURL
{
	self.settings.wallabagURL = [NSURL URLWithString:@"https://wallabag.example.com/"];
	self.settings.userID = 1;
	self.settings.apiToken = @"abc123";
	
	NSString *expectedResult = @"https://wallabag.example.com/index.php?feed&type=home&user_id=1&token=abc123";
	
	XCTAssertNotNil([self.settings getHomeFeedURL]);
	
	NSString *resultString = [self.settings getHomeFeedURL].absoluteString;
	XCTAssert([expectedResult isEqualToString:resultString], @"Expected: %@ Got: %@", expectedResult, resultString);
}

- (void)testHomeFeedURL_subdomainWithoutTrailingSlash_correctFeedURL
{
	self.settings.wallabagURL = [NSURL URLWithString:@"https://wallabag.example.com"];
	self.settings.userID = 1;
	self.settings.apiToken = @"abc123";
	
	NSString *expectedResult = @"https://wallabag.example.com/index.php?feed&type=home&user_id=1&token=abc123";
	
	XCTAssertNotNil([self.settings getHomeFeedURL]);
	
	NSString *resultString = [self.settings getHomeFeedURL].absoluteString;
	XCTAssert([expectedResult isEqualToString:resultString], @"Expected: %@ Got: %@", expectedResult, resultString);
}

- (void)testHomeFeedURL_domainWithTrailingSlash_correctFeedURL
{
	self.settings.wallabagURL = [NSURL URLWithString:@"https://wallabag.com/"];
	self.settings.userID = 1;
	self.settings.apiToken = @"abc123";
	
	NSString *expectedResult = @"https://wallabag.com/index.php?feed&type=home&user_id=1&token=abc123";
	
	XCTAssertNotNil([self.settings getHomeFeedURL]);
	
	NSString *resultString = [self.settings getHomeFeedURL].absoluteString;
	XCTAssert([expectedResult isEqualToString:resultString], @"Expected: %@ Got: %@", expectedResult, resultString);
}

- (void)testHomeFeedURL_domainWithoutTrailingSlash_correctFeedURL
{
	self.settings.wallabagURL = [NSURL URLWithString:@"https://wallabag.com"];
	self.settings.userID = 1;
	self.settings.apiToken = @"abc123";
	
	NSString *expectedResult = @"https://wallabag.com/index.php?feed&type=home&user_id=1&token=abc123";
	
	XCTAssertNotNil([self.settings getHomeFeedURL]);
	
	NSString *resultString = [self.settings getHomeFeedURL].absoluteString;
	XCTAssert([expectedResult isEqualToString:resultString], @"Expected: %@ Got: %@", expectedResult, resultString);
}

@end
