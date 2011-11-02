//
//  UIFont+ZSFoundation.h
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

@interface UIFont (UIFont_ZSFoundation)

/**
 * Returns the maximum height of a line in a font by taking the highest y-coordinate of the highest-reaching glyph in a 
 * font and subtracting the lowest y-coordinate of the lowest-reaching glyph and adding one.
 *
 * @returns	Line height
 */
- (CGFloat)fontLineHeight;

@end
