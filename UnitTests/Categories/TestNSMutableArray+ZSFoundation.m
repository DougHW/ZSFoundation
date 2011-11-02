//
//  TestNSMutableArray+ZSFoundation.m
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

#import "TestNSMutableArray+ZSFoundation.h"
#import "NSMutableArray+ZSFoundation.h"

@implementation TestNSMutableArray_ZSFoundation

- (void)testStackOperations {
	NSMutableArray *mutable = [[[NSMutableArray alloc] init] autorelease];
	[mutable push: @"push1"];
	[mutable push: @"push2"];
	[mutable push: @"push3"];
	[mutable push: @"push4"];
	
	NSArray *idealAfterPop = [NSArray arrayWithObjects:@"push1", @"push2", @"push3", nil];
	
	NSString *str = (NSString *)[mutable pop];
	STAssertEqualObjects(@"push4", str, @"pop result erroneous");
	STAssertTrue([idealAfterPop isEqualToArray:mutable], @"pop erroneous");
	
	str = [mutable peek];
	STAssertEqualObjects(@"push3", str, @"pop result erroneous");

	str = [mutable peek:1];
	STAssertEqualObjects(@"push2", str, @"pop result erroneous");
}

- (void)testQueueOperations {
	NSMutableArray *mutable = [[[NSMutableArray alloc] init] autorelease];
	[mutable enqueue: @"queue1"];
	[mutable enqueue: @"queue2"];
	[mutable enqueue: @"queue3"];
	[mutable enqueue: @"queue4"];
	
	NSArray *idealAfterDequeue1 = [NSArray arrayWithObjects:@"queue2", @"queue3", @"queue4", nil];
	NSArray *idealAfterDequeue2 = [NSArray arrayWithObjects:@"queue3", @"queue4", nil];
	NSArray *idealAfterDequeue3 = [NSArray arrayWithObjects:@"queue4", nil];
	NSArray *idealAfterDequeue4 = [NSArray arrayWithObjects:nil];
	
	NSString *str = (NSString *)[mutable dequeue];
	STAssertEqualObjects(@"queue1", str, @"dequeue result erroneous");
	STAssertTrue([idealAfterDequeue1 isEqualToArray:mutable], @"dequeue erroneous");
	
	str = (NSString *)[mutable dequeue];
	STAssertEqualObjects(@"queue2", str, @"dequeue result erroneous");
	STAssertTrue([idealAfterDequeue2 isEqualToArray:mutable], @"dequeue erroneous");
	
	str = (NSString *)[mutable dequeue];
	STAssertEqualObjects(@"queue3", str, @"dequeue result erroneous");
	STAssertTrue([idealAfterDequeue3 isEqualToArray:mutable], @"dequeue erroneous");
	
	str = (NSString *)[mutable dequeue];
	STAssertEqualObjects(@"queue4", str, @"dequeue result erroneous");
	STAssertTrue([idealAfterDequeue4 isEqualToArray:mutable], @"dequeue erroneous");

	// Should be nil and still have nothing
	str = (NSString *)[mutable dequeue];
	STAssertNil(str, @"dequeue result erroneous - should be nil");
	STAssertTrue([idealAfterDequeue4 isEqualToArray:mutable], @"dequeue erroneous");
}

@end
