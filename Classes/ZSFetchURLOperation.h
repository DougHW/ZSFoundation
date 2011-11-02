//
//  ZSFetchURLOperation.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol ZSFetchURLOperationDelegate <NSObject>

- (void)didFetchData:(NSData *)aData forURL:(NSURL *)aURL;
- (void)didFailFetchForURL:(NSURL *)aURL withStatusCode:(NSInteger)aCode;

@end

@interface ZSFetchURLOperation : NSOperation {
@private
	id <ZSFetchURLOperationDelegate>		delegate;
	NSURL	*url;

}

@property (atomic, assign)	id <ZSFetchURLOperationDelegate>		delegate;
@property (atomic, retain)	NSURL	*url;

@end
