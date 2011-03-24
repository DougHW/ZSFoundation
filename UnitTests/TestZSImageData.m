//
//  TestZSImageData.m
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

#import "TestZSImageData.h"
#import "ZSImageData.h"


@implementation TestZSImageData

- (void)testEncodeDecode {
	NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"gtm" ofType:@"png"];
	STAssertNotNil(imagePath, @"Couldn't find a path to sample image");
	NSData *imageData = [[[NSData alloc] initWithContentsOfFile:imagePath
														options:NSDataReadingUncached
														  error:nil] autorelease];
	STAssertNotNil(imageData, @"NSData was nil!");
	ZSImageData *wrappedData = [[[ZSImageData alloc] initWithData:imageData] autorelease];
	STAssertNotNil(wrappedData, @"ZSImageData was nil!");
	
	// Encode image data
	NSMutableData *codedImageData	= [NSMutableData data];
	NSKeyedArchiver *archiver		= [[NSKeyedArchiver alloc] initForWritingWithMutableData:codedImageData];
	[archiver encodeObject:wrappedData forKey:@"testImage"];
	[archiver finishEncoding];
	[archiver release];
	STAssertTrue([codedImageData length] > 0, @"Image not coded properly!");
	
	// Decode image data
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedImageData];
	UIImage *decodedImage = [unarchiver decodeObjectForKey:@"testImage"];
	[unarchiver finishDecoding];
	[unarchiver release];
	STAssertNotNil(decodedImage, @"Decoded image was nil!");
	STAssertTrue(decodedImage.size.width > 0, @"Decoded image width was zero!");
	STAssertTrue(decodedImage.size.height > 0, @"Decoded image width was zero!");
}

@end
