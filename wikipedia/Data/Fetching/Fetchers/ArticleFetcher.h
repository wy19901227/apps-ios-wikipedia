//  Created by Monte Hurd on 10/9/14.
//  Copyright (c) 2014 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import <Foundation/Foundation.h>
#import "FetcherBase.h"

typedef NS_ENUM(NSInteger, ArticleFetchType) {
    ARTICLE_FETCH_TYPE_SECTIONS_LEAD,
    ARTICLE_FETCH_TYPE_SECTIONS_NONLEAD
};

@class Article, AFHTTPRequestOperationManager;

@interface ArticleFetcher : FetcherBase

// The Article object to be updated with the downloaded data.
@property (nonatomic, strong) Article *articleDelegate;

// Method to kick of download, results are reported to "delegate"
// via the FetchCompletionDelegate protocol method.
-(void)fetchWithManager:(AFHTTPRequestOperationManager *)manager;

@end
