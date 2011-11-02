//
//  TestNSURL+ZSFoundation.m
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

#import "TestNSURL+ZSFoundation.h"
#import "NSURL+ZSFoundation.h"

@implementation TestNSURL_ZSFoundation

- (void)testPathArray {
	NSURL *url = [NSURL URLWithString:@"http://this/is/an/url?with=some&param=eters"];
	NSArray *idealPathArray = [NSArray arrayWithObjects:@"is", @"an", @"url",nil];
	
	STAssertTrue([idealPathArray isEqualToArray:[url pathArray]], @"pathArray is erroneous");
}

- (void)testQueryDictionary {
	NSURL *url = [NSURL URLWithString:@"http://this/is/an/url?with=some&param=eters"];
	NSDictionary *idealQueryDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
										  @"eters", @"param",
										  @"some", @"with",
										  nil];
	
	STAssertTrue([idealQueryDictionary isEqualToDictionary:[url queryDictionary]], @"queryDictionary is erroneous");
}

@end
