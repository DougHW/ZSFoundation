//
//  UINavigationController+ZSFoundation.h
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


#import "UINavigationController+ZSFoundation.h"

@implementation UINavigationController (UINavigationController_ZSFoundation)

- (BOOL)containsKindOfClass:(Class)aClass {
	for (UIViewController *tViewController in self.viewControllers) {
		if ([tViewController isKindOfClass:aClass]) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)containsMemberOfClass:(Class)aClass {
	for (UIViewController *tViewController in self.viewControllers) {
		if ([tViewController isMemberOfClass:aClass]) {
			return YES;
		}
	}
	return NO;
}

- (NSArray *)popToKindOfClass:(Class)aClass animated:(BOOL)animated {
	UIViewController *foundController = nil;
	
	for (UIViewController *tViewController in self.viewControllers) {
		if ([tViewController isKindOfClass:aClass]) {
			foundController = [[tViewController retain] autorelease];
			break;
		}
	}
	
	if (foundController) {
		return [self popToViewController:foundController animated:animated];
	}
	
	return nil;
}

- (NSArray *)popToMemberOfClass:(Class)aClass animated:(BOOL)animated {
	UIViewController *foundController = nil;
	
	for (UIViewController *tViewController in self.viewControllers) {
		if ([tViewController isMemberOfClass:aClass]) {
			foundController = [[tViewController retain] autorelease];
			break;
		}
	}
	
	if (foundController) {
		return [self popToViewController:foundController animated:animated];
	}
	
	return nil;
}

@end
