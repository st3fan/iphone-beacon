// Beacon.m

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