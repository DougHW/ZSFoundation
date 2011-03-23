//
//  UIImage+NSCoding.h
//  ZSFoundation
//
//  Created by Doug Wehmeier on 3/23/11.
//  Copyright 2011 Zoosk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef enum {
	UIImageNSCodingFormatJPEG,
	UIImageNSCodingFormatPNG
} UIImageNSCodingFormat;

@interface UIImage (NSCoding) <NSCoding>

@property (nonatomic)	UIImageNSCodingFormat	codingFormat;
@property (nonatomic)	CGFloat					codingQuality;

@end
