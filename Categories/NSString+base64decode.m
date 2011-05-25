//
//  NSString+base64decode.m
//  ZSFoundation
//
//  Created by Doug Wehmeier on 5/24/11.
//  Copyright 2011 Zoosk. All rights reserved.
//

#import "NSString+base64decode.h"


@implementation NSString (ZSFoundation_base64decode)

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

@end
