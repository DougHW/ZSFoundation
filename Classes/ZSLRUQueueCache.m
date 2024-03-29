//
//  ZSLRUQueueCache.m
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

#import "ZSLRUQueueCache.h"
#import "UIImage+ZSFoundation.h"
#import "ZSKeyValuePair.h"


#define ZSLRUQueueCache_DYNAMIC_RESIZE_FACTOR 0.7

@interface ZSLRUQueueCache ()

@property (nonatomic, retain)	NSMutableDictionary		*memoryCache;
@property (nonatomic, retain)	NSMutableArray			*keyQueue;

/**
 * If this object is listening for low memory warnings, this method will be called.
 */
- (void)lowMemoryWarning;
/**
 * Returns the size of the disk cache in bytes.
 * WARNING - This method requires significant disk access
 */
- (unsigned long long)computeDiskCacheSize;
/**
 * Returns an array of ZSKeyValuePairs where the key is the complete file path
 * and the value is an NSDate representing the file's modification date.
 * WARNING - This method requires significant disk access
 */
- (NSArray *)cacheFilesSortedByModifiedDate;
/**
 * Removes items from in-memory cache in excess of memoryCountLimit
 */
- (void)removeMemoryItemsToLimit;
/**
 * Removes items from disk cache until total size < diskSizeLimit
 */
- (void)removeDiskItemsToLimit;

- (id<NSObject, NSCoding>)objectInMemoryForKey:(id)aKey;
- (id<NSObject, NSCoding>)objectOnDiskForKey:(id)aKey;

- (BOOL)setObjectInMemory:(id<NSObject,NSCoding>)anObject forKey:(id)aKey;
- (BOOL)setObjectOnDisk:(id<NSObject,NSCoding>)anObject forKey:(id)aKey;

@end


@implementation ZSLRUQueueCache

@synthesize cacheDirectory;
@synthesize memoryCountLimit, diskSizeLimit, diskSize;
@synthesize exclusiveDiskCacheUser, shouldClearOnLowMemory, shouldReduceCacheOnLowMemory;
@synthesize memoryCache, keyQueue;

+ (NSString *)diskFilenameForCacheKey:(id)aKey {
	return [NSString stringWithFormat:@"%d.zslru", [aKey hash]];
}

- (id)init {
	// Does not support default init
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithCacheDirectory:(NSString *)aCacheDirectory {
    self = [self initWithCacheDirectory:aCacheDirectory memoryCountLimit:0 diskSizeLimit:0];
	if (self) {
		// Nothing to do
	}
	return self;
}

- (id)initWithCacheDirectory:(NSString *)aCacheDirectory memoryCountLimit:(NSUInteger)memoryLimit diskSizeLimit:(NSUInteger)diskLimit {
    self = [super init];
	if (self) {
		cacheDirectory		= [aCacheDirectory copy];
		memoryCountLimit	= memoryLimit;
		diskSizeLimit		= diskLimit;
		
		exclusiveDiskCacheUser	= YES;
		diskSize				= 0;
		
		keyQueue			= [[NSMutableArray alloc] initWithCapacity:(memoryCountLimit + 1)];
		memoryCache			= [[NSMutableDictionary alloc] initWithCapacity:(memoryCountLimit + 1)];
		
		// Create directory if necessary
		BOOL isDir = NO;
		NSError *error;
		if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory isDirectory:&isDir] && isDir == NO) {
			if (![[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
				// Could not create the directory, fail init
				NSLog(@"Failed to create cache directory for ZSLRUQueueCache");
				[self release];
				return nil;
			}
		} else {
			// Disk cache directory already exists, calculate size
			diskSize = [self computeDiskCacheSize];
		}
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[cacheDirectory release];
	
	[memoryCache release];
	[keyQueue release];

	[super dealloc];
}

- (void)setMemoryCountLimit:(NSUInteger)aLimit {
	memoryCountLimit = aLimit;
	
	[self removeMemoryItemsToLimit];
}

- (void)setDiskSizeLimit:(NSUInteger)aLimit {
	diskSizeLimit = aLimit;
	
	[self removeDiskItemsToLimit];
}

- (void)setExclusiveDiskCacheUser:(BOOL)aBool {
	exclusiveDiskCacheUser = aBool;

	if (exclusiveDiskCacheUser) {
		// We need to recalculate our initial running total size
		diskSize = [self computeDiskCacheSize];
	}
}

- (unsigned long long)diskSize {
	if (self.exclusiveDiskCacheUser) {
		return diskSize;
	} else {
		return [self computeDiskCacheSize];
	}

}

- (void)setShouldClearOnLowMemory:(BOOL)aBool {
	shouldClearOnLowMemory = aBool;
	
	if (shouldClearOnLowMemory) {
		// Start listening for low memory warnings
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(lowMemoryWarning)
													 name:UIApplicationDidReceiveMemoryWarningNotification
												   object:nil];
	} else {
		// Stop listening for low memory warnings
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
}

- (void)lowMemoryWarning {
	// Clear our in-memory cache
	[self removeAllObjectsFromMemory];
	
	// Resize our in-memory cache if appropriate
	if (self.shouldReduceCacheOnLowMemory) {
		self.memoryCountLimit = (NSUInteger)ceil(self.memoryCountLimit * ZSLRUQueueCache_DYNAMIC_RESIZE_FACTOR);
	}
}

- (unsigned long long)computeDiskCacheSize {
	unsigned long long recomputedCacheSize = 0;
	
	// Create an autorelease pool to help with the memory overhead
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Go through all the files and add up the size
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.cacheDirectory error:nil];
	for (NSString *file in files) {
		NSError *error = nil;
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:file] error:&error];
		if (!error && ![[fileAttributes fileType] isEqualToString:NSFileTypeDirectory]) {
			recomputedCacheSize += [fileAttributes fileSize];
		}
	}
	
	[pool drain];
	
	return recomputedCacheSize;
}

