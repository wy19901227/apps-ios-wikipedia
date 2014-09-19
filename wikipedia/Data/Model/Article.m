//
//  Article.m
//  Wikipedia
//
//  Created by Brion on 6/24/14.
//  Copyright (c) 2014 Wikimedia Foundation. All rights reserved.
//

#import "Article.h"
#import "GalleryImage.h"
#import "History.h"
#import "Image.h"
#import "Saved.h"
#import "Section.h"


// Imports to support the "downloadWithQueuePriority:" method.
#import "QueuesSingleton.h"
#import "ArticleDataContextSingleton.h"
#import "DownloadSectionsOp.h"
#import "ArticleCoreDataObjects.h"
#import "MWPageTitle.h"
#import "Section+ImageRecords.h"
#import "Section+LeadSection.h"
#import "NSString+Extras.h"




@implementation Article

@dynamic articleId;
@dynamic dateCreated;
@dynamic domain;
@dynamic domainName;
@dynamic languagecount;
@dynamic lastmodified;
@dynamic lastmodifiedby;
@dynamic lastScrollX;
@dynamic lastScrollY;
@dynamic needsRefresh;
@dynamic redirected;
@dynamic site;
@dynamic title;
@dynamic protectionStatus;
@dynamic editable;
@dynamic displayTitle;
@dynamic galleryImage;
@dynamic history;
@dynamic saved;
@dynamic section;
@dynamic thumbnailImage;




@synthesize delegate;


