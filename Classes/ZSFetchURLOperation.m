//
//  ZSFetchURLOperation.m
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

#import "ZSFetchURLOperation.h"


@interface ZSFetchURLOperation ()

- (void)notifyDelegateDidFetchData:(NSData *)aData;
- (void)notifyDelegateDidFailWithStatusCode:(NSNumber *)aCode;

@end

@implementation ZSFetchURLOperation

@synthesize delegate, url;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
	[url release];
	
	[super dealloc];
}

- (void)main {
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.url
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:30];
	
	NSError *rpcResponseError = nil;
	NSURLResponse *rpcResponse = nil;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&rpcResponse error:&rpcResponseError];
	
	if (responseData) {
		[self notifyDelegateDidFetchData:responseData];
	} else {
		NSInteger statusCode = 400;
		if ([rpcResponse respondsToSelector:@selector(statusCode)]) {
			statusCode = [(id)rpcResponse statusCode];
		}
		[self notifyDelegateDidFailWithStatusCode:[NSNumber numberWithInteger:statusCode]];
	}
}
		 
- (void)notifyDelegateDidFetchData:(NSData *)aData {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(notifyDelegateDidFetchData:) withObject:aData waitUntilDone:NO];
		return;
	}
	
	[self.delegate didFetchData:aData forURL:self.url];
}

- (void)notifyDelegateDidFailWithStatusCode:(NSNumber *)aCode {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(notifyDelegateDidFailWithStatusCode:) withObject:aCode waitUntilDone:NO];
		return;
	}
	
	[self.delegate didFailFetchForURL:self.url withStatusCode:[aCode integerValue]];
}

@end
