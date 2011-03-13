//
//  ZSUInteger.m
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

#import "ZSUInteger.h"


@implementation ZSUInteger

@synthesize value;

+ (id)uintegerWithUInteger:(NSUInteger)aValue {
	return [[[ZSUInteger alloc] initWithUInteger:aValue] autorelease];
}

- (id)initWithUInteger:(NSUInteger)aValue {
    self = [super init];
	if (self) {
		value = aValue;
	}
	return self;
}

- (NSComparisonResult)compare:(ZSUInteger *)aZSUInteger {
	NSAssert(aZSUInteger != nil, @"ZSUInteger cannot compare to nil");
	
	if (self.value < aZSUInteger.value) {
		return NSOrderedAscending;
	} else if (self.value == aZSUInteger.value) {
		return NSOrderedSame;
	} else {
		return NSOrderedDescending;
	}
}

- (NSString *)description {
	return [NSString stringWithFormat:@"{ZSUInteger: %d}", self.value];
}


#pragma mark -
#pragma mark NSObject Protocol methods

- (NSUInteger)hash {
	return self.value;
}

- (BOOL)isEqual:(id)anObject {
	if (self == anObject) {
		return YES;
	}
	
	if (!anObject) {
		// We know self isn't nil, so return NO
		return NO;
	}
	
	if (![anObject isKindOfClass:[ZSUInteger class]]) {
		return NO;
	}
	
	return self.value == ((ZSUInteger *)anObject).value;
}


#pragma mark -
#pragma mark NSCopying Protocol methods

- (id)copyWithZone:(NSZone *)zone {
	ZSUInteger *newObject = [[ZSUInteger allocWithZone:zone] init];
	
	newObject.value = self.value;
	
	return newObject;
}


#pragma mark -
#pragma mark NSCoding methods

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super init]) {
		value = [coder decodeIntegerForKey:@"ZSUInteger.value"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInteger:self.value forKey:@"ZSUInteger.value"];
}

@end
