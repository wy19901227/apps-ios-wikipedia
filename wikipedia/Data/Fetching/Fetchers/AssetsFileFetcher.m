//  Created by Monte Hurd on 10/9/14.
//  Copyright (c) 2014 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "AssetsFileFetcher.h"
#import "AFHTTPRequestOperationManager.h"

#import "MWNetworkActivityIndicatorManager.h"
#import "NSURLRequest+DictionaryRequest.h"

#import "AssetsFile.h"

@implementation AssetsFileFetcher

-(void)fetchAssetsFile: (AssetsFileEnum)file
                maxAge: (CGFloat)maxAge
           withManager: (AFHTTPRequestOperationManager *)manager;
{


    AssetsFile *assetsFile = [[AssetsFile alloc] initWithFile:file];

    // Cancel the operation if the existing file hasn't aged enough.
    BOOL shouldRefresh = [assetsFile isOlderThan:maxAge];

    if (!shouldRefresh) return;
    
    NSURL *url = assetsFile.url;
    
    [[MWNetworkActivityIndicatorManager sharedManager] push];
    
    [manager GET:url.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [[MWNetworkActivityIndicatorManager sharedManager] pop];
        
        if (operation.response.statusCode != 200) return;
        
        //NSString *className = NSStringFromClass ([responseObject class]);
        //NSLog(@"className = %@", className);
        //NSLog(@"mimeType = %@", operation.response.MIMEType);

        if([responseObject isKindOfClass:[NSData class]]){

            NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            if (
                !responseString
                ||
                (responseString.length == 0)
                ||
                ([responseString hasPrefix:@"/*\nInternal error\n*"])
            ) return;
            
            NSError *error = nil;
            
            [responseString writeToFile: assetsFile.path
                             atomically: YES
                               encoding: NSUTF8StringEncoding
                                  error: &error];
            
            if (error) {
                NSLog(@"Error: %@", error);
                [self downloadFinishedWithResult: FETCH_RESULT_FAILED
                                            type: file
                                           error: error];
            }else{
                [self downloadFinishedWithResult: FETCH_RESULT_SUCCEEDED
                                            type: file
                                           error: nil];
            }
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //NSLog(@"Error URL: %@", operation.request.URL);

        [[MWNetworkActivityIndicatorManager sharedManager] pop];
        if([error code] == NSURLErrorCancelled) {
            [self downloadFinishedWithResult: FETCH_RESULT_CANCELLED
                                        type: file
                                       error: error];
        }else{
            [self downloadFinishedWithResult: FETCH_RESULT_FAILED
                                        type: file
                                       error: error];
        }
    }];
}

- (void)downloadFinishedWithResult: (FetchResult)result
                              type: (AssetsFileEnum)type
                             error: (NSError *)error
{
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
        [self.fetchCompletionDelegate fetchFinishedForObject: nil
                                                      sender: self
                                                      result: result
                                                        type: type
                                                       error: error];
    }];
}

-(void)dealloc
{
    NSLog(@"DEALLOC'ING FETCHER!");
}

@end
