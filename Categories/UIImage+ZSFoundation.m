//
//  UIImage+ZSFoundation.m
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

#import "UIImage+ZSFoundation.h"
#import <objc/runtime.h>
#import "ZSFloat.h"
#import "ZSUInteger.h"


#define DEFAULT_CODING_QUALITY 0.7

static char CODING_FORMAT_KEY;
static char CODING_QUALITY_KEY;

@implementation UIImage (UIImage_ZSFoundation)

@dynamic codingFormat, codingQuality;

- (UIImageNSCodingFormat)codingFormat {
	ZSUInteger *associatedFormat = (ZSUInteger *)objc_getAssociatedObject(self, &CODING_FORMAT_KEY);
	if (!associatedFormat) {
		associatedFormat = [[ZSUInteger alloc] initWithUInteger:UIImageNSCodingFormatJPEG];
		objc_setAssociatedObject(self, &CODING_FORMAT_KEY, associatedFormat, OBJC_ASSOCIATION_RETAIN);
		[associatedFormat release];
	}
	
	return associatedFormat.value;
}

- (void)setCodingFormat:(UIImageNSCodingFormat)codingFormat {
	ZSUInteger *associatedFormat = [[ZSUInteger alloc] initWithUInteger:codingFormat];
	objc_setAssociatedObject(self, &CODING_FORMAT_KEY, associatedFormat, OBJC_ASSOCIATION_RETAIN);
	[associatedFormat release];
}

- (CGFloat)codingQuality {
	ZSFloat *associatedQuality = (ZSFloat *)objc_getAssociatedObject(self, &CODING_QUALITY_KEY);
	if (!associatedQuality) {
		associatedQuality = [[ZSFloat alloc] initWithFloat:DEFAULT_CODING_QUALITY];
		objc_setAssociatedObject(self, &CODING_QUALITY_KEY, associatedQuality, OBJC_ASSOCIATION_RETAIN);
		[associatedQuality release];
	}
	
	return associatedQuality.value;
}

- (void)setCodingQuality:(CGFloat)codingQuality {
	ZSFloat *associatedQuality = [[ZSFloat alloc] initWithFloat:codingQuality];
	objc_setAssociatedObject(self, &CODING_QUALITY_KEY, associatedQuality, OBJC_ASSOCIATION_RETAIN);
	[associatedQuality release];
}


#pragma mark -
#pragma mark NSCoding methods

- (id)initWithCoder:(NSCoder *)coder {
	NSData *decodedData = [coder decodeObjectForKey:@"UIImage.data"];
	if (decodedData) {
		return [(UIImage *)[[self class] alloc] initWithData:decodedData];
	}
	
	return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	switch (self.codingFormat) {
		case UIImageNSCodingFormatJPEG: {
			NSData *encodedData = UIImageJPEGRepresentation(self, self.codingQuality);
			[coder encodeObject:encodedData forKey:@"UIImage.data"];
			break;
		}
		case UIImageNSCodingFormatPNG: {
			NSData *encodedData = UIImagePNGRepresentation(self);
			[coder encodeObject:encodedData forKey:@"UIImage.data"];
			break;
		}
		default:
			break;
	}
}

@end
