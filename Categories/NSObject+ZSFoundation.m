//
//  NSObject+ZSFoundation.m
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

/**
 * The following code was adapted from code available at https://gist.github.com/1323909
 * and is subject to the following license, commonly referred to as "the MIT license".
 *
 * Copyright (c) 2011 Zachary J. Gramana
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "NSObject+ZSFoundation.h"

@implementation NSObject (NSObject_ZSFoundation)

- (void)performSelectorInBackground:(SEL)aSelector withParameters:(void *)params, ... {
	// Create our invocation
	NSMethodSignature *targetMethodSignature = [self methodSignatureForSelector:aSelector];
	NSInvocation *newInvocation = [NSInvocation invocationWithMethodSignature:targetMethodSignature];
	[newInvocation retainArguments];
	
	// Set target and selector for invocation
	[newInvocation setTarget:self];
	[newInvocation setSelector:aSelector];
	
	// Get our parameter list
	va_list arg_list;
	va_start(arg_list, params);
	
	// Loop through and add them to our invocation
	NSUInteger argumentCount = [targetMethodSignature numberOfArguments];
	void *currentArg = params;
	for (NSUInteger i = 2; i < argumentCount; i++) {
		[newInvocation setArgument:&currentArg atIndex:i];
		currentArg = va_arg(arg_list, void *);
	}
	
	// End parameter list loop
	va_end(arg_list);
	
	// Call it!
	[newInvocation performSelectorInBackground:@selector(invoke) withObject:nil];
}

@end
