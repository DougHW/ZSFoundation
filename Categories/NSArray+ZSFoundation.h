//
//  NSArray+ZSFoundation.h
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

@interface NSArray (NSArray_ZSFoundation)

/**
 * Returns object at index, nil if index does not exist.
 * README: I struggled with the idea of adding this.  It *could* encourage bad programming practice, but
 * ultimately, how is this any different from NSSet or NSDictionary?  This should not be used any differently
 * than objectAtIndex, it's just safer, without requiring a try-catch block.  This should ONLY be used in
 * the case that data is stale, and getting a nil is preferable to an NSRangeException.
 * Also, "arrays" in objective c are giant POSes anyway.
 */
- (id)safeObjectAtIndex:(NSUInteger)index;

@end
