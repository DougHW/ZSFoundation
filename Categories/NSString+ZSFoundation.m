//
//  NSString+ZSFoundation.m
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

#import "NSString+ZSFoundation.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (NSString_ZSFoundation)

/**
 * Some of the following code was adapted from PHP Version 5 and is subject to the PHP License 3.01
 * http://www.php.net/license/3_01.txt
 *
 +----------------------------------------------------------------------+
 | base64.c                                                             |
 |                                                                      |
 | PHP Version 5                                                        |
 +----------------------------------------------------------------------+
 | Copyright (c) 1997-2011 The PHP Group                                |
 +----------------------------------------------------------------------+
 | This source file is subject to version 3.01 of the PHP license,      |
 | that is bundled with this package in the file LICENSE, and is        |
 | available through the world-wide-web at the following url:           |
 | http://www.php.net/license/3_01.txt                                  |
 | If you did not receive a copy of the PHP license and are unable to   |
 | obtain it through the world-wide-web, please send a note to          |
 | license@php.net so we can mail you a copy immediately.               |
 +----------------------------------------------------------------------+
 | Author: Jim Winstead <jimw@php.net>                                  |
 +----------------------------------------------------------------------+
 */

// base64 encode table
static const short base64_reverse_table[256] = {
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -2, -1, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
	52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
	-2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
	15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
	-2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
	41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

#define BASE64_PAD '='

- (NSData *)base64decoding {
	return [self base64decodingStrict:NO];
}

- (NSData *)base64decodingStrict:(BOOL)strict {
	const char *current = [self cStringUsingEncoding:NSASCIIStringEncoding];
	int length = strlen(current);
	int ch, i = 0, j = 0, k;
	/* this sucks for threaded environments */
	char *result;
	
	result = (char *)calloc(length, sizeof(char));
	
	/* run through the whole string, converting as we go */
	while ((ch = *current++) != '\0' && length-- > 0) {
		if (ch == BASE64_PAD) {
			if (*current != '=' && ((i % 4) == 1 || (strict && length > 0))) {
				free(result);
				return nil;
			}
			continue;
		}
		
		ch = base64_reverse_table[ch];
		if ((!strict && ch < 0) || ch == -1) { /* a space or some other separator character, we simply skip over */
			continue;
		} else if (ch == -2) {
			free(result);
			return nil;
		}
		
		switch(i % 4) {
			case 0:
				result[j] = ch << 2;
				break;
			case 1:
				result[j++] |= ch >> 4;
				result[j] = (ch & 0x0f) << 4;
				break;
			case 2:
				result[j++] |= ch >>2;
				result[j] = (ch & 0x03) << 6;
				break;
			case 3:
				result[j++] |= ch;
				break;
		}
		i++;
	}
	
	k = j;
	/* mop things up if we ended on a boundary */
	if (ch == BASE64_PAD) {
		switch(i % 4) {
			case 1:
				free(result);
				return nil;
			case 2:
				k++;
			case 3:
				result[k] = 0;
		}
	}
	result[j] = '\0';
	
	NSData *returnData = [[[NSData alloc] initWithBytes:result length:j] autorelease];
	free(result);
	return returnData;
}

+ (NSArray *)groupSizeForStrings:(NSArray *)strings withFont:(UIFont *)font minFontSize:(CGFloat)minFontSize actualFontSize:(CGFloat *)actualFontSize forWidth:(CGFloat)width lineBreakMode:(UILineBreakMode)lineBreakMode {
	if (!strings || [strings count] < 1) {
		// No strings
		return nil;
	}
	
	if ([strings count] == 1) {
		// Only one string
		CGSize returnSize = [(NSString *)[strings objectAtIndex:0] sizeWithFont:font minFontSize:minFontSize actualFontSize:actualFontSize forWidth:width lineBreakMode:lineBreakMode];
		return [NSArray arrayWithObject:[NSValue valueWithCGSize:returnSize]];
	}
	
	NSString *spaceString = @" ";
	
	for (CGFloat currentFontSize = font.pointSize; currentFontSize >= minFontSize; currentFontSize -= 1.0) {
		
		CGFloat totalWidth			= 0.0;
		NSMutableArray *stringSizes	= [[NSMutableArray alloc] initWithCapacity:[strings count]];
		UIFont *currentFont			= [font fontWithSize:currentFontSize];
		
		// Calculate size of a space so strings aren't against each other
		CGSize spaceSize = [spaceString sizeWithFont:currentFont forWidth:width lineBreakMode:lineBreakMode];
		
		// Add up the width of each string
		NSUInteger i = 0;
		for (NSString *aString in strings) {
			CGSize stringSize = [aString sizeWithFont:currentFont forWidth:width lineBreakMode:lineBreakMode];
			
			// If this is not the first string, add the space width
			if (i > 0) {
				totalWidth += spaceSize.width;
			}
			
			// Calculate the rect and add it
			[stringSizes addObject:[NSValue valueWithCGRect:CGRectMake(totalWidth, 0.0, stringSize.width, stringSize.height)]];
			
			// Add the values up
			totalWidth += stringSize.width;
			i++;
		}
		
		if (totalWidth <= width) {
			// Width is acceptable
			*actualFontSize = currentFontSize;
			
			NSArray *returnArray = [[[NSArray alloc] initWithArray:stringSizes] autorelease];
			[stringSizes release];
			return returnArray;
		} else {
			[stringSizes release];
		}
	}
	
	return nil;
}

- (NSString *)stringThatFitsInSize:(CGSize)aSize withFont:(UIFont *)aFont minFontSize:(CGFloat)minFontSize actualFontSize:(CGFloat *)actualFontSize lineBreakMode:(UILineBreakMode)lineBreakMode {
	if (lineBreakMode != UILineBreakModeWordWrap && lineBreakMode != UILineBreakModeCharacterWrap) {
		return nil;
	}
	
	UIFont *currentFont			= aFont;
	*actualFontSize				= currentFont.pointSize;
	NSString *currentString		= [self copy];
	CGSize currentSize			= CGSizeZero;
	
	// Loop to see if the whole text will fit
	while (*actualFontSize >= minFontSize) {
		currentSize = [currentString sizeWithFont:currentFont constrainedToSize:CGSizeMake(aSize.width, CGFLOAT_MAX) lineBreakMode:lineBreakMode];
		
		if (currentSize.height <= aSize.height) {
			return currentString;
		}
		
		*actualFontSize = *actualFontSize - 1.0;
		currentFont = [currentFont fontWithSize:*actualFontSize];
	}
	
	// Set font to minimum size
	*actualFontSize = minFontSize;
	currentFont = [currentFont fontWithSize:*actualFontSize];
	
	// Initialize for search
	NSUInteger lowIndex = 0;
	NSUInteger highIndex = [currentString length];
	NSUInteger currentIndex;
	NSString *testString = nil;
	
	while (highIndex > lowIndex) {
		if (lowIndex == 0) {
			CGFloat overageRatio = aSize.height / currentSize.height;
			currentIndex = roundf(highIndex * overageRatio);
		} else {
			currentIndex = lowIndex + roundf((highIndex - lowIndex) / 2);
		}
		
		
		testString = [[currentString substringToIndex:currentIndex] stringByAppendingString:@"..."];
		currentSize = [testString sizeWithFont:currentFont constrainedToSize:CGSizeMake(aSize.width, CGFLOAT_MAX) lineBreakMode:lineBreakMode];
		
		if (currentSize.height > aSize.height) {
			highIndex = [testString length] - 4;
		} else {
			lowIndex = [testString length] - 2;
		}
	}
	
	return testString;
}

- (BOOL)isNotEmpty {
	return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0;
}

- (BOOL)isEmailAddress {
	NSRange atRange = [self rangeOfString:@"@"];
	
	if (atRange.location != NSNotFound) {
		NSRange otherAtRange = [self rangeOfString:@"@" options:NSBackwardsSearch];
		if (NSEqualRanges(atRange, otherAtRange)) {
			return YES;
		}
	}
	
	return NO;
}

- (NSString *)stringEncodedForUrl {
	NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																				  NULL,
																				  (CFStringRef)self,
																				  NULL,
																				  (CFStringRef)@"!*'();:@&=+$,/?%#[] ",
																				  kCFStringEncodingUTF8);
	return [encodedString autorelease];
}

- (NSString*)stringDecodedFromUrl {
	// Replace + signs with spaces first
	NSString *tString = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
	
	NSString *decodedString = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
																								  NULL,
																								  (CFStringRef)tString,
																								  CFSTR(""),
																								  kCFStringEncodingUTF8);
	return [decodedString autorelease];
}

- (NSMutableDictionary *)explodeOnInnerGlue:(NSString *)innerGlue outerGlue:(NSString *)outerGlue {
	// Explode based on outer glue
	NSArray *firstExplode = [self componentsSeparatedByString:outerGlue];
	NSArray *secondExplode;
	
	// Explode based on inner glue
	NSInteger count = [firstExplode count];
	NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithCapacity:count];
	for (NSInteger i = 0; i < count; i++) {
		secondExplode = [(NSString *)[firstExplode objectAtIndex:i] componentsSeparatedByString:innerGlue];
		if ([secondExplode count] == 2) {
			[returnDictionary setObject:[secondExplode objectAtIndex:1] forKey:[secondExplode objectAtIndex:0]];
		}
	}
	
	return returnDictionary;
}

- (NSString *)md5 {
	const char *cStr = [self UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

@end
