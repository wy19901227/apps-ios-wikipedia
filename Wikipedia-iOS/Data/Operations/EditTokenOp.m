//  Created by Monte Hurd on 1/16/14.

#import "EditTokenOp.h"
#import "MWNetworkActivityIndicatorManager.h"
#import "SessionSingleton.h"
#import "NSURLRequest+DictionaryRequest.h"

@implementation EditTokenOp

- (id)initForPageTitle: (NSString *)title
                domain: (NSString *)domain
       completionBlock: (void (^)(NSString *))completionBlock
        cancelledBlock: (void (^)(NSError *))cancelledBlock
            errorBlock: (void (^)(NSError *))errorBlock
{
    self = [super init];
    if (self) {

//api.php?action=query&prop=info|revisions&intoken=edit&titles=Main%20Page

        NSMutableDictionary *parameters = [@{
                                             @"action": @"query",
                                             @"prop": @"info|revisions",
                                             @"intoken": @"edit",
                                             @"titles": title,
                                             @"prop": @"info",
                                             @"format": @"json"
                                             }mutableCopy];
        
        self.request = [NSURLRequest postRequestWithURL: [[SessionSingleton sharedInstance] urlForDomain:domain]
                                             parameters: parameters
                        ];
NSString* newStr = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];

NSLog(@"%@", newStr);
        __weak EditTokenOp *weakSelf = self;
        self.aboutToStart = ^{
            [[MWNetworkActivityIndicatorManager sharedManager] push];
        };
        self.completionBlock = ^(){
            [[MWNetworkActivityIndicatorManager sharedManager] pop];
            
            if(weakSelf.isCancelled){
                cancelledBlock(weakSelf.error);
                return;
            }
            
            // Check for error retrieving section zero data.
            if(weakSelf.jsonRetrieved[@"error"]){
                NSMutableDictionary *errorDict = [weakSelf.jsonRetrieved[@"error"] mutableCopy];
                
                errorDict[NSLocalizedDescriptionKey] = errorDict[@"info"];
                
                // Set error condition so dependent ops don't even start and so the errorBlock below will fire.
                weakSelf.error = [NSError errorWithDomain:@"Edit Token Op" code:001 userInfo:errorDict];
            }




NSString *token = nil;
NSDictionary *pages = weakSelf.jsonRetrieved[@"query"][@"pages"];
if (pages) {
    NSDictionary *page = pages[pages.allKeys[0]];
    if (page) {
        token = page[@"edittoken"];
    }
}

if (!weakSelf.error && !token) {
    NSMutableDictionary *errorDict = [@{} mutableCopy];
    errorDict[NSLocalizedDescriptionKey] = NSLocalizedString(@"wikitext-upload-token-failed", nil);
    
    // Set error condition so dependent ops don't even start and so the errorBlock below will fire.
    weakSelf.error = [NSError errorWithDomain:@"Edit Token Op" code:002 userInfo:errorDict];
}



            
            if (weakSelf.error) {
                errorBlock(weakSelf.error);
                return;
            }
            
//            NSDictionary *result = weakSelf.jsonRetrieved;
NSLog(@"%@", token);
            
            completionBlock(token);
        };
    }
    return self;
}

@end