- (NSArray *)cacheFilesSortedByModifiedDate {
	NSArray *files				= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.cacheDirectory error:nil];
	NSMutableArray *pairArray	= [NSMutableArray arrayWithCapacity:[files count]];
	
	// Create an autorelease pool to help with the memory overhead
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Go through the files and create ZSKeyValuePairs
	for (NSString *file in files) {
		NSError *error = nil;
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:file] error:&error];
		if (!error && ![[fileAttributes fileType] isEqualToString:NSFileTypeDirectory]) {
			ZSKeyValuePair *pair = [ZSKeyValuePair keyValuePairWithKey:[self.cacheDirectory stringByAppendingPathComponent:file]
																 value:[fileAttributes fileModificationDate]];
			[pairArray addObject:pair];
		}
	}
	
	[pool drain];
	
	// Sort by value (modified date) descending
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"value" ascending:NO] autorelease];
	return [pairArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (void)removeMemoryItemsToLimit {
	if (self.memoryCountLimit > 0) {
		while ([self.keyQueue count] > self.memoryCountLimit) {
			id keyToRemove = [[self.keyQueue objectAtIndex:0] retain];
			[self.keyQueue removeObjectAtIndex:0];
			[self.memoryCache removeObjectForKey:keyToRemove];
			[keyToRemove release];
		}
	}
}

- (void)removeDiskItemsToLimit {
	if (self.diskSizeLimit == 0) {
		// Unlimited
		return;
	}
	
	// Remove by size
	unsigned long long currentSize	= self.diskSize;
	
	if (currentSize > self.diskSizeLimit) {
		NSArray *cachedFilePairs	= [self cacheFilesSortedByModifiedDate];
		NSUInteger itemIndex		= [cachedFilePairs count];
		
		unsigned long long newSizeTarget = self.diskSizeLimit * ZSLRUQueueCache_DISK_FLUSH_FACTOR;
	
		while (itemIndex > 0 && currentSize > newSizeTarget) {
			itemIndex--;
			
			ZSKeyValuePair *filePair		= (ZSKeyValuePair *)[cachedFilePairs objectAtIndex:itemIndex];
			NSDictionary *fileAttributes	= [[NSFileManager defaultManager] attributesOfItemAtPath:filePair.key error:nil];
			
			if ([[NSFileManager defaultManager] removeItemAtPath:filePair.key error:nil]) {
				// File removed, deduct size
				currentSize -= [fileAttributes fileSize];
			}
		}
		
		if (self.exclusiveDiskCacheUser) {
			diskSize = currentSize;
		}
	}
}

- (NSUInteger)countInMemory {
	return [self.keyQueue count];
}

- (id<NSObject, NSCoding>)objectForKey:(id)aKey {
	if (!aKey) {
		return nil;
	}
	
	// Check memory cache
	id<NSObject, NSCoding> returnObject = [self objectInMemoryForKey:aKey];
	if (returnObject) {
		return returnObject;
	}
	
	returnObject = [self objectOnDiskForKey:aKey];
	if (returnObject) {
		// Add back to in-memory cache, and resize if necessary
		[self.memoryCache setObject:returnObject forKey:aKey];
		[self.keyQueue addObject:aKey];
		[self removeMemoryItemsToLimit];
		
		return returnObject;
	}
	
	return nil;
}

- (id<NSObject, NSCoding>)objectInMemoryForKey:(id)aKey {
	if (!aKey) {
		return nil;
	}
	
	// Check memory cache
	id returnObject = [self.memoryCache objectForKey:aKey];
	if (returnObject) {
		[self.keyQueue removeObject:aKey];
		[self.keyQueue addObject:aKey];
		
		// Update disk cache timestamp
		// NOTE - This might be a bit expensive to perform on every access
		// If performance is a concern, this should probably be profiled, and perhaps
		// removed, threaded, batched, etc.
		[[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate]
										 ofItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:[ZSLRUQueueCache diskFilenameForCacheKey:aKey]]
												error:nil];
	}
	
	return returnObject;
}

