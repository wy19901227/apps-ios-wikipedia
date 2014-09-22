//  Created by Monte Hurd on 12/6/13.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "QueuesSingleton.h"

@implementation QueuesSingleton

+ (QueuesSingleton *)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.loginFetchManager = [AFHTTPRequestOperationManager manager];
        self.articleFetchManager = [AFHTTPRequestOperationManager manager];
        self.savedPagesFetchManager = [AFHTTPRequestOperationManager manager];
        self.searchResultsFetchManager = [AFHTTPRequestOperationManager manager];
        self.sectionWikiTextDownloadManager = [AFHTTPRequestOperationManager manager];
        self.sectionWikiTextUploadManager = [AFHTTPRequestOperationManager manager];
        self.sectionPreviewHtmlFetchManager = [AFHTTPRequestOperationManager manager];
        self.languageLinksFetcher = [AFHTTPRequestOperationManager manager];
        self.zeroRatedMessageFetchManager = [AFHTTPRequestOperationManager manager];
        self.accountCreationFetchManager = [AFHTTPRequestOperationManager manager];
        self.randomArticleFetchManager = [AFHTTPRequestOperationManager manager];
        self.pageHistoryFetchManager = [AFHTTPRequestOperationManager manager];
        self.assetsFetchManager = [AFHTTPRequestOperationManager manager];
        self.nearbyFetchManager = [AFHTTPRequestOperationManager manager];

        // Set the responseSerializer to AFHTTPResponseSerializer, so that it will no longer
        // try to parse the JSON - needed because we use the following managers to fetch both
        // nearby json api data *and* thumbnails. Thumb responses are not json!
        // From: http://stackoverflow.com/a/21621530
        self.nearbyFetchManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.searchResultsFetchManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        // The assetsFetchManager doesn't retreive json either.
        self.assetsFetchManager.responseSerializer = [AFHTTPResponseSerializer serializer];

        //[self setupQMonitorLogging];
    }
    return self;
}

-(void)setupQMonitorLogging
{
    // Listen in on the Q's op counts to ensure they go away properly.
    [self.articleFetchManager.operationQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:nil];
    [self.searchResultsFetchManager.operationQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"operationCount"]) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            NSLog(@"QUEUE OP COUNTS: Search %lu, Article %lu",
                (unsigned long)self.searchResultsFetchManager.operationQueue.operationCount,
                (unsigned long)self.articleFetchManager.operationQueue.operationCount
            );
        });
    }
}

@end
