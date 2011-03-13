//
//  TestZSLowMemoryPool.m
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

#import "TestZSLowMemoryPool.h"
#import "ZSLowMemoryPool.h"


@implementation TestZSLowMemoryPool

const char *byte_to_binary
(
 int x
 )
{
    static char b[9];
    b[0] = '\0';
	
    int z;
    for (z = 256; z > 0; z >>= 1)
    {
        strcat(b, ((x & z) == z) ? "1" : "0");
    }
	
    return b;
}

- (NSString *)byteToBinary:(unsigned int)x {
	NSString *retString = [NSString string];
	
	int z;
	for (z = 256; z > 0; z >>= 1) {
		retString = [NSString stringWithFormat:@"%@%@", retString, ((x & z) == z) ? "1" : "0"];
	}
	
	return retString;
}

- (void)testAddAndRemove {
	// Initialize and add to pool
	NSString *testString = [[NSString alloc] initWithFormat:@"TEST"];
	STAssertTrue(1 == [testString retainCount], @"Incorrect retain count!");
	[[ZSLowMemoryPool lowMemoryPool] addPointer:&testString];
	STAssertTrue(2 == [testString retainCount], @"Incorrect retain count!");
	
	// Release and test
	[testString release];
	STAssertTrue(nil != testString, @"String nil before removal!");
	STAssertTrue(1 == [testString retainCount], @"Incorrect retain count!");
	
	// Create another pointer
	NSString *testString2 = [testString retain];
	STAssertTrue(2 == [testString retainCount], @"Incorrect retain count!");
	
	// Remove from pool and test
	[[ZSLowMemoryPool lowMemoryPool] removePointer:&testString];
	STAssertTrue(nil != testString, @"Pointer changed to nil incorrectly!");
	STAssertTrue(1 == [testString2 retainCount], @"Incorrect retain count!");
	
	NSLog(@"sizeof(void*) %d", sizeof(void*));
	NSLog(@"sizeof(CGFloat) %d", sizeof(CGFloat));
	NSLog(@"sizeof(CGSize) %d", sizeof(CGSize));
	
	UIView *aView = nil;
	UIView *anotherView = [[[UIView alloc] initWithFrame:CGRectMake(50.0, 100.0, 150.0, 200.0)] autorelease];
	CGSize bSize = anotherView.frame.size;
	CGSize aSize = aView.frame.size;
	NSLog(@"nil size %@", NSStringFromCGSize(aSize));
	
	ufloat u1;
	u1.f = aSize.width;
	NSLog(@"binary nil width %d", u1.u);
}

- (void)testLowMemoryClear {
	// Initialize and add to pool
	NSString *testString = [[NSString alloc] initWithFormat:@"TEST"];
	STAssertTrue(1 == [testString retainCount], @"Incorrect retain count!");
	[[ZSLowMemoryPool lowMemoryPool] addPointer:&testString];
	STAssertTrue(2 == [testString retainCount], @"Incorrect retain count!");
	
	// Release and test
	[testString release];
	STAssertTrue(nil != testString, @"String nil before removal!");
	STAssertTrue(1 == [testString retainCount], @"Incorrect retain count!");
	
	// Create another pointer
	NSString *testString2 = [testString retain];
	STAssertTrue(2 == [testString retainCount], @"Incorrect retain count!");
	
	// Fake a low memory event
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UIApplicationDidReceiveMemoryWarningNotification object:nil]];
	STAssertTrue(nil == testString, @"Pointer not changed to nil correctly!");
	STAssertTrue(nil != testString2, @"Pointer changed to nil incorrectly!");
	STAssertTrue(1 == [testString2 retainCount], @"Incorrect retain count!");
}

- (void)testThreadSingleton {
	ZSLowMemoryPool *mainThreadPool = [ZSLowMemoryPool lowMemoryPool];
	STAssertNotNil(mainThreadPool, @"ZSLowMemoryPool singleton nil on main thread!");
	
	// Check pool on another thread
	[NSThread detachNewThreadSelector:@selector(helperTestThreadSingleton:) toTarget:self withObject:mainThreadPool];
}

- (void)helperTestThreadSingleton:(ZSLowMemoryPool *)aPool {
	NSAutoreleasePool *autoreleasePool = [[NSAutoreleasePool alloc] init];
	
	STAssertFalse([[NSThread currentThread] isMainThread], @"Thread did not detach properly!");
	
	ZSLowMemoryPool *anotherPool = [ZSLowMemoryPool lowMemoryPool];
	STAssertTrue(aPool != anotherPool, @"Pools equal when they should not be!");
	
	[autoreleasePool drain];
}

@end
