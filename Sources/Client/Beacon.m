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

#include <sys/types.h>
#include <sys/sysctl.h>

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

- (NSString*) _systemInformationString: (NSString*) name
{
	char buffer[1024];
	size_t length = 1024;

	if (sysctlbyname([name cStringUsingEncoding: NSASCIIStringEncoding], buffer, &length, NULL, 0) == 0) {
		return [NSString stringWithCString: buffer encoding: NSASCIIStringEncoding];
	}

	return nil;
}

- (BOOL) _deviceJailbroken
{
	return [[NSFileManager defaultManager] fileExistsAtPath: @"/Applications/Cydia.app"]
		|| [[NSFileManager defaultManager] fileExistsAtPath: @"/private/var/lib/apt"];
}

- (NSDictionary*) _applicationInformation
{
	NSMutableDictionary* applicationInformation = [NSMutableDictionary dictionary];
	if (applicationInformation != nil)
	{
		NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
		if (info != nil)
		{
			[applicationInformation setObject: [info objectForKey: @"CFBundleIdentifier"] forKey: @"applicationIdentifier"];
			[applicationInformation setObject: [info objectForKey: @"CFBundleVersion"] forKey: @"applicationVersion"];
		}
	}
	
	return applicationInformation;
}

- (NSDictionary*) _deviceInformation
{
	NSMutableDictionary* deviceInformation = [NSMutableDictionary dictionary];
	if (deviceInformation != nil)
	{
		[deviceInformation setObject: [[UIDevice currentDevice] uniqueIdentifier] forKey: @"deviceIdentifier"];
		[deviceInformation setObject: [[UIDevice currentDevice] model] forKey: @"deviceModel"];
		[deviceInformation setObject: [[UIDevice currentDevice] systemVersion] forKey: @"deviceSystemVersion"];
		[deviceInformation setObject: [NSNumber numberWithBool: [self _deviceJailbroken]] forKey: @"deviceJailbroken"];
		
		[deviceInformation setObject: [self _systemInformationString: @"hw.machine"] forKey: @"hardwareMachine"];
		[deviceInformation setObject: [self _systemInformationString: @"hw.model"] forKey: @"hardwareModel"];
	}

	return deviceInformation;
}

#pragma mark -

- (NSString*) _formEncodeString: (NSString*) string
{
	NSString* encoded = (NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
		(CFStringRef) string, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
	return [encoded autorelease];
}

#pragma mark -

- (void) signal
{
#if !defined(TARGET_IPHONE_SIMULATOR)
	if (_connection == nil)
	{
		NSMutableString* query = [NSMutableString stringWithString: @"?"];
		
		NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
		[parameters addEntriesFromDictionary: [self _applicationInformation]];
		[parameters addEntriesFromDictionary: [self _deviceInformation]];
		
		for (NSString* key in [parameters keyEnumerator]) {
			if ([query length] > 1) {
				[query appendString: @"&"];
			}
			[query appendFormat: @"%@=%@", key, [self _formEncodeString: [[parameters objectForKey: key] description]]];
		}
			
		_connection = [[NSURLConnection connectionWithRequest:
			[NSURLRequest requestWithURL: [NSURL URLWithString: query relativeToURL: _url]]
				delegate: self] retain];
	}
#endif
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
