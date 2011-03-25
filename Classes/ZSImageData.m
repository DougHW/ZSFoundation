//
//  ZSImageData.m
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

#import "ZSImageData.h"
#import "UIImage+NSCoding.h"


@implementation ZSImageData

@synthesize dataValue;

+ (ZSImageData *)imageDataWithData:(NSData *)aData {
	return [[[ZSImageData alloc] initWithData:aData] autorelease];
}

- (id)initWithData:(NSData *)aData {
	self = [super init];
	if (self) {
		dataValue = [aData retain];
	}
	return self;
}

- (void)dealloc {
	[dataValue release];
	
	[super dealloc];
}

- (Class)classForCoder {
	return [UIImage class];
}


#pragma mark -
#pragma mark NSCopying Protocol methods

- (id)copyWithZone:(NSZone *)zone {
	ZSImageData *newObject = [[ZSImageData allocWithZone:zone] init];
	
	newObject.dataValue = self.dataValue;
	
	return newObject;
}


#pragma mark -
#pragma mark NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder {
	return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.dataValue forKey:@"UIImage.data"];
}

@end
