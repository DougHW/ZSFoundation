//
//  ZSDataFetcher.m
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
#import "ZSDataFetcher.h"


#define DEFAULT_DATA_FETCHER_TIMEOUT 60.0

@interface ZSDataFetcherConnection : NSObject {
@private
    NSURL				*connectionURL;
	NSURLConnection		*connection;
	NSInteger			connectionStatus;
	NSMutableData		*connectionData;
	
	/**
	 * This is a collection of pointers to delegates, wrapped in NSValues
	 */
	NSMutableSet		*connectionDelegates;
}

@property (nonatomic, retain)	NSURL				*connectionURL;
@property (nonatomic, retain)	NSURLConnection		*connection;
@property (nonatomic)			NSInteger			connectionStatus;
@property (nonatomic, retain)	NSMutableData		*connectionData;

@property (nonatomic, retain)	NSMutableSet		*connectionDelegates;

@end

@implementation ZSDataFetcherConnection

@synthesize connectionURL, connection, connectionStatus, connectionData;
@synthesize connectionDelegates;

- (id)init {
	self = [super init];
	if (self) {
		connectionData = [[NSMutableData alloc] init];
		
		connectionDelegates = [[NSMutableSet alloc] init];
	}
	return self;
}

- (void)dealloc {
	[connectionURL release];
	[connection release];
	[connectionData release];
	
	[connectionDelegates release];
	
	[super dealloc];
}

@end


@interface ZSDataFetcher ()

@property (nonatomic, retain)	NSMutableSet	*connections;

@end

@implementation ZSDataFetcher

+ (ZSDataFetcher *)defaultDataFetcher {
	ZSDataFetcher *threadDataFetcher = (ZSDataFetcher *)[[[NSThread currentThread] threadDictionary] objectForKey:@"NSThread_ZSDataFetcher"];
	
	if (!threadDataFetcher) {
		threadDataFetcher = [[[ZSDataFetcher alloc] init] autorelease];
		[[[NSThread currentThread] threadDictionary] setObject:threadDataFetcher forKey:@"NSThread_ZSDataFetcher"];
	}
	
    return threadDataFetcher;
}

@synthesize connections;

- (id)init {
	self = [super init];
	if (self) {
		connections = [[NSMutableSet alloc] init];
	}
	return self;
}

- (void)dealloc {
	[connections release];
	
	[super dealloc];
}

- (void)fetchURL:(NSURL *)aURL forDelegate:(id<ZSDataFetcherDelegate>)aDelegate {
	if (!aURL || !aDelegate) {
		// pre-condition
		return;
	}
	
	[self fetchRequest:[NSURLRequest requestWithURL:aURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:DEFAULT_DATA_FETCHER_TIMEOUT]
		   forDelegate:aDelegate];
}

- (void)fetchRequest:(NSURLRequest *)aURLRequest forDelegate:(id<ZSDataFetcherDelegate>)aDelegate {
	if (!aURLRequest || !aDelegate) {
		// pre-condition
		return;
	}
	
	// Check to see if we already have a fetcher connection to this resource going
	ZSDataFetcherConnection *newFetcherConnection = nil;
	for (ZSDataFetcherConnection *aFetcherConnection in self.connections) {
		if ([aFetcherConnection.connectionURL isEqual:[aURLRequest URL]]) {
			newFetcherConnection = aFetcherConnection;
			break;
		}
	}
	
	// If we don't have an existing request, start a new one
	if (!newFetcherConnection) {
		newFetcherConnection = [[[ZSDataFetcherConnection alloc] init] autorelease];
		newFetcherConnection.connectionURL = [aURLRequest URL];
		[self.connections addObject:newFetcherConnection];
	}

	// Add this delegate
	[newFetcherConnection.connectionDelegates addObject:[NSValue valueWithNonretainedObject:aDelegate]];
	
	// Try to start a connection to the resource
	if (!newFetcherConnection.connection) {
		newFetcherConnection.connection = [NSURLConnection connectionWithRequest:aURLRequest delegate:self];
		
		if (!newFetcherConnection.connection) {
			// Unable to make a connection
			for (NSValue *delegatePointer in newFetcherConnection.connectionDelegates) {
				id<ZSDataFetcherDelegate> currentDelegate = [delegatePointer nonretainedObjectValue];
				[currentDelegate didFailFetchForURL:[aURLRequest URL] withStatusCode:404];
			}
			
			// Remove the fetcher connection
			[self.connections removeObject:newFetcherConnection];
		}
	}
}

