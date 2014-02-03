//  Created by Monte Hurd on 1/16/14.

#import "LoginOp.h"
#import "MWNetworkActivityIndicatorManager.h"
#import "SessionSingleton.h"
#import "NSURLRequest+DictionaryRequest.h"

@interface LoginOp()

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *domain;

@end

@implementation LoginOp

-(NSURLRequest *)getRequest
{
    NSMutableDictionary *parameters = [@{
                                         @"action": @"login",
                                         @"lgname": self.userName,
                                         @"lgpassword": self.password,
                                         @"format": @"json"//,
//                                         @"lgtoken": self.token,
                                         }mutableCopy];
    

if (self.token) {
    parameters[@"lgtoken"] = self.token;
}

    return [NSURLRequest postRequestWithURL: [[SessionSingleton sharedInstance] urlForDomain:self.domain]
                                 parameters: parameters
            ];
}

- (id)initWithUsername: (NSString *)userName
              password: (NSString *)password
                domain: (NSString *)domain
       completionBlock: (void (^)(NSString *))completionBlock
        cancelledBlock: (void (^)(NSError *))cancelledBlock
            errorBlock: (void (^)(NSError *))errorBlock
{
    self = [super init];
    if (self) {
        self.token = nil;
        self.userName = userName;
        self.password = password;
        self.domain = domain;
        __weak LoginOp *weakSelf = self;
        self.aboutToStart = ^{
            [[MWNetworkActivityIndicatorManager sharedManager] push];
            weakSelf.request = [weakSelf getRequest];
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
                weakSelf.error = [NSError errorWithDomain:@"Login Op" code:001 userInfo:errorDict];
            }













if (!weakSelf.error) {

//NSLog(@"LoginOp jsonRetrieved = %@", weakSelf.jsonRetrieved);

    NSString *result = weakSelf.jsonRetrieved[@"login"][@"result"];

//TODO: add enum for each non-"Success" error type from here: http://www.mediawiki.org/wiki/API:Login#Errors
// Then do a switch here to outout appropriate error msgs

    if (![result isEqualToString:@"Success"]) {
        NSMutableDictionary *errorDict = [@{} mutableCopy];
        
        errorDict[NSLocalizedDescriptionKey] = result;
        
        // Set error condition so dependent ops don't even start and so the errorBlock below will fire.
        weakSelf.error = [NSError errorWithDomain:@"Login Op" code:002 userInfo:errorDict];
    }
}














            if (weakSelf.error) {
                errorBlock(weakSelf.error);
                return;
            }

            //NSDictionary *result = weakSelf.jsonRetrieved;
            NSString *result = weakSelf.jsonRetrieved[@"login"][@"result"];

            completionBlock(result);
        };
    }
    return self;
}

@end
