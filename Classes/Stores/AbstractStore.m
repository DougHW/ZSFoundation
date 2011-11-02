//
//  AbstractStore.m
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

#import "AbstractStore.h"


@implementation AbstractStore

@synthesize delegates;

- (id)init {
	self = [super init];
	if (self) {
		delegates = [[NSMutableSet alloc] init];
	}
	return self;
}

- (void)dealloc {
	[delegates release];
	
	[super dealloc];
}


#pragma mark - Delegate methods

- (void)addStoreDelegate:(id<AbstractStoreDelegate>)aDelegate {
	if (!aDelegate) {
		// pre-condition
		return;
	}
	
	NSValue *wrappedDelegate = [NSValue valueWithNonretainedObject:aDelegate];
	
	[self.delegates addObject:wrappedDelegate];
}

- (void)removeStoreDelegate:(id<AbstractStoreDelegate>)aDelegate {
	NSValue *wrappedDelegate = [NSValue valueWithNonretainedObject:aDelegate];
	
	[self.delegates removeObject:wrappedDelegate];
}

- (void)flushAll {
	// Abstract - Throws an exception
	[self doesNotRecognizeSelector:_cmd];
}

- (NSMutableSet *)createAllDelegatesRespondingToSelector:(SEL)aSelector {
	NSMutableSet *respondingWrappedDelegates = [[NSMutableSet alloc] init];
	
	// Add general delegates
	for (NSValue *aWrappedDelegate in self.delegates) {
		id<AbstractStoreDelegate> aDelegate = [aWrappedDelegate nonretainedObjectValue];
		
		if ([aDelegate respondsToSelector:aSelector]) {
			[respondingWrappedDelegates addObject:aWrappedDelegate];
		}
	}
	
	return respondingWrappedDelegates;
}

@end
