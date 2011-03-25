//
//  ZSLowMemoryPool.m
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

#import "ZSLowMemoryPool.h"


#define NSTHREAD_LOW_MEMORY_POOL_KEY @"low_memory_pool_key"

@interface ZSLowMemoryPool ()

@property (nonatomic, retain)	NSMutableDictionary		*pointerPool;

@end


#pragma mark -
#pragma mark ZSLowMemoryPool implementation

@implementation ZSLowMemoryPool

@synthesize pointerPool;

+ (ZSLowMemoryPool *)lowMemoryPool {
	ZSLowMemoryPool *threadPool = (ZSLowMemoryPool *)[[[NSThread currentThread] threadDictionary] objectForKey:NSTHREAD_LOW_MEMORY_POOL_KEY];
	
	if (!threadPool) {
		threadPool = [[[ZSLowMemoryPool alloc] init] autorelease];
		[[[NSThread currentThread] threadDictionary] setObject:threadPool forKey:NSTHREAD_LOW_MEMORY_POOL_KEY];
	}
	
    return threadPool;
}


#pragma mark -
#pragma mark ZSLowMemoryPool Instance Methods

- (id)init {
    self = [super init];
	if (self) {
		// Create a pool
		pointerPool = [[NSMutableDictionary alloc] init];
		
		// Listen for low memory conditions
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(empty) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	
	[pointerPool release];

	[super dealloc];
}

- (void)addPointer:(id<NSObject> *)object {
	NSValue *pointerValue = [NSValue valueWithPointer:object];
	
	if ([self.pointerPool objectForKey:pointerValue]) {
		// We already have this pointer in our pool
		return;
	}
	
	// Add the pointer and object to our pool
	[self.pointerPool setObject:*object forKey:pointerValue];
}

- (void)removePointer:(id<NSObject> *)object {
	NSValue *pointerValue = [NSValue valueWithPointer:object];
	
	if (![self.pointerPool objectForKey:pointerValue]) {
		// We don't have this pointer in our pool
		return;
	}
	
	// Remove the pointer and object from our pool
	[self.pointerPool removeObjectForKey:pointerValue];
}

- (void)empty {
	for (NSValue *key in self.pointerPool) {
		id<NSObject> *pointer = [key pointerValue];
		
		// Set the pointer to nil
		*pointer = nil;
	}
	
	// Remove all objects from our pool
	[self.pointerPool removeAllObjects];
}

@end
