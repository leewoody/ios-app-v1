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
@end
