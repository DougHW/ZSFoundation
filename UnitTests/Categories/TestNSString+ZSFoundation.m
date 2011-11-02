//
//  TestNSString+ZSFoundation.m
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

#import "TestNSString+ZSFoundation.h"
#import "NSString+ZSFoundation.h"

@implementation TestNSString_ZSFoundation

- (void)testIsNotEmpty {
	STAssertTrue([@"fgsfds" isNotEmpty], @"Erroneous isNotEmpty output");
	STAssertFalse([@"		 " isNotEmpty], @"Erroneous isNotEmpty output");
}

- (void)testStringDecodedForUrl {
	NSString *str = @"pathological-parameter-!*'();:@&=+$,/?%#[] /`<>";
	NSString *decodedStr = [@"pathological-parameter-%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%25%23%5B%5D%20%2F%60%3C%3E"
							stringDecodedFromUrl];
	STAssertEqualObjects(str,
						 decodedStr,
						 @"erroneous stringDecodedFromUrl result");

}

- (void)testStringEncodedFromUrl {
	NSString *str = @"pathological-parameter-%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%25%23%5B%5D%20%2F%60%3C%3E";
	NSString *encodedStr = [@"pathological-parameter-!*'();:@&=+$,/?%#[] /`<>" stringEncodedForUrl];
	STAssertEqualObjects(str,
						 encodedStr,
						 @"erroneous stringEncodedFromUrl result");
	
	
}

@end
