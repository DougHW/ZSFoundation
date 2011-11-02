//
//  NSMutableArray+ZSFoundation.h
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

@interface NSMutableArray (NSMutableArray_ZSFoundation)

// Stack methods
/**
 * Pushes an object onto the end of the array. Equivalent to addObject:.
 *
 * @param	stackObject	Object to be pushed
 */
- (void)push:(id)stackObject;

/**
 * Removes and returns the last element of the array.
 *
 * @return	(Formerly) last object in the array
 */
- (id)pop;

/**
 * Returns the last element of the array without removing it.
 *
 * @return	Last object in the array
 */
- (id)peek;

/**
 * Return the n'th-to-last element of the array without removing it, where n is depth.
 *
 * @param	depth	Distance of the desired element from last
 * @return			n'th-to-last object in the array, where n is depth
 */
- (id)peek:(NSInteger)depth;

// Queue methods
/**
 * Enqueues an object onto the end of the array. Equivalent to addObject:.
 *
 * @param	queueObject	Object to be queued
 */
- (void)enqueue:(id)queueObject;
/**
 * Removes and returns the first element of the array.
 *
 * @return	(Formerly) first object in the array
 */
- (id)dequeue;
/**
 * Removes object at a given index if that index exists
 */
- (void)safeRemoveObjectAtIndex:(NSUInteger)index;
/**
 * Adds an object to an array, if it is not-nil
 */
- (void)safeAddObject:(id)anObject;

@end
