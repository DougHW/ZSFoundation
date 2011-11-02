//
//  AbstractSetStore.m
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

#import "AbstractSetStore.h"
#import "NSMutableSet+ZSFoundation.h"


@implementation AbstractSetStore

@synthesize setItems;

- (id)init {
	self = [super init];
	if (self) {
		setItems = [[NSMutableSet alloc] init];
	}
	return self;
}

- (void)dealloc {
	[setItems release];
	
	[super dealloc];
}

#pragma mark - Set manipulation methods

- (BOOL)internalUpsertItem:(id)anItem {
	if (!anItem) {
		return NO;
	}
	
	[self.setItems replaceObject:anItem];
	
	[self notifyDelegatesItemChanged:anItem];
	
	return YES;
}

- (BOOL)upsertItem:(id)anItem {
	return [self internalUpsertItem:anItem];
}

- (BOOL)upsertItems:(NSSet *)aSet {
	if (!aSet) {
		return NO;
	}
	
	BOOL success = NO;
	for (id anItem in aSet) {
		success = [self internalUpsertItem:anItem] || success; // Note - order of operations matters here
	}
	
	return success;
}

- (BOOL)removeItem:(id)item {
	id existingItem = [[[self.setItems member:item] retain] autorelease];
	if (existingItem) {
		[self.setItems removeObject:item];
		
		// Notify delegates
		[self notifyDelegatesItemChanged:existingItem];
		
		return YES;
	}
	
	return NO;
}

- (void)replaceItems:(NSSet *)items {
	self.setItems = [[items mutableCopy] autorelease];
	
	// Notify delegates
	[self notifyDelegatesItemChanged:nil];
}

- (BOOL)containsItem:(id)item {
	return [self.setItems containsObject:item];
}

- (id)member:(id)item {
	return [self.setItems member:item];
}

- (NSArray *)orderedItems {
	return [[self.setItems allObjects] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)flushAll {
	self.setItems = [[[NSMutableSet alloc] init] autorelease];
	
	// Notify delegates
	[self notifyDelegatesItemChanged:nil];
}


#pragma mark - Delegate methods

- (void)notifyDelegatesItemChanged:(id)anItem {
	// Notify delegates
	NSMutableSet *respondingDelegates = [self createAllDelegatesRespondingToSelector:@selector(store:itemChanged:)];
	for (NSValue *aWrappedDelegate in respondingDelegates) {
		id<AbstractSetStoreDelegate> aDelegate = [aWrappedDelegate nonretainedObjectValue];
		[aDelegate store:self itemChanged:anItem];
	}
	[respondingDelegates release];
}

@end
