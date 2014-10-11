//
//  WALServerConnection.m
//  Wallabag
//
//  Created by Kevin Meyer on 30.05.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALServerConnection.h"
#import "WALArticle.h"
#import "WALSettings.h"
#import "WALArticleList.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <AFNetworking/AFURLSessionManager.h>
#import "TBXML.h"


@interface WALServerConnection ()
@property (strong) WALSettings* settings;

@property (strong) TBXML* parser;
@property (strong) WALArticleList* parser_articleList;
@property (strong) NSString* parser_currentString;
@property (strong) WALArticle* parser_currentArticle;

@property (strong) WALArticleList* oldArticleList;
@property (weak) id<WALServerConnectionDelegate> delegate;

@end

@implementation WALServerConnection

- (void) loadArticlesOfListType:(WALArticleListType) listType withSettings:(WALSettings*) settings OldArticleList:(WALArticleList*) articleList delegate:(id<WALServerConnectionDelegate>) delegate
{
	self.oldArticleList = articleList;
	self.delegate = delegate;
	self.settings = settings;
	
	[self downloadAndStartParsingListType:listType];
}

- (void) downloadAndStartParsingListType:(WALArticleListType) listType
{
	NSString *urlString;
	
	switch (listType) {
		case WALArticleListTypeUnread:
			urlString = [self.settings getHomeFeedURL].absoluteString;
			break;
			
		case WALArticleListTypeFavorites:
			urlString = [self.settings getFavoriteFeedURL].absoluteString;
			break;
			
		case WALArticleListTypeArchive:
			urlString = [self.settings getArchiveFeedURL].absoluteString;
			break;
		}
	
	NSString *tempFile = NSTemporaryDirectory();
	tempFile = [tempFile stringByAppendingString:@"feed.xml"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:tempFile]) {
		[[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
	}
	
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
	
	manager.securityPolicy.allowInvalidCertificates = YES;

	NSURL *URL = [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	
	NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
		NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
		return [documentsDirectoryURL URLByAppendingPathComponent:@"feed.xml"];
	} completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
		if (error) {
			[self callbackWithError:error];
		} else {
			
			NSData *data = [NSData dataWithContentsOfURL:filePath ];
			NSError *parserError;
			self.parser = [[TBXML alloc] initWithXMLData:data error:&parserError];
						
			if(!parserError || self.parser.rootXMLElement) {
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
					[self parseRootElement:self.parser.rootXMLElement ofListWithType:listType];
				});
				return;
			} else {
				NSString *textData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
				textData = [NSString stringWithFormat:@"Response: %@", textData];
				NSRange stringRange = {0, MIN(textData.length, 200)};
				stringRange = [textData rangeOfComposedCharacterSequencesForRange:stringRange];
				textData = [textData substringWithRange:stringRange];
				
				if (parserError)
					textData = [NSString stringWithFormat:@"Parser Error: %@\n%@", parserError.localizedDescription, textData];
				
				NSError *errorWithResponse = [[NSError alloc] initWithDomain:@"WALError"
																		code:100
																	userInfo:@{NSLocalizedDescriptionKey: textData}];
				[self callbackWithError:errorWithResponse];
			}
		}
	}];
	[downloadTask resume];
	
}

#pragma mark - Parser

- (void) parseRootElement:(TBXMLElement*) root ofListWithType:(WALArticleListType) listType {
	
	TBXMLElement *channel = [TBXML childElementNamed:@"channel" parentElement:root];
	TBXMLElement *item = [TBXML childElementNamed:@"item" parentElement:channel];
	
	self.parser_articleList = [[WALArticleList alloc] initAsType:listType];
	
	while (item)
	{
		WALArticle *article = [[WALArticle alloc] init];
		article.title = [self stringByHtmlUnescapingString:[TBXML textForElement:[TBXML childElementNamed:@"title" parentElement:item]]];
		article.link = [NSURL URLWithString:[self stringByHtmlUnescapingString:[TBXML textForElement:[TBXML childElementNamed:@"link" parentElement:item]]]];
		[article setDateWithString:[self stringByHtmlUnescapingString:[TBXML textForElement:[TBXML childElementNamed:@"pubDate" parentElement:item]]]];
		article.content = [self stringByHtmlUnescapingString:[TBXML textForElement:[TBXML childElementNamed:@"description" parentElement:item]]];
		article.source = [NSURL URLWithString:[self stringByHtmlUnescapingString:[TBXML textForElement:[TBXML childElementNamed:@"source" parentElement:item]]]];
		
		[self mergeArticleWithOldArticles:article];
		[self.parser_articleList addArticle:article];
		article = nil;
    
		item = item->nextSibling;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.delegate serverConnection:self didFinishWithArticleList:self.parser_articleList];
		self.parser_articleList = nil;
		self.oldArticleList = nil;
		self.delegate = nil;
		self.parser = nil;
	});
}

#pragma mark -

- (void) callbackWithError:(NSError*) error
{
	[self.parser_articleList deleteCachedArticles];
	[self.delegate serverConnection:self didFinishWithError:error];
	
	self.parser_articleList = nil;
	self.oldArticleList = nil;
	self.delegate = nil;
}

- (void) mergeArticleWithOldArticles:(WALArticle*) article
{
	WALArticle *oldArticle = [self.oldArticleList getArticleWithLink:article.link];
	
	if (oldArticle)
	{
		article.archive = oldArticle.archive;
	}
}

