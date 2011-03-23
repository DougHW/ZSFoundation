//
//  TestUIImage+NSCoding.h
//  ZSFoundation
//
//  Created by Doug Wehmeier on 3/23/11.
//  Copyright 2011 Zoosk. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

@interface TestUIImage_NSCoding : SenTestCase {
	
}

- (void)testJPEGEncodeDecode;
- (void)testPNGEncodeDecode;
- (void)testJPEGEncodeDecodeDifferentQualities;

@end
