//  Created by Monte Hurd on 12/6/13.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import <Foundation/Foundation.h>

#import "AFHTTPRequestOperationManager.h"

@interface QueuesSingleton : NSObject

@property (strong, nonatomic) AFHTTPRequestOperationManager *loginFetchManager;
@property (strong, nonatomic) AFHTTPRequestOperationManager *articleFetchManager;
@property (strong, nonatomic) NSOperationQueue *savedPagesQ;
@property (strong, nonatomic) AFHTTPRequestOperationManager *searchResultsFetchManager;
@property (strong, nonatomic) NSOperationQueue *thumbnailQ;
@property (strong, nonatomic) NSOperationQueue *zeroRatedMessageStringQ;

@property (strong, nonatomic) NSOperationQueue *sectionWikiTextDownloadQ;
@property (strong, nonatomic) NSOperationQueue *sectionWikiTextUploadQ;
@property (strong, nonatomic) AFHTTPRequestOperationManager *sectionPreviewHtmlFetchManager;
@property (strong, nonatomic) NSOperationQueue *langLinksQ;
@property (strong, nonatomic) AFHTTPRequestOperationManager *accountCreationFetchManager;

@property (strong, nonatomic) NSOperationQueue *randomArticleQ;

@property (strong, nonatomic) AFHTTPRequestOperationManager *pageHistoryFetchManager;

@property (strong, nonatomic) AFHTTPRequestOperationManager *assetsFetchManager;
@property (strong, nonatomic) NSOperationQueue *nearbyQ;

+ (QueuesSingleton *)sharedInstance;

@end
