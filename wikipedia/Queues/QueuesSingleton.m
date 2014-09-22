//  Created by Monte Hurd on 12/6/13.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "QueuesSingleton.h"
#import "WikipediaAppUtils.h"

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
        [self setRequestHeadersForManager:self.loginFetchManager];
        
        self.articleFetchManager = [AFHTTPRequestOperationManager manager];
        [self setRequestHeadersForManager:self.articleFetchManager];
        
        self.savedPagesFetchManager = [AFHTTPRequestOperationManager manager];
        [self setRequestHeadersForManager:self.savedPagesFetchManager];
        
        self.searchResultsFetchManager = [AFHTTPRequestOperationManager manager];
        [self setRequestHeadersForManager:self.searchResultsFetchManager];
        
        self.sectionWikiTextDownloadManager = [AFHTTPRequestOperationManager manager];
        [self setRequestHeadersForManager:self.sectionWikiTextDownloadManager];
        
        self.sectionWikiTextUploadManager = [AFHTTPRequestOperationManager manager];
        [self setRequestHeadersForManager:self.sectionWikiTextUploadManager];
        
        self.sectionPreviewHtmlFetchManager = [AFHTTPRequestOperationManager manager];
        [self setRequestHeadersForManager:self.sectionPreviewHtmlFetchManager];
        
        self.languageLinksFetcher = [AFHTTPRequestOperationManager manager];
        [self setRequestHeadersForManager:self.languageLinksFetcher];
        
        self.zeroRatedMessageFetchManager = [AFHTTPRequestOperationManager manager];
        [self setRequestHeadersForManager:self.zeroRatedMessageFetchManager];
        
        self.accountCreationFetchManager = [AFHTTPRequestOperationManager manager];
        [self setRequestHeadersForManager:self.accountCreationFetchManager];
        
        self.pageHistoryFetchManager = [AFHTTPRequestOperationManager manager];
        [self setRequestHeadersForManager:self.pageHistoryFetchManager];
        
        self.assetsFetchManager = [AFHTTPRequestOperationManager manager];
        [self setRequestHeadersForManager:self.assetsFetchManager];
        
        self.nearbyFetchManager = [AFHTTPRequestOperationManager manager];
        [self setRequestHeadersForManager:self.nearbyFetchManager];
        

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

-(void)setRequestHeadersForManager:(AFHTTPRequestOperationManager *)manager
{
    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [manager.requestSerializer setValue:[WikipediaAppUtils versionedUserAgent] forHTTPHeaderField:@"User-Agent"];
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
