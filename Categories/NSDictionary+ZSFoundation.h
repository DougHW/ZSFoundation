//
//  NSDictionary+ZSFoundation.h
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

@interface NSDictionary (NSDictionary_ZSFoundation)

/**
 * Transforms a dictionary into a query string
 *
 * @return	Query string
 */
- (NSString *)buildQueryParameterString;

/**
 * Joins keys and values by innerGlue and delimits each with outerGlue.
 *
 * @param	innerGlue	String with which to glue keys and values
 * @param	outerGlue	String with which to separate key-value pairs
 * @return				Imploded string
 */
- (NSString *)implodeOnInnerGlue:(NSString *)innerGlue outerGlue:(NSString *)outerGlue;

@end
