//  Created by Monte Hurd on 1/15/14.

#import "Section+Editing.h"

#import "QueuesSingleton.h"
#import "MWNetworkOp.h"
#import "SessionSingleton.h"
#import "NSURLRequest+DictionaryRequest.h"
#import "MWNetworkActivityIndicatorManager.h"
#import "ArticleCoreDataObjects.h"

@implementation Section (Editing)

- (void)getWikiTextThen:(void (^)(NSString *))block
{
    [[QueuesSingleton sharedInstance].sectionWikiTextQ cancelAllOperations];
   
//TODO: hook up "Loading Wiki text..." mesage (once message label is available to any VCs)
    // Show "Loading Wiki text..." message.
    //self.webViewController.alertLabel.text = WIKI_TEXT_LOADING_MSG;
    
    MWNetworkOp *wikiTextOp = [[MWNetworkOp alloc] init];
    //wikiTextOp.delegate = self;
    wikiTextOp.request = [NSURLRequest postRequestWithURL: [NSURL URLWithString:[SessionSingleton sharedInstance].searchApiUrl]
                                             parameters: @{
                                                           @"action": @"query",
                                                           @"prop": @"revisions",
                                                           @"rvprop": @"content",
                                                           @"rvlimit": @1,
                                                           @"rvsection": self.index,
                                                           @"titles": self.article.title,
                                                           @"format": @"json"
                                                           }
                        ];
    
    __weak MWNetworkOp *weakWikiTextOp = wikiTextOp;

    wikiTextOp.aboutToStart = ^{
        [[MWNetworkActivityIndicatorManager sharedManager] push];
    };

    wikiTextOp.completionBlock = ^(){
        [[MWNetworkActivityIndicatorManager sharedManager] pop];
        if(weakWikiTextOp.isCancelled){
            return;
        }

        if(weakWikiTextOp.error){
            //NSLog(@"wikiTextOp completionBlock bailed on error %@", weakWikiTextOp.error);
            
            // Show error message.
            // (need to extract msg from error *before* main q block - the error is dealloc'ed by
            // the time the block is dequeued)
/*
            NSString *errorMsg = weakWikiTextOp.error.localizedDescription;
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                self.webViewController.alertLabel.text = errorMsg;
            }];
*/
            return;
        }else{
/*
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                self.webViewController.alertLabel.text = @"";
            }];
*/
        }

//TODO: hook up error message below if revision not found.
        NSDictionary *json = (NSDictionary *)weakWikiTextOp.jsonRetrieved;
        NSDictionary *pages = json[@"query"][@"pages"];

        if (pages) {
            NSDictionary *page = pages[pages.allKeys[0]];
            if (page) {
                NSString *revision = page[@"revisions"][0][@"*"];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    block(revision);
                });
            }
        }
    };

    [[QueuesSingleton sharedInstance].sectionWikiTextQ addOperation:wikiTextOp];
}

//TODO: handle errors and refresh underlying page cache on edit success.

- (void)saveWikiText:(NSString *)wikiText then:(void (^)(NSDictionary *))block
{
    [[QueuesSingleton sharedInstance].sectionWikiTextQ cancelAllOperations];
   
//TODO: hook up "Loading Wiki text..." mesage (once message label is available to any VCs)
    // Show "Loading Wiki text..." message.
    //self.webViewController.alertLabel.text = WIKI_TEXT_LOADING_MSG;
    
    MWNetworkOp *wikiTextOp = [[MWNetworkOp alloc] init];
    //wikiTextOp.delegate = self;
    wikiTextOp.request = [NSURLRequest postRequestWithURL: [NSURL URLWithString:[SessionSingleton sharedInstance].searchApiUrl]
                                             parameters: @{
                                                           @"action": @"edit",
                                                           @"token": @"+\\",
                                                           @"text": wikiText,
                                                           @"section": self.index,
                                                           @"title": self.article.title,
                                                           @"format": @"json"
                                                           }
                        ];
    
    __weak MWNetworkOp *weakWikiTextOp = wikiTextOp;

    wikiTextOp.aboutToStart = ^{
        [[MWNetworkActivityIndicatorManager sharedManager] push];
    };
    wikiTextOp.completionBlock = ^(){
        [[MWNetworkActivityIndicatorManager sharedManager] pop];
        if(weakWikiTextOp.isCancelled){
            return;
        }

        if(weakWikiTextOp.error){
            //NSLog(@"wikiTextOp completionBlock bailed on error %@", weakWikiTextOp.error);
            
            // Show error message.
            // (need to extract msg from error *before* main q block - the error is dealloc'ed by
            // the time the block is dequeued)
/*
            NSString *errorMsg = weakWikiTextOp.error.localizedDescription;
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                self.webViewController.alertLabel.text = errorMsg;
            }];
*/
            return;
        }else{
/*
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                self.webViewController.alertLabel.text = @"";
            }];
*/
        }

//TODO: hook up error message below if revision not found.
        NSDictionary *resultJson = (NSDictionary *)weakWikiTextOp.jsonRetrieved;


//        NSDictionary *pages = json[@"query"][@"pages"];
//
//        if (pages) {
//            NSDictionary *page = pages[pages.allKeys[0]];
//            if (page) {
//                NSString *revision = page[@"revisions"][0][@"*"];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    block(resultJson);
                });
//            }
//        }
    };
    
    [[QueuesSingleton sharedInstance].sectionWikiTextQ addOperation:wikiTextOp];
}

@end
