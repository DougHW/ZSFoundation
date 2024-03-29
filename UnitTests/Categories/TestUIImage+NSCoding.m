//
//  TestUIImage+NSCoding.m
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

#import "TestUIImage+NSCoding.h"
#import "UIImage+ZSFoundation.h"


@implementation TestUIImage_NSCoding

#pragma mark -
#pragma mark Helper methods

- (UIImage *)getTestImage {
	NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"gtm" ofType:@"png"];
	STAssertNotNil(imagePath, @"Couldn't find a path to sample image");
	NSData *imageData = [[[NSData alloc] initWithContentsOfFile:imagePath
														options:NSDataReadingUncached
														  error:nil] autorelease];
	
	UIImage *testImage = [UIImage imageWithData:imageData];
	STAssertNotNil(testImage, @"Test image was not loaded properly!");
	
	return testImage;
}

- (NSData *)encodeImage:(UIImage *)anImage {
	NSMutableData *codedImageData	= [NSMutableData data];
	NSKeyedArchiver *archiver		= [[NSKeyedArchiver alloc] initForWritingWithMutableData:codedImageData];
	[archiver encodeObject:anImage forKey:@"testImage"];
	[archiver finishEncoding];
	[archiver release];
	STAssertTrue([codedImageData length] > 0, @"Image not coded properly!");
	
	return codedImageData;
}

- (UIImage *)decodeImage:(NSData *)codedImageData {
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedImageData];
	UIImage *decodedImage = [unarchiver decodeObjectForKey:@"testImage"];
	[unarchiver finishDecoding];
	[unarchiver release];
	STAssertNotNil(decodedImage, @"Decoded image was nil!");
	
	return decodedImage;
}


#pragma mark -
#pragma mark Unit tests

- (void)testJPEGEncodeDecode {
	UIImage *testImage = [self getTestImage];
	STAssertTrue([testImage conformsToProtocol:@protocol(NSCoding)], @"UIImage does not conform to NSCoding protocol!");
	
	NSData *codedImageData	= [self encodeImage:testImage];
	UIImage *decodedImage	= [self decodeImage:codedImageData];
	STAssertTrue(CGSizeEqualToSize(decodedImage.size, testImage.size), @"Decoded image not same size as original!");
}

- (void)testPNGEncodeDecode {
	UIImage *testImage = [self getTestImage];
	STAssertTrue([testImage conformsToProtocol:@protocol(NSCoding)], @"UIImage does not conform to NSCoding protocol!");
	
	// Set parameters
	testImage.codingFormat = UIImageNSCodingFormatPNG;
	
	NSData *codedImageData	= [self encodeImage:testImage];
	UIImage *decodedImage	= [self decodeImage:codedImageData];
	STAssertTrue(CGSizeEqualToSize(decodedImage.size, testImage.size), @"Decoded image not same size as original!");
}

- (void)testJPEGEncodeDecodeDifferentQualities {
	UIImage *testImage = [self getTestImage];
	STAssertTrue([testImage conformsToProtocol:@protocol(NSCoding)], @"UIImage does not conform to NSCoding protocol!");
	
	// Set parameters
	testImage.codingQuality = 0.3;
	
	NSData *codedImageData1	= [self encodeImage:testImage];
	UIImage *decodedImage1	= [self decodeImage:codedImageData1];
	STAssertTrue(CGSizeEqualToSize(decodedImage1.size, testImage.size), @"Decoded image not same size as original!");
	
	// Set parameters
	testImage.codingQuality = 0.9;
	
	NSData *codedImageData2	= [self encodeImage:testImage];
	UIImage *decodedImage2	= [self decodeImage:codedImageData1];
	STAssertTrue(CGSizeEqualToSize(decodedImage2.size, testImage.size), @"Decoded image not same size as original!");
	
	STAssertTrue([codedImageData1 length] < [codedImageData2 length], @"Lower quality JPEG encoding was not smaller size!");
}

@end
