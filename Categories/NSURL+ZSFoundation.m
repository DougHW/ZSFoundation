//
//  NSURL+ZSFoundation.m
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

#import "NSURL+ZSFoundation.h"
#import "NSString+ZSFoundation.h"

@implementation NSURL (NSURL_ZSFoundation)

- (NSString *)resourceIdentifier {
	NSArray *pathComponents = [self pathComponents];
	NSString *identifier = [pathComponents lastObject];
	
	if (![identifier isEqualToString:@"/"]) {
		return identifier;
	}
	
	return nil;
}

- (NSArray *)pathArray {
	// Create a character set for the slash character
	NSRange slashRange;
	slashRange.location = (unsigned int)'/';
	slashRange.length = 1;
	NSCharacterSet *slashSet = [NSCharacterSet characterSetWithRange:slashRange];
	
	// Get path with leading (and trailing) slashes removed
	NSString *path = [[self path] stringByTrimmingCharactersInSet:slashSet];
	
	return [path componentsSeparatedByCharactersInSet:slashSet];
}

- (NSDictionary *)queryDictionary {
	NSDictionary *returnDictionary = [[[[self query] explodeOnInnerGlue:@"=" outerGlue:@"&"] copy] autorelease];
	return returnDictionary;
}

@end
