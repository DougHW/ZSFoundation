//
//  NSCountedSet+ZSFoundation.h
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

@interface NSCountedSet (NSCountedSet_ZSFoundation)

/**
 * Adds each of the objects from aCountedSet to the receiver as many times as it appears in aCountedSet.
 * For example, if Object A is in the receiver with count 3 and also in aCountedSet with count 2,
 * after this operation it will have count 5 in the receiver.
 * This method is O(n*m) where n is [aCountedSet count] and m is the average count of each object in aCountedSet.
 */
- (void)unionCountedSet:(NSCountedSet *)aCountedSet;

@end
