// Beacon.h

#import <Foundation/Foundation.h>

@interface Beacon : NSObject {
  @private
	NSURL* _url;
  @private
    NSURLConnection* _connection;
}

- (id) initWithURL: (NSURL*) url;
- (void) signal;

@end