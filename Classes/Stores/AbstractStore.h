//
//  AbstractStore.h
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


@class AbstractStore;

@protocol AbstractStoreDelegate <NSObject>
@optional

// Nothing

@end

@interface AbstractStore : NSObject {
@protected
	NSMutableSet	*delegates;
}

/**
 * Adds a delegate to this store's pool.
 */
- (void)addStoreDelegate:(id)aDelegate;
/**
 * Removes a delegate from the store's pool.
 */
- (void)removeStoreDelegate:(id)aDelegate;

/**
 * ABSTRACT
 * Removes all cache items.
 */
- (void)flushAll;


#pragma mark -
#pragma mark PROTECTED PROPERTIES AND METHODS - DO NOT USE IF YOU ARE NOT A SUBCLASS

@property (nonatomic, retain)	NSMutableSet	*delegates;

/**
 * Returns all delegates that respond to the given selector.  This method will return
 * a new set, that will not be affected by mutation issues.
 * These delegates are wrapped in NSValue using valueWithNonretainedObject
 * NOTE - Response is retained!
 */
- (NSMutableSet *)createAllDelegatesRespondingToSelector:(SEL)aSelector NS_RETURNS_RETAINED;

@end
