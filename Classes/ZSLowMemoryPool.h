//
//  ZSLowMemoryPool.h
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
#import <UIKit/UIKit.h>


@interface ZSLowMemoryPool : NSObject {
@private
	NSMutableDictionary		*pointerPool;
}

/**
 * Returns the singleton ZSLowMemoryPool instance for the current thread.
 * ZSLowMemoryPool is not technically a singleton.  Rather, one instance exists per
 * thread, and is created lazily via this method.
 * And pointers added to the pool will be set, and have their objects retained
 * and released on the thread from which this method was called.
 */
+ (ZSLowMemoryPool *)lowMemoryPool;

/**
 * Adds a pointer to the pool and retains the object it points to.
 * On low memory, the object will be released, and its pointer set to nil
 *
 * @param		id<NSObject>	An object
 */
- (void)addPointer:(id<NSObject> *)object;

/**
 * Removes a pointer from the pool and releases the object it points to.
 * Does NOT set the pointer itself to nil, as during a low memory warning!
 *
 * @param		id<NSObject>	An object
 */
- (void)removePointer:(id<NSObject> *)object;

/**
 * Releases all pointers and sets them to nil
 */
- (void)empty;

@end
