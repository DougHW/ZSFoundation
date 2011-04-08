//
//  UIView+centering.m
//  ZSFoundation
//
//  Created by Doug Wehmeier on 4/8/11.
//  Copyright 2011 Zoosk. All rights reserved.
//

#import "UIView+centering.h"


@implementation UIView (ZSFoundation_centering)

- (CGPoint)boundsCenter {
	return CGPointMake(roundf(self.bounds.size.width / 2.0), roundf(self.bounds.size.height / 2.0));
}

- (void)setEvenCenter:(CGPoint)newCenter {
	/**
	 * I realize this is a bit inefficient, but I set the center first and then
	 * round the resulting position because I don't know what side-effects Apple
	 * has put into the setCenter: method.  Want to make sure they're triggered.
	 */
	self.center = newCenter;
	CGRect newFrame		= self.frame;
	newFrame.origin.x	= roundf(newFrame.origin.x);
	newFrame.origin.y	= roundf(newFrame.origin.y);
	self.frame			= newFrame;
}

@end
