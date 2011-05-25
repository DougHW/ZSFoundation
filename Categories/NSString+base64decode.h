//
//  NSString+base64decode.h
//  ZSFoundation
//
//  Created by Doug Wehmeier on 5/24/11.
//  Copyright 2011 Zoosk. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (ZSFoundation_base64decode)

/**
 * Calls base64decodingStrict: with strict=NO
 */
- (NSData *)base64decoding;

/**
 * Decodes a (presumably) base64 encoded string into a byte array.
 *
 * @param	strict		If YES, then spaces and other invalid characters will cause a failure (return nil).  If NO, these characters are simply skipped.
 * @return				The decoded 
 */
- (NSData *)base64decodingStrict:(BOOL)strict;

@end
