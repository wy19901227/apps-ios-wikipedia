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
        self.savedPagesQ = [[NSOperationQueue alloc] init];
        self.searchResultsFetchManager = [AFHTTPRequestOperationManager manager];
        self.thumbnailQ = [[NSOperationQueue alloc] init];
        self.sectionWikiTextDownloadQ = [[NSOperationQueue alloc] init];
        self.sectionWikiTextUploadQ = [[NSOperationQueue alloc] init];
        self.sectionPreviewHtmlFetchManager = [AFHTTPRequestOperationManager manager];
        self.langLinksQ = [[NSOperationQueue alloc] init];
        self.zeroRatedMessageStringQ = [[NSOperationQueue alloc] init];
        self.accountCreationFetchManager = [AFHTTPRequestOperationManager manager];
        self.randomArticleQ = [[NSOperationQueue alloc] init];
        self.pageHistoryFetchManager = [AFHTTPRequestOperationManager manager];
        self.assetsFetchManager = [AFHTTPRequestOperationManager manager];
        self.nearbyQ = [[NSOperationQueue alloc] init];
        //[self setupQMonitorLogging];
    }
    return self;
}

-(void)setupQMonitorLogging
{
    // Listen in on the Q's op counts to ensure they go away properly.
    [self.articleFetchManager.operationQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:nil];
    [self.searchResultsFetchManager.operationQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:nil];
    [self.thumbnailQ addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"operationCount"]) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            NSLog(@"QUEUE OP COUNTS: Search %lu, Thumb %lu, Article %lu",
                (unsigned long)self.searchResultsFetchManager.operationQueue.operationCount,
                (unsigned long)self.thumbnailQ.operationCount,
                (unsigned long)self.articleFetchManager.operationQueue.operationCount
            );
        });
    }
}

@end
