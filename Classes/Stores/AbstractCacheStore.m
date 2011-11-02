//
//  AbstractCacheStore.m
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
#import "AbstractCacheStore.h"


@implementation AbstractCacheStore

@synthesize cacheItems, keyDelegates;

- (id)init {
	self = [super init];
	if (self) {
		cacheItems = [[NSMutableDictionary alloc] init];
		keyDelegates = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	[cacheItems release];
	[keyDelegates release];
	
	[super dealloc];
}


#pragma mark - Delegate methods

- (void)removeStoreDelegate:(id<AbstractStoreDelegate>)aDelegate {
	[super removeStoreDelegate:aDelegate];
	
	NSValue *wrappedDelegate = [NSValue valueWithNonretainedObject:aDelegate];
	
	for (id aKey in self.keyDelegates) {
		NSMutableSet *keyDelegateSet = [self.keyDelegates objectForKey:aKey];
		[keyDelegateSet removeObject:wrappedDelegate];
	}
}

- (void)addStoreDelegate:(id<CacheStoreDelegate>)aDelegate forKey:(id)aKey {
	if (!aDelegate || !aKey) {
		// pre-condition
		return;
	}
	
	NSValue *wrappedDelegate = [NSValue valueWithNonretainedObject:aDelegate];
	
	NSMutableSet *keyDelegateSet = [self.keyDelegates objectForKey:aKey];
	if (!keyDelegateSet) {
		keyDelegateSet = [[NSMutableSet alloc] init];
		[self.keyDelegates setObject:keyDelegateSet forKey:aKey];
		[keyDelegateSet release];
	}
	
	[keyDelegateSet addObject:wrappedDelegate];
}

- (void)removeStoreDelegate:(id<CacheStoreDelegate>)aDelegate forKey:(id)aKey {
	NSMutableSet *keyDelegateSet = [self.keyDelegates objectForKey:aKey];
	if (!keyDelegateSet) {
		// Nothing to do
		return;
	}
	
	NSValue *wrappedDelegate = [NSValue valueWithNonretainedObject:aDelegate];
	
	[keyDelegateSet removeObject:wrappedDelegate];
}


#pragma mark - Cache manipulation methods

- (BOOL)internalUpsertItem:(id)anItem forKey:(id)aKey {
	if (!anItem || !aKey) {
		return NO;
	}
	
	[self.cacheItems setObject:anItem forKey:aKey];
	
	[self notifyDelegatesItemChangedForKey:aKey];
	
	return YES;
}

- (BOOL)upsertCacheStoreItem:(id<CacheStoreItem>)anItem {
	return [self internalUpsertItem:anItem forKey:[anItem itemKey]];
}

- (BOOL)upsertItem:(id)anItem forKey:(id)aKey {
	return [self internalUpsertItem:anItem forKey:aKey];
}

- (BOOL)upsertCacheStoreItems:(NSSet *)items {
	BOOL success = NO;
	for (id anItem in items) {
		success = [self internalUpsertItem:anItem forKey:[anItem itemKey]] || success; // Note - order of operations matters here
	}
	
	return success;
}

- (BOOL)upsertItems:(NSArray *)items forKeys:(NSArray *)keys {
	if ([items count] != [keys count]) {
		// pre-condition
		return NO;
	}
	
	BOOL success = NO;
	NSUInteger itemCount = [items count];
	for (NSUInteger i = 0; i < itemCount; i++) {
		success = [self internalUpsertItem:[items objectAtIndex:i] forKey:[keys objectAtIndex:i]] || success; // Note - order of operations matters here
	}
	
	return success;
}

- (BOOL)replaceCacheStoreItem:(id<CacheStoreItem>)anItem {
	if (!anItem) {
		return NO;
	}
	
	[self.cacheItems setObject:anItem forKey:[anItem itemKey]];
	
	[self notifyDelegatesItemChangedForKey:[anItem itemKey]];
	
	return YES;
}

- (BOOL)replaceItem:(id)anItem forKey:(id)aKey {
	if (!anItem) {
		// Item is nil, try to remove key
		return [self removeItemForKey:aKey];
	}
	
	[self.cacheItems setObject:anItem forKey:aKey];
	
	[self notifyDelegatesItemChangedForKey:aKey];
	
	return YES;
}

- (BOOL)removeItemForKey:(id)aKey {
	if ([self.cacheItems objectForKey:aKey]) {
		[self.cacheItems removeObjectForKey:aKey];
		
		// Notify delegates
		[self notifyDelegatesItemChangedForKey:[[aKey retain] autorelease]];
		
		return YES;
	}
	
	return NO;
}

- (id)itemForKey:(id)aKey {
	return [self.cacheItems objectForKey:aKey];
}

- (NSArray *)itemsForKeys:(NSArray *)keys notFoundMarker:(id)anObject {
	if (anObject) {
		// Not found marker provided
		return [self.cacheItems objectsForKeys:keys notFoundMarker:anObject];
	}
	
	NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:[keys count]];
	for (id aKey in keys) {
		id item = [self itemForKey:aKey];
		if (item) {
			[items addObject:item];
		}
	}
	
	// Create immutable response and return
	NSArray *returnArray = [[items copy] autorelease];
	[items release];
	return returnArray;
}

- (NSArray *)allItems {
	return [self.cacheItems allValues];
}

- (void)flushAll {
	self.cacheItems = [[[NSMutableDictionary alloc] init] autorelease];
	
	// Notify delegates
	[self notifyDelegatesItemChangedForKey:nil];
}


#pragma mark - Delegate methods

- (NSMutableSet *)createAllDelegatesForKey:(id)aKey respondingToSelector:(SEL)aSelector {
	NSMutableSet *respondingWrappedDelegates = [[NSMutableSet alloc] init];
	
	// Add specific delegates
	if (aKey) {
		// General case
		NSSet *delegateSet = [self.keyDelegates objectForKey:aKey];
		for (NSValue *aWrappedDelegate in delegateSet) {
			id<CacheStoreDelegate> aDelegate = [aWrappedDelegate nonretainedObjectValue];
			
			if ([aDelegate respondsToSelector:aSelector]) {
				[respondingWrappedDelegates addObject:aWrappedDelegate];
			}
		}
	} else {
		// Special case for nil key, should return all delegates
		NSArray *delegateSetArray = [self.keyDelegates allValues];
		for (NSSet *delegateSet in delegateSetArray) {
			for (NSValue *aWrappedDelegate in delegateSet) {
				id<CacheStoreDelegate> aDelegate = [aWrappedDelegate nonretainedObjectValue];
				
				if ([aDelegate respondsToSelector:aSelector]) {
					[respondingWrappedDelegates addObject:aWrappedDelegate];
				}
			}			
		}
	}

	// Add general delegates
	for (NSValue *aWrappedDelegate in self.delegates) {
		id<CacheStoreDelegate> aDelegate = [aWrappedDelegate nonretainedObjectValue];
		
		if ([aDelegate respondsToSelector:aSelector]) {
			[respondingWrappedDelegates addObject:aWrappedDelegate];
		}
	}
	
	return respondingWrappedDelegates;
}

- (void)notifyDelegatesItemChangedForKey:(id)aKey {
	// Notify all delegates
	NSMutableSet *respondingDelegates = [self createAllDelegatesForKey:aKey respondingToSelector:@selector(store:itemChangedForKey:)];
	for (NSValue *aWrappedDelegate in respondingDelegates) {
		id<CacheStoreDelegate> aDelegate = [aWrappedDelegate nonretainedObjectValue];
		[aDelegate store:self itemChangedForKey:aKey];
	}
	[respondingDelegates release];
}

@end
