//
//  ZSDataFetcher.h
//
//	Copyright 2011 Zoosk, Inc.
//
//	Licensed under the Apache License, Version 2.0 (the "License");
//	you may not use this file except in compliance with the License.
//	You may obtain a copy of the License at
//
//	http://www.apache.org/licenses/LICENSE-2.0
//
//	Unless required by applicable law or agreed to in writing, software
//	distributed under the License is distributed on an "AS IS" BASIS,
//	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//	See the License for the specific language governing permissions and
//	limitations under the License.
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

/**
 * Returns the default data fetcher for the current thread.
 * One default ZSDataFetcher will be lazily created per thread.
 *
 * @return	The current thread's default data fetcher.
 */
+ (ZSDataFetcher *)defaultDataFetcher;

- (void)fetchURL:(NSURL *)aURL forDelegate:(id<ZSDataFetcherDelegate>)aDelegate;
- (void)fetchRequest:(NSURLRequest *)aURLRequest forDelegate:(id<ZSDataFetcherDelegate>)aDelegate;
- (void)removeDelegate:(id<ZSDataFetcherDelegate>)aDelegate;

@end
