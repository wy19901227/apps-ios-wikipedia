//  Created by Monte Hurd on 10/9/14.
//  Copyright (c) 2014 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "ArticleFetcher.h"

#import "Article.h"
#import "Section.h"

#import "QueuesSingleton.h"
#import "ArticleDataContextSingleton.h"
#import "ArticleCoreDataObjects.h"
#import "MWPageTitle.h"
#import "Section+ImageRecords.h"
#import "Section+LeadSection.h"
#import "NSString+Extras.h"

#import "AFHTTPRequestOperationManager.h"
#import "SessionSingleton.h"
#import "ReadingActionFunnel.h"
#import "NSURLRequest+DictionaryRequest.h"
#import "NSString+Extras.h"
#import "NSObject+Extras.h"
#import "MWNetworkActivityIndicatorManager.h"

@interface ArticleFetcher()

// The Article object to be updated with the downloaded data.
@property (nonatomic, strong) Article *articleDelegate;

@end

@implementation ArticleFetcher

-(instancetype)initAndFetchArticle: (Article *)article
                       withManager: (AFHTTPRequestOperationManager *)manager
                thenNotifyDelegate: (id <FetchFinishedDelegate>) delegate
{
    self = [super init];
    if (self) {
        self.articleDelegate = article;
        self.fetchFinishedDelegate = delegate;
        [self fetchWithManager:manager];
    }
    return self;
}

-(void)fetchWithManager:(AFHTTPRequestOperationManager *)manager
{
    NSString *title = self.articleDelegate.title;
    NSString *domain = self.articleDelegate.domain;
    
    if (!self.articleDelegate) {
        NSLog(@"NO ARTICLE DELEGATE");
        return;
    }
    if (!self.fetchFinishedDelegate) {
        NSLog(@"NO DOWNLOAD DELEGATE");
        return;
    }
    if(!domain){
        NSLog(@"NO DOMAIN");
        return;
    }
    if(!title){
        NSLog(@"NO TITLE");
        return;
    }

    NSURL *url = [[SessionSingleton sharedInstance] urlForDomain:domain];
    
    void (^getNonLeadSections)() = ^void() {
        // Get the remaining sections data.
        NSDictionary *params = [self getParamsForTitle:title leadSectionOnly:NO];
        
        [[MWNetworkActivityIndicatorManager sharedManager] push];

        [manager GET:url.absoluteString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[MWNetworkActivityIndicatorManager sharedManager] pop];
            //NSLog(@"JSON: %@", responseObject);
            
            NSDictionary *nonLeadSectionsResults = [self prepareResultsFromResponse:responseObject forTitle:title];
            
            [self applyResultsForNonLeadSections:nonLeadSectionsResults];

            [self finishWithError: nil
                         userData: self.articleDelegate
                             type: ARTICLE_FETCH_TYPE_SECTIONS_NONLEAD];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[MWNetworkActivityIndicatorManager sharedManager] pop];
            NSLog(@"Error: %@", error);

            [self finishWithError: error
                         userData: self.articleDelegate
                             type: ARTICLE_FETCH_TYPE_SECTIONS_NONLEAD];

        }];
    };
    
    
    // First retrieve lead section data, then get the remaining sections data.

    NSDictionary *params = [self getParamsForTitle:title leadSectionOnly:YES];
    
    [[MWNetworkActivityIndicatorManager sharedManager] push];

    [manager GET:url.absoluteString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        [[MWNetworkActivityIndicatorManager sharedManager] pop];
        
        NSDictionary *leadSectionResults = [self prepareResultsFromResponse:responseObject forTitle:title];
        
        [self applyResultsForLeadSection:leadSectionResults];

        [self finishWithError: nil
                     userData: self.articleDelegate
                         type: ARTICLE_FETCH_TYPE_SECTIONS_LEAD];
        

        // Now that lead section data has been retrieved, get the remaining sections data.
        getNonLeadSections();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [[MWNetworkActivityIndicatorManager sharedManager] pop];

        [self finishWithError: error
                     userData: self.articleDelegate
                         type: ARTICLE_FETCH_TYPE_SECTIONS_LEAD];

    }];
}