- (id<NSObject, NSCoding>)objectOnDiskForKey:(id)aKey {
	if (!aKey) {
		return nil;
	}
	
	NSData *cachedData = [[NSData alloc] initWithContentsOfFile:[self.cacheDirectory stringByAppendingPathComponent:[ZSLRUQueueCache diskFilenameForCacheKey:aKey]]
														options:NSDataReadingUncached
														  error:nil];
	
	id returnObject = nil;
	if (cachedData) {
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:cachedData];
		returnObject = [unarchiver decodeObjectForKey:@"object"];
		[unarchiver finishDecoding];
		[unarchiver release];
		
		if (returnObject) {
			// Update disk cache timestamp
			// NOTE - This might be a bit expensive to perform on every access
			// If performance is a concern, this should probably be profiled, and perhaps
			// removed, threaded, batched, etc.
			[[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate]
											 ofItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:[ZSLRUQueueCache diskFilenameForCacheKey:aKey]]
													error:nil];
		}
	}
	[cachedData release];
	
	return returnObject;
}

- (BOOL)setObject:(id<NSObject, NSCoding>)anObject forKey:(id)aKey {
	if (!aKey || ![aKey conformsToProtocol:@protocol(NSCopying)]) {
		// pre-condition
		return NO;
	}
	
	id keyCopy = [aKey copy];

	[self setObjectOnDisk:anObject forKey:keyCopy];
	BOOL success = [self setObjectInMemory:anObject forKey:keyCopy];
	
	[keyCopy release];
	return success;
}

- (BOOL)setObjectInMemory:(id<NSObject,NSCoding>)anObject forKey:(id)aKey {
	if (!aKey) {
		// pre-condition
		return NO;
	}
	
	// Add key to queue
	[self.keyQueue removeObject:aKey];
	[self.keyQueue addObject:aKey];
	
	// Add to memory cache
	[self.memoryCache setObject:anObject forKey:aKey];

	// Eject objects if we've overflowed
	[self removeMemoryItemsToLimit];
	
	return YES;
}

- (BOOL)setObjectOnDisk:(id<NSObject,NSCoding>)anObject forKey:(id)aKey {
	if (!aKey) {
		// pre-condition
		return NO;
	}
	
	// Add to disk cache
	NSMutableData *data			= [NSMutableData data];
	NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:anObject forKey:@"object"];
	[archiver finishEncoding];
	[archiver release];
	
	if ([data writeToFile:[self.cacheDirectory stringByAppendingPathComponent:[ZSLRUQueueCache diskFilenameForCacheKey:aKey]] atomically:YES]) {
		// File written to disk cache successfully - add to diskSize
		if (self.exclusiveDiskCacheUser) {
			NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:[ZSLRUQueueCache diskFilenameForCacheKey:aKey]] error:nil];
			diskSize += [fileAttributes fileSize];
		}
		
		// Eject objects if we've overflowed
		[self removeDiskItemsToLimit];
		
		return YES;
	}
	
	return NO;
}

- (void)removeAllObjectsFromMemory {
	self.keyQueue		= [[[NSMutableArray alloc] initWithCapacity:(self.memoryCountLimit + 1)] autorelease];
	self.memoryCache	= [[[NSMutableDictionary alloc] initWithCapacity:(self.memoryCountLimit + 1)] autorelease];
}

- (void)removeAllObjectsFromDisk {
	// Remove cache directory
	[[NSFileManager defaultManager] removeItemAtPath:self.cacheDirectory error:nil];
	
	// Recreate cache directory
	if (![[NSFileManager defaultManager] createDirectoryAtPath:self.cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
		// Could not create the directory
		NSLog(@"Failed to create cache directory for ZSLRUQueueCache in removeAllObjectsFromDisk");
	}
	
	diskSize = 0;
}

@end
