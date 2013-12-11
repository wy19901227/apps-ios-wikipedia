//  Created by Monte Hurd on 12/10/13.

#import "URLCache.h"

@implementation URLCache




- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{


cachedResponse = nil;


/*    NSString *responseData = [[NSString alloc] initWithData:cachedResponse.data encoding:NSUTF8StringEncoding];
    NSLog(@"caching request: \nrequest = %@\ncachedResponse.data.length = %d", request, cachedResponse.data.length);
*/
    [super storeCachedResponse:cachedResponse forRequest:request];
}





- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {




/*
NSData *imgData = UIImageJPEGRepresentation([UIImage imageNamed:@"w@2x.png"],0.0);
NSURLResponse *r = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:@"image/jpeg" expectedContentLength:imgData.length textEncodingName:nil];
NSCachedURLResponse *d = [[NSCachedURLResponse alloc] initWithResponse:r data:imgData];
return d;
*/




NSCachedURLResponse * c = [super cachedResponseForRequest:request];
NSString *dataString = [[NSString alloc] initWithData:c.data encoding:NSUTF8StringEncoding];

NSLog(@"\n\n\n\nrequest.URL = %@", request.URL);
NSLog(@"url = %@\ndata = %@", c.response.URL, dataString);
NSLog(@"currentDiskUsage = %d\ncurrentMemoryUsage = %d", self.currentDiskUsage, self.currentMemoryUsage);
NSLog(@"diskCapacity = %d\nmemoryCapacity = %d", self.diskCapacity, self.memoryCapacity);
NSLog(@"percents:\n\tdisk = %f\n\tmemory = %f", 100.0f * ((float)self.currentDiskUsage / (float)self.diskCapacity), 100.0f * ((float)self.currentMemoryUsage / (float)self.memoryCapacity));

return c;

    /*
    if ([[[request URL] absoluteString] rangeOfString:@"/ajax/"].location == NSNotFound) {
        return nil;
    } else {
        
        ASIHTTPRequest *asirequest = [ASIHTTPRequest requestWithURL:[request URL]];
        [asirequest setValidatesSecureCertificate:NO];
        [asirequest startSynchronous];
        NSError *error = [asirequest error];
        NSData* data = [[asirequest responseString] dataUsingEncoding:NSUTF8StringEncoding];
        
        // Create the cacheable response
        NSURLResponse *urlresponse = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:@"application/json" expectedContentLength:[data length] textEncodingName:@"UTF-8"];
        NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:urlresponse data:data];
        
        NSLog(@"cachedResponse %@", cachedResponse);
        NSLog(@"cachedResponse data %@", [[NSString alloc] initWithData:[cachedResponse data] encoding:NSUTF8StringEncoding]);
        
        return cachedResponse;
    }  
    */
    return nil;
}

@end
