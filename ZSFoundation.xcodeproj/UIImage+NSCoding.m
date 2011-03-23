//
//  UIImage+NSCoding.m
//  ZSFoundation
//
//  Created by Doug Wehmeier on 3/23/11.
//  Copyright 2011 Zoosk. All rights reserved.
//

#import "UIImage+NSCoding.h"
#import <objc/runtime.h>
#import "ZSFloat.h"
#import "ZSUInteger.h"


#define DEFAULT_CODING_QUALITY 0.7

static char CODING_FORMAT_KEY;
static char CODING_QUALITY_KEY;

@implementation UIImage (NSCoding)

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
