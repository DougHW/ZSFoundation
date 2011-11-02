//
//  NSInvocation+ZSFoundation.m
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

#import "NSInvocation+ZSFoundation.h"

@implementation NSInvocation (NSInvocation_ZSFoundation)

+ (NSInvocation *)invocationWithTarget:(id)aTarget selector:(SEL)aSelector arguments:(void *)args, ... {
	// Create our invocation
	NSMethodSignature *targetMethodSignature = [aTarget methodSignatureForSelector:aSelector];
	NSInvocation *newInvocation = [NSInvocation invocationWithMethodSignature:targetMethodSignature];
	[newInvocation retainArguments];
	
	// Set target and selector for invocation
	[newInvocation setTarget:aTarget];
	[newInvocation setSelector:aSelector];
	
	// Get our parameter list
	va_list arg_list;
	va_start(arg_list, args);
	
	// Loop through and add them to our invocation
	NSUInteger argumentCount = [targetMethodSignature numberOfArguments];
	void *currentArg = args;
	for (NSUInteger i = 2; i < argumentCount; i++) {
		[newInvocation setArgument:&currentArg atIndex:i];
		currentArg = va_arg(arg_list, void *);
	}
	
	// End parameter list loop
	va_end(arg_list);
	
	return newInvocation;
}

@end
