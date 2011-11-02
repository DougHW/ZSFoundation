//
//  ZSImageCache.h
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
#import "AbstractCacheStore.h"
#import "ZSDataFetcher.h"


@class ZSImageCache;

/**
 * CacheStoreDelegate extension to provide image fetching callback information.
 */
@protocol ZSImageCacheDelegate <CacheStoreDelegate>
@optional
- (void)imageCache:(ZSImageCache *)aCache didFetchImageForFilename:(NSString *)aFilename;
- (void)imageCache:(ZSImageCache *)aCache didFailFetchImageForFilename:(NSString *)aFilename;

@end

/**
 * ZSImageCache is a disk based least recently used image cache.
 *
 * Extends from AbstractCacheStore.  Methods from AbstractCacheStore will function, but
 * added images will ONLY be retained in memory, NOT on the disk cache!
 *
 * This class must be initialized with the directory to be used for on-disk cache.  It
 * will assume that this directory is dedicated and only used for this cache.
 * 
 * You may set a limit on the size in bytes that may be stored on disk.  In that case, the
 * least recently used items will be ejected from the cache first.
 */
@interface ZSImageCache : AbstractCacheStore <ZSDataFetcherDelegate> {
@private
	NSString	*cacheDirectory;

	NSUInteger	diskSizeLimit;
	float		diskFlushFactor;
	NSUInteger	inMemoryLimit;
	
	NSUInteger	writtenCount;
	NSMutableArray *memoryKeyQueue;
}

/**
 * The directory where cache files will be stored.
 *
 * This directory will be created on initialization if it does not exist.
 * All files in this directory will be managed by the cache, so you should
 * use a dedicated directory with no other files.
 * Trailing slash (/) is optional.
 */
@property (nonatomic, copy, readonly)	NSString	*cacheDirectory;

/**
 * If > 0, disk cache will be limited to this size in Bytes.
 * When disk cache reaches this limit, it will be reduced according to the diskFlushFactor.
 *
 * This reduction will be done on a background thread to avoid burdening the main thread.
 */
@property (nonatomic, readonly)		NSUInteger		diskSizeLimit;
/**
 * Must be > 0.0 and <= 1.0.
 * Default = 0.6
 *
 * This value controls the flushing characteristics of the cache.  When the disk cache is reduced,
 * files will be removed until folder size is less than diskSizeLimit * diskFlushFactor.
 *
 * It also determines how often flushing is performed.  Once writes totalling
 * diskSizeLimit - (diskSizeLimit * diskFlushFactor) + 1 bytes have been performed, the cache will
 * be reduced on a background thread.
 *
 * Example: If diskSizeLimit = 10mb and diskFlushFactor = 0.6, the cache will reduce the disk after
 * 4mb + 1byte worth of data have been written.  It will reduce the disk to <= 6mb.
 */
@property (nonatomic)				float			diskFlushFactor;

/**
 * Default = 20
 *
 * This value determines how many images will be kept in memory on being read.
 * Images will be ejected from the in memory cache on an LRU basis, once this limit is met.
 *
 * Changing this property will have no effect until the next ejection check.
 */
@property (nonatomic)				NSUInteger		inMemoryLimit;

/**
 * DO NOT USE.  Will throw an exception.
 */
- (id)init;

/**
 * This initializer will create a ZSImageCache with no limits on items in memory or on disk.
 *
 * @param	aCacheDirectory		The path to cache files on disk
 * @return						A ZSImageCache object
 */
- (id)initWithCacheDirectory:(NSString *)aCacheDirectory;

/**
 * INITIALIZER (DESIGNATED)
 *
 * @param	aCacheDirectory		The path to cache files on disk
 * @param	diskLimit			The maximum size of items to keep on disk
 * @return						A ZSImageCache object
 */
- (id)initWithCacheDirectory:(NSString *)aCacheDirectory diskSizeLimit:(NSUInteger)diskLimit;

/**
 * Convenience method for itemForKey:
 *
 * @param	aName	The filename (e.g. "test.jpg") of the image. Corresponds to the item key of backing AbstractCacheStore.
 * @return			The UIImage if it exists in the cache.
 */
- (UIImage *)imageForFilename:(NSString *)aName;
/**
 * Convenience method for calling imageForFilename: with an NSURL.
 */
- (UIImage *)imageForURL:(NSURL *)aURL;

/**
 * Convenience method for setItem:forKey:
 *
 * @param	imageData	The NSData of the image. Method will fail if creating a UIImage from data fails.
 * @param	aName		The filename (e.g. "test.jpg") of the image.
 * @return				YES if item was at least stored successfully in memory. Ignores disk failure.
 */
- (BOOL)setImageData:(NSData *)imageData forFilename:(NSString *)aName;
/**
 * Convenience method for calling setImageData:forFilename: with an NSURL.
 */
- (BOOL)setImageData:(NSData *)imageData forURL:(NSURL *)aURL;

/**
 * Asynchronously fetches and processes the image at the given URL.
 * Uses the resource identifier to determine image filename.  That means that two different URLs with
 * the same filename will overwrite each other.  See NSURL category extension for details.
 *
 * @param	aURL	The image URL to fetch.
 */
- (void)fetchImageForURL:(NSURL *)aURL;

@end
