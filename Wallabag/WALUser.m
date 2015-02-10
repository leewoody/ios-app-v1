//
//  WALUser.m
//  Wallabag
//
//  Created by Kevin Meyer on 10/02/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import "WALUser.h"
#import "NSString+Hashes.h"
#import <CommonCrypto/CommonDigest.h>

@interface WALUser ()

@property (readwrite, strong) NSString *passwordHashed;
@property (strong) NSDateFormatter *dateFormatter;

@property (strong) NSString *nonce;
@property (strong) NSString *timestamp;
@end

@implementation WALUser

#pragma mark - 

- (instancetype)init {
	if (self = [super init]) {
		self.dateFormatter = [[NSDateFormatter alloc] init];
		self.dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
		self.dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
		self.dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
	}
	return self;
}

- (instancetype)initWithUsername:(NSString *)username andHashedPassword:(NSString *)passwordHashed {
	if (self = [self init]) {
		self.username = username;
		self.passwordHashed = passwordHashed;
	}
	return self;
}

#pragma mark - WSSE

- (void)generateWSSE {
	self.timestamp = [self generateTimestamp];
	self.nonce = [self generateNonce];
}

- (void)generateWSSEWithNonce:(NSString *)nonce andTimestamp:(NSString *)timestamp {
	self.nonce = nonce ? : [self generateNonce];
	self.timestamp = timestamp ? : [self generateTimestamp];
}

#pragma mark - WSSE HTTP Header

- (NSString *)wsseHeaderKey {
	return @"X-WSSE";
}

- (NSString *)wsseHeaderValue {
	if (!self.nonce || !self.timestamp) {
		[self generateWSSE];
	}

	NSString *digest64 = [self generateDigestWithNonce:self.nonce andTimestamp:self.timestamp];
	
	NSMutableString *headerValue = [NSMutableString string];
	[headerValue appendFormat:@"UsernameToken Username=\"%@\", ", self.username];
	[headerValue appendFormat:@"PasswordDigest=\"%@\", ", digest64];
	[headerValue appendFormat:@"Nonce=\"%@\", ", [self.nonce stringByEncodingBase64]];
	[headerValue appendFormat:@"Created=\"%@\"", self.timestamp];
	
	return headerValue;
}

#pragma mark - WSSE Generation

- (NSString *)generateDigestWithNonce:(NSString *) nonce andTimestamp:(NSString *) timestamp {
	NSString *password = self.passwordHashed;
	
	NSString *combined = [NSString stringWithFormat:@"%@%@%@", nonce, timestamp, password];
	NSData *data = [combined dataByHashingWithSHA1];
	return [data base64EncodedStringWithOptions:0];
}

- (NSString *)generateNonce {
	// Using UUID as secure random
	return [[NSUUID UUID] UUIDString];
}

- (NSString *)generateTimestamp {
	return [self.dateFormatter stringFromDate:[NSDate date]];
}

@end
