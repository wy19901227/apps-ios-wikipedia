//
//  Article.h
//  Wikipedia
//
//  Created by Brion on 6/24/14.
//  Copyright (c) 2014 Wikimedia Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GalleryImage, History, Image, Saved, Section, Article;








// Enums for the ArticleDownloadDelegate protocol method.
typedef NS_ENUM(NSInteger, DownloadType) {
    ARTICLE_DOWNLOAD_TYPE_SECTIONS_LEAD,
    ARTICLE_DOWNLOAD_TYPE_SECTIONS_NONLEAD
};

typedef NS_ENUM(NSInteger, DownloadResult) {
    ARTICLE_DOWNLOAD_RESULT_SUCCESS,
    ARTICLE_DOWNLOAD_RESULT_CANCELLED,
    ARTICLE_DOWNLOAD_RESULT_FAILED
};

@protocol ArticleDownloadDelegate <NSObject>
// Protocol for notifying a listener that download has completed.
- (void)downloadFinishedForArticle: (Article *)article
                              type: (DownloadType)type
                            result: (DownloadResult)result
                             error: (NSError *)error;
@end












@interface Article : NSManagedObject <NetworkOpDelegate>

@property (nonatomic, retain) NSNumber * articleId;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * domain;
@property (nonatomic, retain) NSString * domainName;
@property (nonatomic, retain) NSNumber * languagecount;
@property (nonatomic, retain) NSDate * lastmodified;
@property (nonatomic, retain) NSString * lastmodifiedby;
@property (nonatomic, retain) NSNumber * lastScrollX;
@property (nonatomic, retain) NSNumber * lastScrollY;
@property (nonatomic, retain) NSNumber * needsRefresh;
@property (nonatomic, retain) NSString * redirected;
@property (nonatomic, retain) NSString * site;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * protectionStatus;
@property (nonatomic, retain) NSNumber * editable;
@property (nonatomic, retain) NSString * displayTitle;
@property (nonatomic, retain) NSSet *galleryImage;
@property (nonatomic, retain) NSSet *history;
@property (nonatomic, retain) NSSet *saved;
@property (nonatomic, retain) NSSet *section;
@property (nonatomic, retain) Image *thumbnailImage;




// The object to receive download notifications.
@property (nonatomic, assign) id <ArticleDownloadDelegate> delegate;



@end

@interface Article (CoreDataGeneratedAccessors)

- (void)addGalleryImageObject:(GalleryImage *)value;
- (void)removeGalleryImageObject:(GalleryImage *)value;
- (void)addGalleryImage:(NSSet *)values;
- (void)removeGalleryImage:(NSSet *)values;

- (void)addHistoryObject:(History *)value;
- (void)removeHistoryObject:(History *)value;
- (void)addHistory:(NSSet *)values;
- (void)removeHistory:(NSSet *)values;

- (void)addSavedObject:(Saved *)value;
- (void)removeSavedObject:(Saved *)value;
- (void)addSaved:(NSSet *)values;
- (void)removeSaved:(NSSet *)values;

- (void)addSectionObject:(Section *)value;
- (void)removeSectionObject:(Section *)value;
- (void)addSection:(NSSet *)values;
- (void)removeSection:(NSSet *)values;










// Temp.
//@property (nonatomic, retain) NSString *pageTitleText;


// Method to kick of download, results are reported to "delegate"
// via the ArticleDownloadDelegate protocol method.
// Note: the WebViewController should use a higher priority than
// background downloads by the Saved Pages view controller.

// Also, be sure if the web view controller cancels downloads aleady
// in the q, it does so only for the higher priority downloads that
// it added rather cancelling all downloads, which would wipe out
// any lower priority Saved Pages downloads.
-(void)downloadWithQueuePriority:(NSOperationQueuePriority)queuePriority;







@end