- (void)removeDelegate:(id<ZSDataFetcherDelegate>)aDelegate {
	NSValue *searchValue		= [NSValue valueWithNonretainedObject:aDelegate];
	NSArray *connectionObjects	= [self.connections allObjects];
	NSUInteger objectCount		= [connectionObjects count];
	
	for (NSUInteger i = 0; i < objectCount; i++) {
		ZSDataFetcherConnection *aFetcherConnection = [connectionObjects objectAtIndex:i];
		
		[aFetcherConnection.connectionDelegates removeObject:searchValue];
		
		if ([aFetcherConnection.connectionDelegates count] < 1) {
			// Stop in-flight request
			[aFetcherConnection.connection cancel];
			aFetcherConnection.connection = nil;
			
			// Remove this fetcher connection
			[self.connections removeObject:aFetcherConnection];
		}
	}
}


#pragma mark -
#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
	// Find connection
	ZSDataFetcherConnection *currentFetcherConnection = nil;
	for (ZSDataFetcherConnection *aFetcherConnection in self.connections) {
		if ([conn isEqual:aFetcherConnection.connection]) {
			currentFetcherConnection = aFetcherConnection;
			break;
		}
	}
	
	// Set status
	currentFetcherConnection.connectionStatus = [(NSHTTPURLResponse *)response statusCode];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
	// Find connection
	ZSDataFetcherConnection *currentFetcherConnection = nil;
	for (ZSDataFetcherConnection *aFetcherConnection in self.connections) {
		if ([conn isEqual:aFetcherConnection.connection]) {
			currentFetcherConnection = aFetcherConnection;
			break;
		}
	}
	
	// Append data
    [currentFetcherConnection.connectionData appendData:data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
	// Find connection
	ZSDataFetcherConnection *currentFetcherConnection = nil;
	for (ZSDataFetcherConnection *aFetcherConnection in self.connections) {
		if ([conn isEqual:aFetcherConnection.connection]) {
			currentFetcherConnection = aFetcherConnection;
			break;
		}
	}
	
	// Connection failed, notify delegates
	for (NSValue *delegatePointer in currentFetcherConnection.connectionDelegates) {
		id<ZSDataFetcherDelegate> currentDelegate = (id<ZSDataFetcherDelegate>)[delegatePointer pointerValue];
		[currentDelegate didFailFetchForURL:currentFetcherConnection.connectionURL withStatusCode:currentFetcherConnection.connectionStatus];
	}
	
	// Remove the fetcher connection
	[self.connections removeObject:currentFetcherConnection];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
	// Find connection
	ZSDataFetcherConnection *currentFetcherConnection = nil;
	for (ZSDataFetcherConnection *aFetcherConnection in self.connections) {
		if ([conn isEqual:aFetcherConnection.connection]) {
			currentFetcherConnection = aFetcherConnection;
			break;
		}
	}
	
	// Connection succeeded, notify delegates
	NSArray *connectionDelegateArray = [currentFetcherConnection.connectionDelegates allObjects];
	for (NSUInteger i = 0; i < [connectionDelegateArray count]; i++) {
		NSValue *delegatePointer = [connectionDelegateArray objectAtIndex:i];
		id<ZSDataFetcherDelegate> currentDelegate = (id<ZSDataFetcherDelegate>)[delegatePointer pointerValue];
		[currentDelegate didFetchData:currentFetcherConnection.connectionData forURL:currentFetcherConnection.connectionURL];
	}
	
	// Remove the fetcher connection
	[self.connections removeObject:currentFetcherConnection];
}

@end