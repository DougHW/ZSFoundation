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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UINavigationController (UINavigationController_ZSFoundation)

/**
 * Searches the view controller stack for a class using isKindOfClass
 *
 * @param	aClass		The class to look for (isKindOfClass)
 */
- (BOOL)containsKindOfClass:(Class)aClass;

/**
 * Searches the view controller stack for a class using isMemberOfClass
 *
 * @param	aClass		The class to look for (isMemberOfClass)
 */
- (BOOL)containsMemberOfClass:(Class)aClass;

/**
 * Pops to the first occurance of a view controller that isKindOfClass
 *
 * @param	aClass		The class to pop to (isKindOfClass)
 * @param	animated	Set this value to YES to animate the transition. Pass NO if you are setting up a navigation controller before its view is displayed.
 * @return				An array containing the view controllers that were popped from the stack.
 */
- (NSArray *)popToKindOfClass:(Class)aClass animated:(BOOL)animated;

/**
 * Pops to the first occurance of a view controller that isMemberOfClass
 *
 * @param	aClass		The class to pop to (isMemberOfClass)
 * @param	animated	Set this value to YES to animate the transition. Pass NO if you are setting up a navigation controller before its view is displayed.
 * @return				An array containing the view controllers that were popped from the stack.
 */
- (NSArray *)popToMemberOfClass:(Class)aClass animated:(BOOL)animated;

@end