-(void)downloadWithQueuePriority:(NSOperationQueuePriority)queuePriority
{




    // Retrieve remaining sections op (dependent on first section op)
    DownloadSectionsOp *remainingSectionsOp =
    [[DownloadSectionsOp alloc] initForPageTitle: self.title
                                          domain: self.domain
                                 leadSectionOnly: NO
                                 completionBlock: ^(NSDictionary *results){










        [self.managedObjectContext performBlockAndWait:^(){

            //Non-lead sections have been retreived so set needsRefresh to NO.
            self.needsRefresh = @NO;

            NSArray *sectionsRetrieved = results[@"sections"];

            for (NSDictionary *section in sectionsRetrieved) {
                if (![section[@"id"] isEqual: @0]) {
                                    
                    // Add sections for article
                    Section *thisSection = [NSEntityDescription insertNewObjectForEntityForName:@"Section" inManagedObjectContext:self.managedObjectContext];

                    // Section index is a string because transclusion sections indexes will start with "T-".
                    if ([section[@"index"] isKindOfClass:[NSString class]]) {
                        thisSection.index = section[@"index"];
                    }

                    thisSection.title = section[@"line"];

                    if ([section[@"level"] isKindOfClass:[NSString class]]) {
                        thisSection.level = section[@"level"];
                    }

                    // Section number, from the api, can be 3.5.2 etc, so it's a string.
                    if ([section[@"number"] isKindOfClass:[NSString class]]) {
                        thisSection.number = section[@"number"];
                    }

                    if (section[@"fromtitle"]) {
                        thisSection.fromTitle = section[@"fromtitle"];
                    }

                    thisSection.sectionId = section[@"id"];

                    thisSection.html = section[@"text"];
                    thisSection.tocLevel = section[@"toclevel"];
                    thisSection.dateRetrieved = [NSDate date];
                    thisSection.anchor = (section[@"anchor"]) ? section[@"anchor"] : @"";

                    [self addSectionObject:thisSection];

                    [thisSection createImageRecordsForHtmlOnContext:self.managedObjectContext];
                }
            }

            //NSError *error = nil;
            //[self.managedObjectContext save:&error];

            //[self.tocVC setTocSectionDataForSections:self.section];

        [delegate downloadFinishedForArticle: self
                                        type: ARTICLE_DOWNLOAD_TYPE_SECTIONS_NONLEAD
                                      result: ARTICLE_DOWNLOAD_RESULT_SUCCESS
                                       error: nil];


        }];
        
        //[self displayArticle:articleID mode:DISPLAY_APPEND_NON_LEAD_SECTIONS];











    } cancelledBlock:^(NSError *error){
        //[self fadeAlert];

        [delegate downloadFinishedForArticle: self
                                        type: ARTICLE_DOWNLOAD_TYPE_SECTIONS_NONLEAD
                                      result: ARTICLE_DOWNLOAD_RESULT_CANCELLED
                                       error: nil];


    } errorBlock:^(NSError *error){
        //NSString *errorMsg = error.localizedDescription;
        //if(error.code != 555){ // Quick hack for hiding MWNetworkOp cancel messages.
        //    [self showAlert:errorMsg type:ALERT_TYPE_TOP duration:-1];
        //}


        [delegate downloadFinishedForArticle: self
                                        type: ARTICLE_DOWNLOAD_TYPE_SECTIONS_NONLEAD
                                      result: ARTICLE_DOWNLOAD_RESULT_FAILED
                                       error: error];

    }];

    remainingSectionsOp.delegate = self;












    // Retrieve first section op
    DownloadSectionsOp *firstSectionOp =
    [[DownloadSectionsOp alloc] initForPageTitle: self.title
                                          domain: self.domain
                                 leadSectionOnly: YES
                                 completionBlock: ^(NSDictionary *dataRetrieved){











        //NSString *redirectedTitle = [dataRetrieved[@"redirected"] copy];
        //
        //// Redirect if the pageTitle which triggered this call to "retrieveArticleForPageTitle"
        //// differs from titleReflectingAnyRedirects.
        //if (redirectedTitle.length > 0) {
        //    MWPageTitle *newTitle = [MWPageTitle titleWithString:redirectedTitle];
        //    [self retrieveArticleForPageTitle: newTitle
        //                               domain: domain
        //                      discoveryMethod: discoveryMethod];
        //    return;
        //}

        [self.managedObjectContext performBlockAndWait:^(){
            //Article *article = nil;
            //
            //if (!articleID) {
            //    article = [NSEntityDescription
            //        insertNewObjectForEntityForName:@"Article"
            //        inManagedObjectContext:self.managedObjectContext
            //    ];
            //    article.title = pageTitle.prefixedText;
            //    article.dateCreated = [NSDate date];
            //    article.site = [SessionSingleton sharedInstance].site;
            //    article.domain = [SessionSingleton sharedInstance].currentArticleDomain;
            //    article.domainName = [SessionSingleton sharedInstance].currentArticleDomainName;
            //    articleID = article.objectID;
            //}else{
            //    article = (Article *)[self.managedObjectContext objectWithID:articleID];
            //}
            //
            //if (needsRefresh) {
            //    // If and article needs refreshing remove its sections so they get reloaded too.
            //    for (Section *thisSection in [article.section copy]) {
            //        [self.managedObjectContext deleteObject:thisSection];
            //    }
            //}

            // If "needsRefresh", an existing article's data is being retrieved again, so these need
            // to be updated whether a new article record is being inserted or not as data may have
            // changed since the article record was first created.
            self.languagecount = dataRetrieved[@"languagecount"];
            self.lastmodified = dataRetrieved[@"lastmodified"];
            self.lastmodifiedby = dataRetrieved[@"lastmodifiedby"];
            self.articleId = dataRetrieved[@"articleId"];
            self.editable = dataRetrieved[@"editable"];
            self.protectionStatus = dataRetrieved[@"protectionStatus"];


            // Note: Because "retrieveArticleForPageTitle" recurses with the redirected-to title if
            // the lead section op determines a redirect occurred, the "redirected" value below will
            // probably never be set.
            self.redirected = dataRetrieved[@"redirected"];

            //NSDateFormatter *anotherDateFormatter = [[NSDateFormatter alloc] init];
            //[anotherDateFormatter setDateStyle:NSDateFormatterLongStyle];
            //[anotherDateFormatter setTimeStyle:NSDateFormatterShortStyle];
            //NSLog(@"formatted lastmodified = %@", [anotherDateFormatter stringFromDate:self.lastmodified]);

            // Associate thumbnail with article.
            // If search result for this pageTitle had a thumbnail url associated with it, see if
            // a core data image object exists with a matching sourceURL. If so make the article
            // thumbnailImage property point to that core data image object. This associates the
            // search result thumbnail with the article.
            //NSPredicate *articlePredicate =
            //    [NSPredicate predicateWithFormat:@"(title == %@) AND (thumbnail.source.length > 0)", pageTitle.text];
            //NSDictionary *articleDictFromSearchResults =
            //    [ROOT.topMenuViewController.currentSearchResultsOrdered firstMatchForPredicate:articlePredicate];
            //if (articleDictFromSearchResults) {
            //    NSString *thumbURL = articleDictFromSearchResults[@"thumbnail"][@"source"];
            //    thumbURL = [thumbURL getUrlWithoutScheme];
            //    Image *thumb = (Image *)[self.managedObjectContext getEntityForName: @"Image" withPredicateFormat:@"sourceUrl == %@", thumbURL];
            //    if (thumb) self.thumbnailImage = thumb;
            //}

            self.lastScrollX = @0.0f;
            self.lastScrollY = @0.0f;

            // Get article section zero html
            NSArray *sectionsRetrieved = dataRetrieved[@"sections"];
            NSDictionary *section0Dict = (sectionsRetrieved.count >= 1) ? sectionsRetrieved[0] : nil;

            // If there was only one section then we have what we need so no refresh
            // is needed. Otherwise leave needsRefresh set to YES until subsequent sections
            // have been retrieved. Reminder: "onlyrequestedsections" is not used
            // by the mobileview query so that sectionsRetrieved.count will
            // reflect the article's total number of sections here ("sections"
            // was set to "0" though so only the first section entry actually has
            // any html). This fixes the bug which caused subsequent sections to never
            // be retrieved if the article was navigated away from before they had loaded.
            self.needsRefresh = (sectionsRetrieved.count == 1) ? @NO : @YES;

            NSString *section0HTML = @"";
            if (section0Dict && [section0Dict[@"id"] isEqual: @0] && section0Dict[@"text"]) {
                section0HTML = section0Dict[@"text"];
            }

            // Add sections for article
            Section *section0 = [NSEntityDescription insertNewObjectForEntityForName:@"Section" inManagedObjectContext:self.managedObjectContext];
            // Section index is a string because transclusion sections indexes will start with "T-"
            section0.index = @"0";
            section0.level = @"0";
            section0.number = @"0";
            section0.sectionId = @0;
            section0.title = @"";
            section0.dateRetrieved = [NSDate date];
            section0.html = section0HTML;
            section0.anchor = @"";
            
            [self addSectionObject:section0];

            [section0 createImageRecordsForHtmlOnContext:self.managedObjectContext];

            //// Don't add multiple history items for the same article or back-forward button
            //// behavior becomes a confusing mess.
            //if(self.history.count == 0){
            //    // Add history for article
            //    History *history0 = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:self.managedObjectContext];
            //    history0.dateVisited = [NSDate date];
            //    //history0.dateVisited = [NSDate dateWithDaysBeforeNow:31];
            //    history0.discoveryMethod = discoveryMethod;
            //    [self addHistoryObject:history0];
            //}

            // Save the article!
            //NSError *error = nil;
            //[self.managedObjectContext save:&error];
            //
            ////[self.tocVC setTocSectionDataForSections:self.section];
            //
            //if (error) {
            //    NSLog(@"error = %@", error);
            //    NSLog(@"error = %@", error.localizedDescription);
            //}




        [delegate downloadFinishedForArticle: self
                                        type: ARTICLE_DOWNLOAD_TYPE_SECTIONS_LEAD
                                      result: ARTICLE_DOWNLOAD_RESULT_SUCCESS
                                       error: nil];




        }];

        //[self displayArticle:articleID mode:DISPLAY_LEAD_SECTION];
        //[self showAlert:MWLocalizedString(@"search-loading-section-remaining", nil) type:ALERT_TYPE_TOP duration:-1];












    } cancelledBlock:^(NSError *error){

        // Remove the article so it doesn't get saved.
        //if (articleID) {
        //    Article *article = (Article *)[self.managedObjectContext objectWithID:articleID];
        //    [self.managedObjectContext deleteObject:article];
        //}
        
        [delegate downloadFinishedForArticle: self
                                        type: ARTICLE_DOWNLOAD_TYPE_SECTIONS_LEAD
                                      result: ARTICLE_DOWNLOAD_RESULT_CANCELLED
                                       error: nil];


    } errorBlock:^(NSError *error){
        //NSString *errorMsg = error.localizedDescription;
        //[self showAlert:errorMsg type:ALERT_TYPE_TOP duration:-1];
        //if (articleID) {
        //    // Remove the article so it doesn't get saved.
        //    Article *article = (Article *)[self.managedObjectContext objectWithID:articleID];
        //    [self.managedObjectContext deleteObject:article];
        //}
        //
        //// @TODO potentially do this in the difFailWithError in MWNetworkOp
        //// It seems safe enough, but we didn't want to cause any sort of memory leak
        //if (error.domain == NSStreamSocketSSLErrorDomain ||
        //    (error.domain == NSURLErrorDomain &&
        //     (error.code == NSURLErrorSecureConnectionFailed ||
        //      error.code == NSURLErrorServerCertificateHasBadDate ||
        //      error.code == NSURLErrorServerCertificateUntrusted ||
        //      error.code == NSURLErrorServerCertificateHasUnknownRoot ||
        //      error.code == NSURLErrorServerCertificateNotYetValid)
        //     )
        //    ) {
        //    [SessionSingleton sharedInstance].fallback = true;
        //}

        [delegate downloadFinishedForArticle: self
                                        type: ARTICLE_DOWNLOAD_TYPE_SECTIONS_LEAD
                                      result: ARTICLE_DOWNLOAD_RESULT_FAILED
                                       error: error];


    }];

    firstSectionOp.delegate = self;
    
    
    // Retrieval of remaining sections depends on retrieving first section
    [remainingSectionsOp addDependency:firstSectionOp];

    remainingSectionsOp.queuePriority = queuePriority;
    firstSectionOp.queuePriority = queuePriority;
    
    [[QueuesSingleton sharedInstance].articleRetrievalQ addOperation:remainingSectionsOp];
    [[QueuesSingleton sharedInstance].articleRetrievalQ addOperation:firstSectionOp];

}






@end
