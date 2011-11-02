//
//  AbstractCacheStore.h
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


@class AbstractCacheStore;

@protocol CacheStoreItem <NSObject>

/**
 * Should return the value indicating identity for this item.
 */
- (id)itemKey;

@end

@protocol CacheStoreDelegate <AbstractStoreDelegate>
@optional

/**
 * Should be called whenever an item is modified or added/removed.
 * Sending nil for aKey indicates that ALL items have changed (generally on flushAll).
 */
- (void)store:(AbstractCacheStore *)aStore itemChangedForKey:(id)aKey;

@end

@interface AbstractCacheStore : AbstractStore {
@protected
	NSMutableDictionary		*cacheItems;
	NSMutableDictionary		*keyDelegates;
}

/**
 * Adds a delegate for a specific key.
 * This increments a counter if the delegate has already been added, so delegates should be
 * removed the same number of times they are added.
 */
- (void)addStoreDelegate:(id)aDelegate forKey:(id)aKey;
/**
 * Decrements the count for a delegate against a specific key.  If the count reaches zero,
 * the delegate is removed.
 */
- (void)removeStoreDelegate:(id)aDelegate forKey:(id)aKey;

#pragma mark - Cache manipulation methods

/**
 * Updates an item if it exists in the local cache, otherwise inserts it.
 * It is up to the individual store to determine the logic for updating an existing
 * item.  This could be as simple as replacing it, or could involve unioning the
 * objects together.  Refer to individual stores for implementation details.
 */
- (BOOL)upsertCacheStoreItem:(id<CacheStoreItem>)anItem;

- (BOOL)upsertItem:(id)anItem forKey:(id)aKey;
/**
 * Upserts each item in the set.  Should return NO if no item in the set could be upserted.
 */
- (BOOL)upsertCacheStoreItems:(NSSet *)items;

- (BOOL)upsertItems:(NSArray *)items forKeys:(NSArray *)keys;
/**
 * Replaces an item in the cache.
 */
- (BOOL)replaceCacheStoreItem:(id<CacheStoreItem>)anItem;

- (BOOL)replaceItem:(id)anItem forKey:(id)aKey;
/**
 * Removes an individual item from the store.
 */
- (BOOL)removeItemForKey:(id)aKey;
/**
 * Returns an item for the given key.
 */
- (id)itemForKey:(id)aKey;
/**
 * Returns an array of items in the same order as the keys.
 * If nil is passed for the marker, missing items will be omitted.
 * @see NSDictionary objectForKeys:notFoundMarker:
 */
- (NSArray *)itemsForKeys:(NSArray *)keys notFoundMarker:(id)anObject;
/**
 * Returns all items contained in the cache.
 */
- (NSArray *)allItems;
/**
 * Removes all cache items.
 */
- (void)flushAll;

#pragma mark -
#pragma mark PROTECTED PROPERTIES AND METHODS - DO NOT USE IF YOU ARE NOT A SUBCLASS

@property (nonatomic, retain)	NSMutableDictionary		*cacheItems;
@property (nonatomic, retain)	NSMutableDictionary		*keyDelegates;

/**
 * This method is used internally to prevent upsertItems from firing multiple update notifications
 * if subclasses wish to override upsertItem:
 */
- (BOOL)internalUpsertItem:(id)anItem forKey:(id)aKey;

/**
 * Returns all delegates for a given key or all keys that respond to the given selector.
 * If key is nil, all delegates are returned.
 * This method will return a new set, that will not be affected by mutation issues.
 * NOTE - Response is retained!
 */
- (NSMutableSet *)createAllDelegatesForKey:(id)aKey respondingToSelector:(SEL)aSelector NS_RETURNS_RETAINED;

/**
 * Alerts all delegates listening to everything, or just the given key, that the item has changed.
 * If aKey is nil, all delegates will be alerted.
 */
- (void)notifyDelegatesItemChangedForKey:(id)aKey;

@end