//
//  NSDictionary+ZSFoundation.h
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

#import "NSDictionary+ZSFoundation.h"
#import "NSString+ZSFoundation.h"

@implementation NSDictionary (NSDictionary_ZSFoundation)

- (NSString *)buildQueryParameterString {
	NSMutableArray *pieces = [[[NSMutableArray alloc] initWithCapacity:[self count]] autorelease];
	
	// Iterate over each get parameter
	for (NSString *key in self) {
		id object = [self objectForKey:key];
		
		if ([object conformsToProtocol:@protocol(NSFastEnumeration)]) {
			
			// It's a collection of values corresponding to the same key -- name will be post-fixed with []
			NSUInteger index = 0; // count = [(NSArray *)object count];
			for (id element in (id<NSFastEnumeration>)object) {
				
				// For dictionaries, recursively build the parameter string
				if ([element isKindOfClass:[NSDictionary class]]) {
					element = [element buildQueryParameterString];
				}
				
				[pieces addObject:[NSString stringWithFormat:
								   @"%@[]=%@",
								   [key stringEncodedForUrl],
								   [(NSString *)element stringEncodedForUrl]]];
				
				index++;
			}
			
		} else {
			
			// Otherwise just add it normally
			[pieces addObject:[NSString stringWithFormat:
							   @"%@=%@",
							   [key stringEncodedForUrl],
							   [(NSString *)object stringEncodedForUrl]]];
			
		}
	}
	
	return [pieces componentsJoinedByString:@"&"];
}

- (NSString *)implodeOnInnerGlue:(NSString *)innerGlue outerGlue:(NSString *)outerGlue {
	NSMutableArray *pieces = [[[NSMutableArray alloc] initWithCapacity:[self count]] autorelease];
	
	for (id key in self) {
		[pieces addObject:[NSString stringWithFormat:@"%@%@%@", key, innerGlue, [self objectForKey:key]]];
	}
	
	return [pieces componentsJoinedByString:outerGlue];
}

@end
