//
//  UIView+ZSFoundation.h
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


@interface UIView (UIView_ZSFoundation)
    
/**
 * Returns the center point of the UIView's bounds, in its local coordinate system
 * NOTE: This will round to even pixel boundaries
 */
@property (readonly, nonatomic)		CGPoint		boundsCenter;

/**
 * Centers a view, and makes sure that the result falls on even pixel boundaries.
 * When not animating a transition, you should always use this method instead of setting center directly.
 *
 * @param	newCenter	The view will be centered on this point, shifted to the nearest even pixel
 */
- (void)setEvenCenter:(CGPoint)newCenter;

@end