-(NSDictionary *)getParamsForTitle:(NSString *)title leadSectionOnly:(BOOL)leadSectionOnly
{
    NSMutableDictionary *params = @{
    @"format": @"json",
    @"action": @"mobileview",
    @"sectionprop": @"toclevel|line|anchor|level|number|fromtitle|index",
    @"noheadings": @"true",
    @"page": title,
    @"prop": @"sections|text|lastmodified|lastmodifiedby|languagecount|id|protection|editable|displaytitle",
    }.mutableCopy;

    if (!leadSectionOnly) {
        params[@"onlyrequestedsections"] = @"1";
        params[@"sections"] = @"1-";
    }else{

        //Reminder: do not set @"onlyrequestedsections": @"1" for lead section.
        //Need to see keys for the subsequent sections so the "needsRefresh"
        //value can be left YES until subsequent sections have been retrieved
        //(if there's more than a single section).

        params[@"sections"] = @"0";
        
        if ([SessionSingleton sharedInstance].sendUsageReports) {
            ReadingActionFunnel *funnel = [[ReadingActionFunnel alloc] init];
            params[@"appInstallID"] = funnel.appInstallID;
        }
    }
    return params;
}

-(NSDictionary *)prepareResultsFromResponse:(NSDictionary *)response forTitle:(NSString *)title
{
    // Returns results dictionary with sanitized info from response.
    
    NSArray *sections = response[@"mobileview"][@"sections"];
    
    NSMutableArray *outputSections = @[].mutableCopy;
    
    // The fromtitle tells us if a section was transcluded, but the api sometimes returns false instead
    // of just leaving it out if the section wasn't transcluded. It is also sometimes the name of the
    // current article, which is redundant. So here remove the fromtitle key/value in both of these
    // cases. That way the existense of a "fromtitle" can be relied on as a true transclusion indicator.
    // Todo: pull this out into own method within this file.
    for (NSDictionary *section in sections) {
        NSMutableDictionary *mutableSection = section.mutableCopy;
        if ([mutableSection[@"fromtitle"] isKindOfClass:[NSString class]]) {
            NSString *fromTitle = mutableSection[@"fromtitle"];
            if ([[title wikiTitleWithoutUnderscores] isEqualToString:[fromTitle wikiTitleWithoutUnderscores]]) {
                [mutableSection removeObjectForKey:@"fromtitle"];
            }
        }else{
            [mutableSection removeObjectForKey:@"fromtitle"];
        }
        [outputSections addObject:mutableSection];
    }
    
    NSString *lastmodifiedDateString = response[@"mobileview"][@"lastmodified"];
    NSDate *lastmodifiedDate = [lastmodifiedDateString getDateFromIso8601DateString];
    if (!lastmodifiedDate || [lastmodifiedDate isNull]) {
        NSLog(@"Bad lastmodified date, will show as recently modified as a workaround");
        lastmodifiedDate = [[NSDate alloc] init];
    }
    
    NSDictionary *lastmodifiedbyDict = response[@"mobileview"][@"lastmodifiedby"];
    NSString *lastmodifiedby = @"";
    if (lastmodifiedbyDict && (![lastmodifiedbyDict isNull]) && lastmodifiedbyDict[@"name"]) {
        lastmodifiedby = lastmodifiedbyDict[@"name"];
    }
    if (!lastmodifiedby || [lastmodifiedby isNull]) lastmodifiedby = @"";
    
    NSNumber *languagecount = response[@"mobileview"][@"languagecount"];
    if (!languagecount || [languagecount isNull]) languagecount = @1;
    
    NSString *redirected = response[@"mobileview"][@"redirected"];
    if (!redirected || [redirected isNull]) redirected = @"";
    
    NSNumber *articleId = response[@"mobileview"][@"id"];
    if (!articleId || [articleId isNull]) articleId = @0;
    
    NSNumber *editable = response[@"mobileview"][@"editable"];
    if (!editable || [editable isNull]) editable = @NO;

    NSString *displaytitle = response[@"mobileview"][@"displaytitle"];
    if (!displaytitle || [displaytitle isNull]) displaytitle = @"";
    
    NSString *protectionStatus = @"";
    id protection = response[@"mobileview"][@"protection"];
    // if empty this can be an array instead of an object/dict!
    // https://bugzilla.wikimedia.org/show_bug.cgi?id=67054
    if (protection && [protection isKindOfClass:[NSDictionary class]]) {
        NSDictionary *protectionDict = (NSDictionary *)protection;
        if (protectionDict[@"edit"] && [protection[@"edit"] count] > 0) {
            protectionStatus = protectionDict[@"edit"][0];
        }
    }
    if (!protectionStatus || [protectionStatus isNull]) protectionStatus = @"";
    
    NSMutableDictionary *output = @{
                                    @"sections": outputSections,
                                    @"lastmodified": lastmodifiedDate,
                                    @"lastmodifiedby": lastmodifiedby,
                                    @"redirected": redirected,
                                    @"displaytitle": displaytitle,
                                    @"languagecount": languagecount,
                                    @"articleId": articleId,
                                    @"editable": editable,
                                    @"protectionStatus": protectionStatus
                                    }.mutableCopy;
    
    return output;
}

