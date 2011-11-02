//
//  ZSImageCache.m
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

#import "ZSImageCache.h"
#import "NSObject+ZSFoundation.h"
#import "NSURL+ZSFoundation.h"
#import "ZSKeyValuePair.h"


@interface ZSImageCache ()

/**
 * Tracks the amount of data written since last disk reduction.
 */
@property (nonatomic)			NSUInteger		writtenCount;
/**
 * This queue maintains an ordered list of the objects in memory cache.
 * Items are moved to 
 */
@property (nonatomic, retain)	NSMutableArray	*memoryKeyQueue;

/**
 * Returns the size of the contents of the given directory.
 */
- (NSUInteger)sizeOfDirectory:(NSString *)directory;
/**
 * Returns an array of ZSKeyValuePairs where the key is the complete file path
 * and the value is an NSDate representing the file's modification date.
 * WARNING - This method requires significant disk access
 */
- (NSArray *)filesSortedByModifiedDateInDirectory:(NSString *)directory;
/**
 * Removes items from disk cache until total size < diskSizeLimit
 */
- (void)removeFilesInDirectory:(NSString *)directory toLimitSize:(NSUInteger)limitSize;

- (void)insertIntoMemoryCacheItem:(id)anItem forKey:(id)aKey;

/**
 * Broadcast image fetch notification to all listening delegates.
 */
- (void)notifyDelegatesDidFetchImageForFilename:(NSString *)aFilename;
- (void)notifyDelegatesDidFailFetchImageForFilename:(NSString *)aFilename;

@end


@implementation ZSImageCache

@synthesize cacheDirectory;
@synthesize diskSizeLimit, diskFlushFactor, inMemoryLimit;
@synthesize writtenCount, memoryKeyQueue;

- (id)init {
	// Does not support default init
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithCacheDirectory:(NSString *)aCacheDirectory {
    self = [self initWithCacheDirectory:aCacheDirectory diskSizeLimit:0];
	if (self) {
		// Nothing to do
	}
	return self;
}

- (id)initWithCacheDirectory:(NSString *)aCacheDirectory diskSizeLimit:(NSUInteger)diskLimit {
	if (!aCacheDirectory) {
		// pre-condition
		[self release];
		return nil;
	}
	
    self = [super init];
	if (self) {
		diskSizeLimit	= diskLimit;
		diskFlushFactor	= 0.6;
		
		inMemoryLimit	= 20;
		
		memoryKeyQueue	= [[NSMutableArray alloc] initWithCapacity:(inMemoryLimit + 1)];
		
		// Go through setter to trigger directory creation
		cacheDirectory = [aCacheDirectory copy];
		
		// Create directory if necessary
		BOOL isDir = NO;
		NSError *error;
		if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory isDirectory:&isDir] && isDir == NO) {
			if (![[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
				// Could not create the directory, fail init
				NSLog(@"Failed to create cache directory for ZSImageCache");
				[self release];
				return nil;
			}
		}
		
		// Listen for low memory
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flushAll) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[ZSDataFetcher defaultDataFetcher] removeDelegate:self];
	
	[cacheDirectory release];
	cacheDirectory = nil;
	
	[memoryKeyQueue release];
	memoryKeyQueue = nil;

	[super dealloc];
}


#pragma mark - Public methods

- (UIImage *)imageForFilename:(NSString *)aName {
	return (UIImage *)[self itemForKey:aName];
}

- (UIImage *)imageForURL:(NSURL *)aURL {
	return [self imageForFilename:[aURL resourceIdentifier]];
}

- (BOOL)setImageData:(NSData *)imageData forFilename:(NSString *)aName {
	return [self upsertItem:imageData forKey:aName];
}

- (BOOL)setImageData:(NSData *)imageData forURL:(NSURL *)aURL {
	return [self setImageData:imageData forFilename:[aURL resourceIdentifier]];
}

- (void)fetchImageForURL:(NSURL *)aURL {
	if (!aURL) {
		// pre-condition
		return;
	}
	
	[[ZSDataFetcher defaultDataFetcher] fetchURL:aURL forDelegate:self];
}


#pragma mark - Private methods

- (NSUInteger)sizeOfDirectory:(NSString *)directory {
	NSUInteger recomputedCacheSize = 0;
	
	// Go through all the files and add up the size
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for (NSString *file in files) {
		NSError *error = nil;
		NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[directory stringByAppendingPathComponent:file] error:&error];
		if (!error && ![[fileAttributes fileType] isEqualToString:NSFileTypeDirectory]) {
			recomputedCacheSize += [fileAttributes fileSize];
		}
	}
	
	return recomputedCacheSize;
}

