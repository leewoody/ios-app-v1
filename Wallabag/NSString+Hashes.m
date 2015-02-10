//
//  NSString+Hashes.m
//  Wallabag
//
//  Created by Kevin Meyer on 10/02/15.
//  Copyright (c) 2015 Wallabag. All rights reserved.
//

#import "NSString+Hashes.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Hashes)

- (NSString *)stringByHashingWithSHA1 {
	NSData *data = [self dataByHashingWithSHA1];
	const unsigned char *dataBuffer = data.bytes;
	
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
		[output appendFormat:@"%02x", dataBuffer[i]];
	}
 
	return output;
}

- (NSData *)dataByHashingWithSHA1 {
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	
	CC_SHA1(data.bytes, (unsigned int) data.length, digest);
	return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}

#pragma mark - Base64

- (NSString *)stringByEncodingBase64 {
	NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
	return [plainData base64EncodedStringWithOptions:0];
}

- (NSString *)stringByDecodingBase64 {
	NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:self options:0];
	return [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
}

@end
