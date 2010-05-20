/*
 * (C) Copyright 2010, Stefan Arentz, Arentz Consulting Inc.
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Beacon.h"


@implementation Beacon

- (id) initWithURL: (NSURL*) url
{
	if ((self = [super init]) != nil) {
		_url = [url retain];
	}
	return self;
}

- (void) dealloc
{
	[_url release];
	[_connection release];
	[super dealloc];
}

#pragma mark -

- (void) signal
{
	if (_connection == nil)
	{
		NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
		NSString* queryString = [NSString stringWithFormat: @"?deviceId=%@&applicationVersion=%@&applicationIdentifier=%@",
			[[UIDevice currentDevice] uniqueIdentifier], [info objectForKey: @"CFBundleVersion"], [info objectForKey: @"CFBundleIdentifier"]];
		_connection = [[NSURLConnection connectionWithRequest:
			[NSURLRequest requestWithURL: [NSURL URLWithString: queryString relativeToURL: _url]]
				delegate: self] retain];
	}
}

#pragma mark -

- (void) connection: (NSURLConnection*) connection didFailWithError: (NSError*) error
{
	[_connection release];
	_connection = nil;
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection
{
	[_connection release];
	_connection = nil;
}

@end
