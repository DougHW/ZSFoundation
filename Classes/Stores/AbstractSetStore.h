//
//  AbstractSetStore.h
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
#import "AbstractStore.h"


@class AbstractSetStore;

@protocol AbstractSetStoreDelegate <AbstractStoreDelegate>
@optional

/**
 * Should be called whenever an item is modified or added/removed.
 * Sending nil for anItem indicates that ALL items have changed (generally on flushAll).
 */
- (void)store:(AbstractSetStore *)aStore itemChanged:(id)anItem;

@end

@interface AbstractSetStore : AbstractStore {
@protected
	NSMutableSet	*setItems;
}

#pragma mark - Set manipulation methods

/**
 * Updates an item if it exists in the local set, otherwise inserts it.
 * It is up to the individual store to determine the logic for updating an existing
 * item.  This could be as simple as replacing it, or could involve unioning the
 * objects together.  Refer to individual stores for implementation details.
 */
- (BOOL)upsertItem:(id)anItem;
/**
 * Upserts each item in the set.  Should return NO if no item in the set could be upserted.
 */
- (BOOL)upsertItems:(NSSet *)items;
/**
 * Removes an individual item from the store.
 */
- (BOOL)removeItem:(id)item;
/**
 * The existing set will be emptied and the items parameter will be inserted.
 */
- (void)replaceItems:(NSSet *)items;
/**
 * Returns YES if the given item is in the store.
 */
- (BOOL)containsItem:(id)item;
/**
 * Like NSSet's method "member:", this method tests an object for membership and, if present
 * returns it.  This is valuable because, despite equality, two object instances may be different.
 */
- (id)member:(id)item;
/**
 * Returns an ordered array of the items in the store.
 * Default ordering is to sort using the compare: selector.  Subclasses should override this
 * method if different ordering is desired.
 */
- (NSArray *)orderedItems;
/**
 * Removes all cache items.
 */
- (void)flushAll;

#pragma mark -
#pragma mark PROTECTED PROPERTIES AND METHODS - DO NOT USE IF YOU ARE NOT A SUBCLASS

@property (nonatomic, retain)	NSMutableSet	*setItems;

/**
 * This method is used internally to prevent upsertItems from firing multiple update notifications
 * if subclasses wish to override upsertItem:
 */
- (BOOL)internalUpsertItem:(id)anItem;

/**
 * Alerts all delegates that the item has changed.
 */
- (void)notifyDelegatesItemChanged:(id)anItem;

@end