- (NSString*) stringByHtmlUnescapingString:(NSString*) string {
	return (NSString *)CFBridgingRelease(CFXMLCreateStringByUnescapingEntities(nil ,(__bridge CFStringRef)(string) , nil));
}

// c function used from CFXMLParser.c at http://www.opensource.apple.com/source/CF/CF-550.13/CFXMLParser.c
CFStringRef CFXMLCreateStringByUnescapingEntities(CFAllocatorRef allocator, CFStringRef string, CFDictionaryRef entitiesDictionary) {
	
    CFStringInlineBuffer inlineBuf; /* use this for fast traversal of the string in question */
    CFStringRef sub;
    CFIndex lastChunkStart, length = CFStringGetLength(string);
    CFIndex i, entityStart;
    UniChar uc;
    UInt32 entity;
    int base;
    CFMutableDictionaryRef fullReplDict = entitiesDictionary ? CFDictionaryCreateMutableCopy(allocator, 0, entitiesDictionary) : CFDictionaryCreateMutable(allocator, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	
    CFDictionaryAddValue(fullReplDict, (const void *)CFSTR("amp"), (const void *)CFSTR("&"));
    CFDictionaryAddValue(fullReplDict, (const void *)CFSTR("quot"), (const void *)CFSTR("\""));
    CFDictionaryAddValue(fullReplDict, (const void *)CFSTR("lt"), (const void *)CFSTR("<"));
    CFDictionaryAddValue(fullReplDict, (const void *)CFSTR("gt"), (const void *)CFSTR(">"));
    CFDictionaryAddValue(fullReplDict, (const void *)CFSTR("apos"), (const void *)CFSTR("'"));
	
    CFStringInitInlineBuffer(string, &inlineBuf, CFRangeMake(0, length - 1));
    CFMutableStringRef newString = CFStringCreateMutable(allocator, 0);
	
    lastChunkStart = 0;
    // Scan through the string in its entirety
    for(i = 0; i < length; ) {
        uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;	// grab the next character and move i.
		
        if(uc == '&') {
            entityStart = i - 1;
            entity = 0xFFFF;	// set this to a not-Unicode character as sentinel
			// we've hit the beginning of an entity. Copy everything from lastChunkStart to this point.
            if(lastChunkStart < i - 1) {
                sub = CFStringCreateWithSubstring(allocator, string, CFRangeMake(lastChunkStart, (i - 1) - lastChunkStart));
                CFStringAppend(newString, sub);
                CFRelease(sub);
            }
			
            uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;	// grab the next character and move i.
			// Now we can process the entity reference itself
            if(uc == '#') {	// this is a numeric entity.
                base = 10;
                entity = 0;
                uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;
				
                if(uc == 'x') {	// only lowercase x allowed. Translating numeric entity as hexadecimal.
                    base = 16;
                    uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;
                }
				
                // process the provided digits 'til we're finished
                while(true) {
                    if (uc >= '0' && uc <= '9')
                        entity = entity * base + (uc-'0');
                    else if (uc >= 'a' && uc <= 'f' && base == 16)
                        entity = entity * base + (uc-'a'+10);
                    else if (uc >= 'A' && uc <= 'F' && base == 16)
                        entity = entity * base + (uc-'A'+10);
                    else break;
					
                    if (i < length) {
                        uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;
                    }
                    else
                        break;
                }
            }
			
            // Scan to the end of the entity
            while(uc != ';' && i < length) {
                uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;
            }
			
            if(0xFFFF != entity) { // it was numeric, and translated.
                // Now, output the result fo the entity
                if(entity >= 0x10000) {
                    UniChar characters[2] = { ((entity - 0x10000) >> 10) + 0xD800, ((entity - 0x10000) & 0x3ff) + 0xDC00 };
                    CFStringAppendCharacters(newString, characters, 2);
                } else {
                    UniChar character = entity;
                    CFStringAppendCharacters(newString, &character, 1);
                }
            } else {	// it wasn't numeric.
                sub = CFStringCreateWithSubstring(allocator, string, CFRangeMake(entityStart + 1, (i - entityStart - 2))); // This trims off the & and ; from the string, so we can use it against the dictionary itself.
                CFStringRef replacementString = (CFStringRef)CFDictionaryGetValue(fullReplDict, sub);
                if(replacementString) {
                    CFStringAppend(newString, replacementString);
                } else {
                    CFRelease(sub); // let the old substring go, since we didn't find it in the dictionary
                    sub =  CFStringCreateWithSubstring(allocator, string, CFRangeMake(entityStart, (i - entityStart))); // create a new one, including the & and ;
                    CFStringAppend(newString, sub); // ...and append that.
                }
                CFRelease(sub); // in either case, release the most-recent "sub"
            }
			
            // move the lastChunkStart to the beginning of the next chunk.
            lastChunkStart = i;
        }
    }
    if(lastChunkStart < length) { // we've come out of the loop, let's get the rest of the string and tack it on.
        sub = CFStringCreateWithSubstring(allocator, string, CFRangeMake(lastChunkStart, i - lastChunkStart));
        CFStringAppend(newString, sub);
        CFRelease(sub);
    }
	
    CFRelease(fullReplDict);
	
    return newString;
}


@end
