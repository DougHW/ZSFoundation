//
//  UIImage+ZSFoundation.h
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


/**
 * Type of encoding to use when encoding image via NSCoding
 */
typedef enum {
	UIImageNSCodingFormatJPEG,
	UIImageNSCodingFormatPNG
} UIImageNSCodingFormat;

/**
 * This category on UIImage is intended to add NSCoding capabilities to UIImage.
 * The main problem with this is that there are a number of different formats
 * to encode a UIImage in.
 * This will default to JPEG format with a quality of 0.7
 */
@interface UIImage (UIImage_ZSFoundation) <NSCoding>

@property (nonatomic)	UIImageNSCodingFormat	codingFormat;
@property (nonatomic)	CGFloat					codingQuality;

@end
