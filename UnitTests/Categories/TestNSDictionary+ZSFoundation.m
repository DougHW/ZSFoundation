//
//  TestNSDictionary+ZSFoundation.m
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

#import "TestNSDictionary+ZSFoundation.h"
#import "NSString+ZSFoundation.h"


@implementation TestNSDictionary_ZSFoundation

- (void)testBuildQueryParameterString {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"v1",@"k1",
						  @"v2",@"k2",
						  @"v3",@"k3",
						  @"v4",@"k4",
						  nil];
	NSString *pString = [dict buildQueryParameterString];
	NSDictionary *unDict = [pString explodeOnInnerGlue:@"=" outerGlue:@"&"];
	STAssertTrue([dict isEqualToDictionary:unDict], @"buildQueryParameterString erroneous");
}

/**
 * Note that this relies on explodeOnInnerGlue:outerGlue: working. The reason for this is that we can easily
 * predict the output of that call, whereas the order of enumeration of keys in this method is not deterministic.
 */
- (void)testImplodeOnInnerGlueOuterGlue {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"v1",@"k1",
						  @"v2",@"k2",
						  @"v3",@"k3",
						  @"v4",@"k4",
						  nil];
	NSString *pString = [dict implodeOnInnerGlue:@"=" outerGlue:@"&"];
	NSDictionary *unDict = [pString explodeOnInnerGlue:@"=" outerGlue:@"&"];
	STAssertTrue([dict isEqualToDictionary:unDict], @"implodeOuter erroneous");
}

@end
