//
//  TestAbstractStore.m
//  Zoosk
//
//  Created by James Infusino on 10/7/11.
//  Copyright 2011 Zoosk, Inc. All rights reserved.
//

#import "TestAbstractStore.h"
#import "AbstractStore.h"



@interface ALocalClassThatRespondsToApple : NSObject {
@private
    
}

- (NSString *)apple;

@end

@implementation ALocalClassThatRespondsToApple

- (NSString *)apple {
	return @"I Like Apples";
}

@end

@interface ALocalClassThatRespondsToPear : NSObject {
@private
    
}

- (NSString *)pear;

@end

@implementation ALocalClassThatRespondsToPear

- (NSString *)pear {
	return @"I Like Pears";
}

@end


@implementation TestAbstractStore


- (void)testInit {
    
	AbstractStore *testAbstractStore = [[AbstractStore alloc] init];
	
	STAssertNotNil(testAbstractStore, @"TestAbstractStore: Unable to allocate an Abstract store");
	
	STAssertNotNil(testAbstractStore.delegates, @"TestAbstractStore: did not allocate delegates instance var");

	STAssertTrue(testAbstractStore.delegates.count == 0, @"TestAbstractStore: did not allocate empty instance var");
	
	[testAbstractStore release];
}

- (void)testAddDelegateRemoveDelegate {

	AbstractStore *testAbstractStore = [[AbstractStore alloc] init];
	
	STAssertNotNil(testAbstractStore, @"TestAbstractStore: Unable to allocate an Abstract store");
	
	STAssertNotNil(testAbstractStore.delegates, @"TestAbstractStore: did not allocate delegates instance var");
	
	STAssertTrue(testAbstractStore.delegates.count == 0, @"TestAbstractStore: did not allocate empty instance var");

	ALocalClassThatRespondsToApple *appleClass = [[[ALocalClassThatRespondsToApple alloc] init] autorelease];
	ALocalClassThatRespondsToPear *pearClass = [[[ALocalClassThatRespondsToPear alloc] init] autorelease];
	
	[testAbstractStore addStoreDelegate:appleClass];
	[testAbstractStore addStoreDelegate:pearClass];
	
	STAssertTrue((testAbstractStore.delegates.count == 2), @"TestAbstractStore: expected 0 delegates, got %d", testAbstractStore.delegates.count);

	// check to see if the correct delegates can be identified
	NSMutableSet *appleDelegates = [testAbstractStore createAllDelegatesRespondingToSelector:@selector(apple)];
	// we should have one elemnt in the set
	STAssertTrue(appleDelegates.count == 1, @"TestAbstractStore: expected 1 Apple delegate, found %d", appleDelegates.count);
	STAssertTrue([[appleDelegates anyObject] isKindOfClass:[NSValue class]],  @"TestAbstractStore: store delegate type not contained in NSValue");
	STAssertTrue([[appleDelegates anyObject] nonretainedObjectValue] == appleClass, @"TestAbstractStore: did not get correct delegate");
	
	
	NSMutableSet *pearDelegates = [[testAbstractStore createAllDelegatesRespondingToSelector:@selector(pear)] autorelease];
	// we should have one elemnt in the set
	STAssertTrue(pearDelegates.count == 1, @"TestAbstractStore: expected 1 Pear delegate, found %d", pearDelegates.count);
	STAssertTrue([[pearDelegates anyObject] isKindOfClass:[NSValue class]],  @"TestAbstractStore: store delegate type not contained in NSValue");
	STAssertTrue([[pearDelegates anyObject] nonretainedObjectValue] == pearClass, @"TestAbstractStore: did not get correct delegate");
	
	// remove specific delegates
	[testAbstractStore removeStoreDelegate:appleClass];
	STAssertTrue((testAbstractStore.delegates.count == 1), @"TestAbstractStore: expected 1 delegates, got %d", testAbstractStore.delegates.count);
	appleDelegates = [[testAbstractStore createAllDelegatesRespondingToSelector:@selector(apple)] autorelease];
	// we should have one elemnt in the set
	STAssertTrue(appleDelegates.count == 0, @"TestAbstractStore: expected 0 Apple delegate, found %d", appleDelegates.count);
	
	// we should have one pear elemnt in the set
	STAssertTrue(pearDelegates.count == 1, @"TestAbstractStore: expected 1 Pear delegate, found %d", pearDelegates.count);
	STAssertTrue([[pearDelegates anyObject] isKindOfClass:[NSValue class]],  @"TestAbstractStore: store delegate type not contained in NSValue");
	STAssertTrue([[pearDelegates anyObject] nonretainedObjectValue] == pearClass, @"TestAbstractStore: did not get correct delegate");
	
	// lets remove the same one again to test
	[testAbstractStore removeStoreDelegate:appleClass];
	appleDelegates = [[testAbstractStore createAllDelegatesRespondingToSelector:@selector(apple)] autorelease];
	// we should have one elemnt in the set
	STAssertTrue(appleDelegates.count == 0, @"TestAbstractStore: expected 0 Apple delegate, found %d", appleDelegates.count);

	pearDelegates = [[testAbstractStore createAllDelegatesRespondingToSelector:@selector(pear)] autorelease];
	// we should have one pear elemnt in the set
	STAssertTrue(pearDelegates.count == 1, @"TestAbstractStore: expected 1 Pear delegate, found %d", pearDelegates.count);
	STAssertTrue([[pearDelegates anyObject] isKindOfClass:[NSValue class]],  @"TestAbstractStore: store delegate type not contained in NSValue");
	STAssertTrue([[pearDelegates anyObject] nonretainedObjectValue] == pearClass, @"TestAbstractStore: did not get correct delegate");

	// remove the pear delegate
	[testAbstractStore removeStoreDelegate:pearClass];
	STAssertTrue((testAbstractStore.delegates.count == 0), @"TestAbstractStore: expected 0 delegates, got %d", testAbstractStore.delegates.count);

	[testAbstractStore release];
}

@end