- (NSArray *)filesSortedByModifiedDateInDirectory:(NSString *)directory {
	NSArray *files				= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
	NSMutableArray *pairArray	= [NSMutableArray arrayWithCapacity:[files count]];
	
	// Go through the files and create ZSKeyValuePairs
	for (NSString *file in files) {
		NSError *error = nil;
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[directory stringByAppendingPathComponent:file] error:&error];
		if (!error && ![[fileAttributes fileType] isEqualToString:NSFileTypeDirectory]) {
			ZSKeyValuePair *pair = [[ZSKeyValuePair alloc] initWithKey:[directory stringByAppendingPathComponent:file]
																 value:[fileAttributes fileModificationDate]];
			[pairArray addObject:pair];
			[pair release];
		}
	}
	
	// Sort by value (modified date) descending
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"value" ascending:NO] autorelease];
	return [pairArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (void)removeFilesInDirectory:(NSString *)directory toLimitSize:(NSUInteger)limitSize {
	// Create an autorelease pool in case we're invoked
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSUInteger currentSize = [self sizeOfDirectory:directory];
	
	if (limitSize <= 0 || currentSize <= limitSize) {
		// Nothing to do
		return;
	}
	
	// Remove by size
	NSArray *cachedFilePairs	= [self filesSortedByModifiedDateInDirectory:directory];
	NSUInteger itemIndex		= [cachedFilePairs count];
	
	while (itemIndex > 0 && currentSize > limitSize) {
		itemIndex--;
		
		ZSKeyValuePair *filePair		= (ZSKeyValuePair *)[cachedFilePairs objectAtIndex:itemIndex];
		NSDictionary *fileAttributes	= [[NSFileManager defaultManager] attributesOfItemAtPath:filePair.key error:nil];
		
		if ([[NSFileManager defaultManager] removeItemAtPath:filePair.key error:nil]) {
			// File removed, deduct size
			currentSize -= [fileAttributes fileSize];
		}
	}
		
	[pool release];
}

- (void)insertIntoMemoryCacheItem:(id)anItem forKey:(id)aKey {
	[self.memoryKeyQueue removeObject:aKey];
	
	[self.cacheItems setObject:anItem forKey:aKey];
	[self.memoryKeyQueue insertObject:aKey atIndex:0];
	
	while ([self.memoryKeyQueue count] > self.inMemoryLimit) {
		id ejectedKey = [self.memoryKeyQueue lastObject];
		[self.cacheItems removeObjectForKey:ejectedKey];
		[self.memoryKeyQueue removeObject:ejectedKey];
	}
}

//- (void)lowMemoryWarning:(NSNotification *)notification {
//	[self flushAll];
//}


#pragma mark - Overridden getters/setters

- (void)setDiskSizeLimit:(NSUInteger)aLimit {
	diskSizeLimit = aLimit;
	
	// Reduce disk cache
	NSUInteger limitSize = (self.diskSizeLimit * self.diskFlushFactor);
	[self performSelectorInBackground:@selector(removeFilesInDirectory:toLimitSize:) withParameters:self.cacheDirectory, limitSize, nil];
}


#pragma mark - AbstractCacheStore methods

- (BOOL)internalUpsertItem:(id)anItem forKey:(id)aKey {
	if (!anItem || !aKey || ![anItem isKindOfClass:[NSData class]] || ![aKey isKindOfClass:[NSString class]]) {
		// pre-condition
		return NO;
	}
	
	NSString *filePath = [self.cacheDirectory stringByAppendingPathComponent:aKey];
	
	// Add to disk cache
	NSError *error;
	if ([anItem writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
		// File written to disk cache successfully - add to diskSize
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
		writtenCount += [fileAttributes fileSize];
		
		// Eject objects if we've overflowed
		if (self.diskSizeLimit > 0 && writtenCount > self.diskSizeLimit - (self.diskSizeLimit * self.diskFlushFactor)) {
			// Reset written count
			writtenCount = 0;
			
			// Reduce disk cache
			NSUInteger limitSize = (self.diskSizeLimit * self.diskFlushFactor);
			[self performSelectorInBackground:@selector(removeFilesInDirectory:toLimitSize:) withParameters:self.cacheDirectory, limitSize, nil];
		}
		
		// Notify delegates
		[self notifyDelegatesItemChangedForKey:aKey];
		
	}
	return YES;
}

- (BOOL)removeItemForKey:(id)aKey {
	if ([[NSFileManager defaultManager] removeItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:aKey] error:nil]) {
		// Notify delegates
		[self notifyDelegatesItemChangedForKey:[[aKey retain] autorelease]];
		
		return YES;
	}
	
	return NO;
}

- (id)itemForKey:(id)aKey {
	if (!aKey) {
		return nil;
	}
	
	// Check memory cache first
	UIImage *uncachedImage = [self.cacheItems objectForKey:aKey];
	if (uncachedImage) {
		[self.memoryKeyQueue removeObject:aKey];
		[self.memoryKeyQueue insertObject:aKey atIndex:0];
		
		return uncachedImage;
	}
	
	// Go to disk
	NSString *filePath = [self.cacheDirectory stringByAppendingPathComponent:aKey];
	
	uncachedImage = [UIImage imageWithContentsOfFile:filePath];
	
	if (uncachedImage) {
		// Insert into memory cache
		[self insertIntoMemoryCacheItem:uncachedImage forKey:aKey];
		
		// Update disk cache timestamp
//		NSError *anError;
//		[[NSFileManager defaultManager] performSelectorInBackground:@selector(setAttributes:ofItemAtPath:error:)
//													 withParameters:[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate], filePath, anError, nil];
		[[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate]
										 ofItemAtPath:filePath
												error:nil];
	}
	
	return uncachedImage;
}

- (void)flushAll {
	// Remove memory items
	self.cacheItems = [[[NSMutableDictionary alloc] init] autorelease];
	
	// Remove cache directory
	[[NSFileManager defaultManager] removeItemAtPath:self.cacheDirectory error:nil];
	
	// Recreate cache directory
	if (![[NSFileManager defaultManager] createDirectoryAtPath:self.cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
		// Could not create the directory
		NSLog(@"Failed to create cache directory for ZSLRUQueueCache in removeAllObjectsFromDisk");
	}
}


#pragma mark - Delegate methods

- (void)notifyDelegatesDidFetchImageForFilename:(NSString *)aFilename {
	// Notify all delegates
	NSMutableSet *respondingDelegates = [self createAllDelegatesForKey:aFilename respondingToSelector:@selector(imageCache:didFetchImageForFilename:)];
	for (NSValue *aWrappedDelegate in respondingDelegates) {
		id<ZSImageCacheDelegate> aDelegate = [aWrappedDelegate nonretainedObjectValue];
		[aDelegate imageCache:self didFetchImageForFilename:aFilename];
	}
	[respondingDelegates release];
}

- (void)notifyDelegatesDidFailFetchImageForFilename:(NSString *)aFilename {
	// Notify all delegates
	NSMutableSet *respondingDelegates = [self createAllDelegatesForKey:aFilename respondingToSelector:@selector(imageCache:didFailFetchImageForFilename::)];
	for (NSValue *aWrappedDelegate in respondingDelegates) {
		id<ZSImageCacheDelegate> aDelegate = [aWrappedDelegate nonretainedObjectValue];
		[aDelegate imageCache:self didFailFetchImageForFilename:aFilename];
	}
	[respondingDelegates release];
}


#pragma mark - ZSDataFetcherDelegate methods

- (void)didFetchData:(NSData *)aData forURL:(NSURL *)aURL {
	NSString *resourceIdentifier = [aURL resourceIdentifier];
	if (!aData || !resourceIdentifier) {
		// pre-condition
		if (resourceIdentifier) {
			[self notifyDelegatesDidFailFetchImageForFilename:resourceIdentifier];
		}
		return;
	}
	
	// Make sure this is a valid image
	UIImage *newImage = [UIImage imageWithData:aData];
	
	if (newImage && [self setImageData:aData forFilename:resourceIdentifier]) {
		// Pre-load the image into memory
		[self insertIntoMemoryCacheItem:newImage forKey:resourceIdentifier];

		// Notify delegates success
		[self notifyDelegatesDidFetchImageForFilename:resourceIdentifier];
	} else {
		// Notify delegates failure
		[self notifyDelegatesDidFailFetchImageForFilename:resourceIdentifier];
	}
}

- (void)didFailFetchForURL:(NSURL *)aURL withStatusCode:(NSInteger)aCode {
	// Loading photo failed
	NSString *resourceIdentifier = [aURL resourceIdentifier];
	if (resourceIdentifier) {
		[self notifyDelegatesDidFailFetchImageForFilename:resourceIdentifier];
	}
}

@end
