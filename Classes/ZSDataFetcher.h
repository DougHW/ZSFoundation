//
//  ZSDataFetcher.h
//  ZSFoundation
//
//  Created by Doug Wehmeier on 3/23/11.
//  Copyright 2011 Zoosk. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ZSDataFetcherDelegate <NSObject>

- (void)didFetchData:(NSData *)aData forURL:(NSURL *)aURL;
- (void)didFailFetchForURL:(NSURL *)aURL withStatusCode:(NSInteger)aCode;

@end

@interface ZSDataFetcher : NSObject {
@private
	NSMutableSet		*connections;
}

+ (ZSDataFetcher *)defaultDataFetcher;

- (void)fetchURL:(NSURL *)aURL forDelegate:(id<ZSDataFetcherDelegate>)aDelegate;
- (void)fetchRequest:(NSURLRequest *)aURLRequest forDelegate:(id<ZSDataFetcherDelegate>)aDelegate;
- (void)removeDelegate:(id<ZSDataFetcherDelegate>)aDelegate;

@end