-(void)applyResultsForLeadSection:(NSDictionary *)results
{
    // Updates the article with the lead section data which was retrieved.
    
    [self.articleDelegate.managedObjectContext performBlockAndWait:^(){
        
        // If "needsRefresh", an existing article's data is being retrieved again, so these need
        // to be updated whether a new article record is being inserted or not as data may have
        // changed since the article record was first created.
        self.articleDelegate.languagecount = results[@"languagecount"];
        self.articleDelegate.lastmodified = results[@"lastmodified"];
        self.articleDelegate.lastmodifiedby = results[@"lastmodifiedby"];
        self.articleDelegate.articleId = results[@"articleId"];
        self.articleDelegate.editable = results[@"editable"];
        self.articleDelegate.protectionStatus = results[@"protectionStatus"];
        self.articleDelegate.displayTitle = results[@"displaytitle"];
        
        // Note: Because "retrieveArticleForPageTitle" recurses with the redirected-to title if
        // the lead section op determines a redirect occurred, the "redirected" value below will
        // probably never be set.
        self.articleDelegate.redirected = results[@"redirected"];
        
        //NSDateFormatter *anotherDateFormatter = [[NSDateFormatter alloc] init];
        //[anotherDateFormatter setDateStyle:NSDateFormatterLongStyle];
        //[anotherDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        //NSLog(@"formatted lastmodified = %@", [anotherDateFormatter stringFromDate:self.articleDelegate.lastmodified]);
        
        self.articleDelegate.lastScrollX = @0.0f;
        self.articleDelegate.lastScrollY = @0.0f;
        
        // Get article section zero html
        NSArray *sectionsRetrieved = results[@"sections"];
        NSDictionary *section0Dict = (sectionsRetrieved.count >= 1) ? sectionsRetrieved[0] : nil;
        
        // If there was only one section then we have what we need so no refresh
        // is needed. Otherwise leave needsRefresh set to YES until subsequent sections
        // have been retrieved. Reminder: "onlyrequestedsections" is not used
        // by the mobileview query so that sectionsRetrieved.count will
        // reflect the article's total number of sections here ("sections"
        // was set to "0" though so only the first section entry actually has
        // any html). This fixes the bug which caused subsequent sections to never
        // be retrieved if the article was navigated away from before they had loaded.
        self.articleDelegate.needsRefresh = (sectionsRetrieved.count == 1) ? @NO : @YES;
        
        NSString *section0HTML = @"";
        if (section0Dict && [section0Dict[@"id"] isEqual: @0] && section0Dict[@"text"]) {
            section0HTML = section0Dict[@"text"];
        }
        
        // Add sections for article
        Section *section0 = [NSEntityDescription insertNewObjectForEntityForName:@"Section" inManagedObjectContext:self.articleDelegate.managedObjectContext];
        // Section index is a string because transclusion sections indexes will start with "T-"
        section0.index = @"0";
        section0.level = @"0";
        section0.number = @"0";
        section0.sectionId = @0;
        section0.title = @"";
        section0.dateRetrieved = [NSDate date];
        section0.html = section0HTML;
        section0.anchor = @"";
        
        [self.articleDelegate addSectionObject:section0];
        
        [section0 createImageRecordsForHtmlOnContext:self.articleDelegate.managedObjectContext];
    }];
}

-(void)applyResultsForNonLeadSections:(NSDictionary *)results
{
    // Updates the article with the non-lead section data which was retrieved.
    
    [self.articleDelegate.managedObjectContext performBlockAndWait:^(){
        
        //Non-lead sections have been retreived so set needsRefresh to NO.
        self.articleDelegate.needsRefresh = @NO;
        
        NSArray *sectionsRetrieved = results[@"sections"];
        
        for (NSDictionary *section in sectionsRetrieved) {
            if (![section[@"id"] isEqual: @0]) {
                
                // Add sections for article
                Section *thisSection = [NSEntityDescription insertNewObjectForEntityForName:@"Section" inManagedObjectContext:self.articleDelegate.managedObjectContext];
                
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
                
                [self.articleDelegate addSectionObject:thisSection];
                
                [thisSection createImageRecordsForHtmlOnContext:self.articleDelegate.managedObjectContext];
            }
        }
    }];
}

/*
-(void)dealloc
{
    NSLog(@"DEALLOC'ING ARTICLE FETCHER!");
}
*/

@end
