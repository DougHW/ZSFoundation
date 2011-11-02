//
//  UIView+ZSFoundation.m
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

#import "UIView+ZSFoundation.h"


@implementation UIView (UIView_ZSFoundation)

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
