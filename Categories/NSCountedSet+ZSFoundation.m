//
//  NSCountedSet+ZSFoundation.m
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

#import "NSCountedSet+ZSFoundation.h"

@implementation NSCountedSet (NSCountedSet_ZSFoundation)

- (void)unionCountedSet:(NSCountedSet *)aCountedSet {
	for (id anObject in aCountedSet) {
		NSUInteger objectCount = [aCountedSet countForObject:anObject];
		for (NSUInteger i = 0; i < objectCount; i++) {
			[self addObject:anObject];
		}
	}
}

@end
