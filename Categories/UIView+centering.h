//
//  UIView+centering.h
//  ZSFoundation
//
//  Created by Doug Wehmeier on 4/8/11.
//  Copyright 2011 Zoosk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIView (ZSFoundation_centering)
    
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
