//
//  NSString+ZSFoundation.h
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


@interface NSString (NSString_ZSFoundation)

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

/**
 * Calculates the maximum font size at which all strings in an array can fit a given width, and returns their respective rects.
 *
 * @param	strings			An NSArray of NSStrings to be measureed
 * @param	font
 * @param	minFontSize
 * @param	actualFontSize
 * @param	width
 * @param	lineBreakMode
 * @return					An array of NSValues encapsulating CGRect values
 */
+ (NSArray *)groupSizeForStrings:(NSArray *)strings withFont:(UIFont *)font minFontSize:(CGFloat)minFontSize actualFontSize:(CGFloat *)actualFontSize forWidth:(CGFloat)width lineBreakMode:(UILineBreakMode)lineBreakMode;

/**
 * Returns the string that will fit in a given rectangle with a given truncation style
 */
- (NSString *)stringThatFitsInSize:(CGSize)aSize withFont:(UIFont *)aFont minFontSize:(CGFloat)minFontSize actualFontSize:(CGFloat *)actualFontSize lineBreakMode:(UILineBreakMode)lineBreakMode;

// Do not add this method
// It does not exist because it creates unexpected behavior if the object is nil
//- (BOOL)isEmpty;
//- (BOOL)isEmpty;

/**
 * Returns true if the string contains anything other than whitespace.
 *
 * @return	Non-emptiness of the string
 */
- (BOOL)isNotEmpty;

/**
 * This is NOT an exhaustive algorithm.
 * It is extremely permissive and only checks that the email address contains one and only one '@' character.
 * Even this is not technically correct, but email addresses with more than one '@' are not used in practice.
 *
 * @return	Email address-ness of string
 */
- (BOOL)isEmailAddress;

/**
 * Returns an URL-encoded copy of the string.
 *
 * @return	URL-encoded string
 */
- (NSString *)stringEncodedForUrl;

/**
 * Returns an URL-decoded copy of the string.
 *
 * @return	URL-decoded string
 */
- (NSString *)stringDecodedFromUrl;

/**
 * Extracts keys and values joined with innerGlue and delimited by outerGlue.
 *
 * @param	innerGlue	String that glues keys and values
 * @param	outerGlue	String that separates key-value pairs
 * @return				Exploded string
 */
- (NSMutableDictionary *)explodeOnInnerGlue:(NSString *)innerGlue outerGlue:(NSString *)outerGlue;

/**
 * Computes the md5 hash of this string. Code taken from http://stackoverflow.com/questions/1524604/md5-algorithm-in-objective-c
 */
- (NSString *)md5;

@end
