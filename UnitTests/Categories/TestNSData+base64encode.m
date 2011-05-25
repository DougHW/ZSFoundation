//
//  TestNSData+base64encode.m
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

#import "TestNSData+base64encode.h"
#import "NSData+base64encode.h"
#import "NSString+base64decode.h"


@implementation TestNSData_base64encode

- (void)testEncodeDecode {
	NSString *testString = @"With so much drama in the LBC it's kinda hard bein' Snoop D O double G.";
	NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([testData length] > 0, @"Invalid test NSData");
	
	NSString *base64String = [testData base64encoding];
	STAssertTrue([base64String length] > 0, @"base64 encoded string not encoded properly");
	
	NSData *decodedData = [base64String base64decoding];
	STAssertTrue(decodedData != testData, @"Decoded data points to same variable as pre-encoded data!");
	STAssertTrue([decodedData isEqualToData:testData], @"Decoded data not equal to original!");
}

@end
