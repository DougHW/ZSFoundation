//
//  NSMutableArray+ZSFoundation.m
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

#import "NSMutableArray+ZSFoundation.h"

@implementation NSMutableArray (NSMutableArray_ZSFoundation)

- (void)push:(id)stackObject {
	// Not checking for NIL here to maintain the same contract as addObject
	[self addObject:stackObject];
}

- (id)pop {
	id stackObject = [[[self lastObject] retain] autorelease];
	if (stackObject != nil) {
		[self removeLastObject];
	}
	return stackObject;
}

- (id)peek {
	return [self peek:0];
}

- (id)peek:(NSInteger)depth {
	NSInteger count = [self count];
	if (depth < count) {
		return [self objectAtIndex:(count - depth - 1)];
	}
	return nil;
}

- (void)enqueue:(id)queueObject {
	// Not checking for NIL here to maintain the same contract as addObject
	[self addObject:queueObject];
}

- (id)dequeue {
	if ([self count] == 0) {
		return nil;
	}
	id queueObject = [[[self objectAtIndex:0] retain] autorelease];
	[self removeObjectAtIndex:0];
	return queueObject;
}

- (void)safeRemoveObjectAtIndex:(NSUInteger)index {
	if (index < [self count]) {
		[self removeObjectAtIndex:index];
	}
}

- (void)safeAddObject:(id)anObject {
	if (anObject) {
		[self addObject:anObject];
	}
}

@end
