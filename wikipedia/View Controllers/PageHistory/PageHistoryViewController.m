//  Created by Monte Hurd on 12/4/13.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "PageHistoryViewController.h"
#import "WikipediaAppUtils.h"
//#import "ArticleDataContextSingleton.h"
//#import "ArticleCoreDataObjects.h"
#import "WebViewController.h"
#import "PageHistoryResultCell.h"
#import "PageHistoryTableHeadingLabel.h"
#import "Defines.h"
#import "Article+Convenience.h"
#import "SessionSingleton.h"
#import "UINavigationController+SearchNavStack.h"
#import "NavController.h"
#import "PageHistoryOp.h"
#import "QueuesSingleton.h"
#import "NSString+Extras.h"
#import "NSDate-Utilities.h"
#import "TFHpple.h"
#import "UIViewController+Alert.h"

#import "UIImage+ColorMask.h"
#import "NSString+FormattedAttributedString.h"

#define NAV ((NavController *)self.navigationController)

#define SAVED_PAGES_TITLE_TEXT_COLOR [UIColor colorWithWhite:0.1f alpha:1.0f]
#define SAVED_PAGES_TEXT_COLOR [UIColor colorWithWhite:0.0f alpha:1.0f]
#define SAVED_PAGES_LANGUAGE_COLOR [UIColor colorWithWhite:0.0f alpha:0.4f]
#define SAVED_PAGES_RESULT_HEIGHT 116

@interface PageHistoryViewController ()
{
//    ArticleDataContextSingleton *articleDataContext_;
}

@property (strong, nonatomic) __block NSMutableArray *pageHistoryDataArray;
@property (strong, nonatomic) UIImage *smileImageGray;
@property (strong, nonatomic) UIImage *sleepImageGray;

@end

@implementation PageHistoryViewController

#pragma mark - Init

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View lifecycle

-(void)prepareImages
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIColor *color = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
        UIImage *smileImageGray = [[UIImage imageNamed:@"main_menu_face_smile_white.png"] getImageOfColor:color.CGColor];
        UIImage *sleepImageGray = [[UIImage imageNamed:@"main_menu_face_sleep_white.png"] getImageOfColor:color.CGColor];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.smileImageGray = smileImageGray;
            self.sleepImageGray = sleepImageGray;
        });
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getPageHistoryData];
}

-(PageHistoryTableHeadingLabel *)getHeadingLabel
{
    PageHistoryTableHeadingLabel *pageHistoryLabel =
        [[PageHistoryTableHeadingLabel alloc] initWithFrame:CGRectMake(0, 0, 10, 95)];
    
    NSMutableParagraphStyle *headingParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    [headingParagraphStyle setLineSpacing:14];
    [headingParagraphStyle setParagraphSpacing:0];
    
    NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    [titleParagraphStyle setParagraphSpacing:0];
    
    NSAttributedString *pageHistoryTitle =
    [@"$1\n$2" attributedStringWithAttributes: nil
                          substitutionStrings: @[
                                                 MWLocalizedString(@"page-history-title", nil),
                                                 [SessionSingleton sharedInstance].currentArticleTitle
                                                 ]
                       substitutionAttributes: @[
                                                 @{
                                                     NSFontAttributeName: [UIFont boldSystemFontOfSize:20],
                                                     NSParagraphStyleAttributeName: headingParagraphStyle
                                                     },
                                                 @{
                                                     NSFontAttributeName: [UIFont boldSystemFontOfSize:14],
                                                     NSParagraphStyleAttributeName: titleParagraphStyle
                                                     }
                                                 ]
     ];
    pageHistoryLabel.attributedText = pageHistoryTitle;
    pageHistoryLabel.numberOfLines = 0;
    pageHistoryLabel.textAlignment = NSTextAlignmentCenter;
    pageHistoryLabel.textColor = SAVED_PAGES_TITLE_TEXT_COLOR;
    pageHistoryLabel.backgroundColor = [UIColor whiteColor];

    return pageHistoryLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self prepareImages];

    self.navigationItem.hidesBackButton = YES;

    self.pageHistoryDataArray = @[].mutableCopy;

    self.tableView.tableHeaderView = [self getHeadingLabel];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.tableView.tableFooterView.backgroundColor = [UIColor whiteColor];
    
    // Register the Saved Pages results cell for reuse
    [self.tableView registerNib:[UINib nibWithNibName:@"PageHistoryResultPrototypeView" bundle:nil] forCellReuseIdentifier:@"PageHistoryResultCell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - PageHistory data

-(void)getPageHistoryData
{
    [[QueuesSingleton sharedInstance].pageHistoryQ cancelAllOperations];
    
    __weak PageHistoryViewController *weakSelf = self;
    
    PageHistoryOp *pageHistoryOp =
    [[PageHistoryOp alloc] initWithDomain: [SessionSingleton sharedInstance].currentArticleDomain
                                    title: [SessionSingleton sharedInstance].currentArticleTitle
                          completionBlock: ^(NSMutableArray * result){
                              
                              weakSelf.pageHistoryDataArray = result;
                              
                              dispatch_async(dispatch_get_main_queue(), ^(void){
                                  [weakSelf.tableView reloadData];
                              });
                          }
                           cancelledBlock: ^(NSError *error){
                               [self showAlert:error.localizedDescription];
                           }
                               errorBlock: ^(NSError *error){
                                   [self showAlert:error.localizedDescription];
                               }];
    pageHistoryOp.delegate = self;
    [[QueuesSingleton sharedInstance].pageHistoryQ addOperation:pageHistoryOp];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.pageHistoryDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionDict = self.pageHistoryDataArray[section];
    NSArray *rows = sectionDict[@"revisions"];
    return rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"PageHistoryResultCell";
    PageHistoryResultCell *cell = (PageHistoryResultCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    NSDictionary *sectionDict = self.pageHistoryDataArray[indexPath.section];
    NSArray *rows = sectionDict[@"revisions"];
    NSDictionary *row = rows[indexPath.row];
    
    //NSLog(@"row = %@", row);
    cell.separatorHeightConstraint.constant = (rows.count == 1) ? 0.0f : (1.0f / [UIScreen mainScreen].scale);

    NSDate *timeStamp = [row[@"timestamp"] getDateFromIso8601DateString];
    
    NSString *formattedTime = [NSDateFormatter localizedStringFromDate: timeStamp
                                                             dateStyle: NSDateFormatterNoStyle
                                                             timeStyle: NSDateFormatterShortStyle];
    
    NSString *commentNoHTML = [self getStringWithoutHTML:row[@"parsedcomment"]];

    NSNumber *delta = row[@"characterDelta"];
    
    cell.summaryLabel.text = commentNoHTML;
    cell.nameLabel.text = row[@"user"];
    cell.timeLabel.text = formattedTime;
    cell.deltaLabel.text = [NSString stringWithFormat:@"%@%@", (delta.integerValue > 0) ? @"+" : @"", delta.stringValue];
    
    cell.deltaLabel.textColor =
        (delta.integerValue > 0)
        ?
        [UIColor colorWithRed:0.00 green:0.69 blue:0.49 alpha:1.0]
        :
        [UIColor colorWithRed:0.95 green:0.00 blue:0.00 alpha:1.0]
        ;

    cell.loggedInImageView.image =
        (!row[@"anon"])
        ?
        self.smileImageGray
        :
        self.sleepImageGray
        ;







//Wikifont-Regular
cell.loggedInImageView.layer.borderWidth = 1.0f;








    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Getting dynamic cell height which respects auto layout constraints is tricky.

    // First get the cell configured exactly as it is for display.
    PageHistoryResultCell *cell =
        (PageHistoryResultCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];

    // Then coax the cell into taking on the size that would satisfy its layout constraints (and
    // return that size's height).
    // From: http://stackoverflow.com/a/18746930/135557
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    cell.bounds = CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, cell.bounds.size.height);
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    return ([cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1.0f);
}















//PULL THIS INTO CAT?

//truncate on june 10 austin lucas edit

- (NSString *)getStringWithoutHTML:(NSString *)string
{
    // Strips html from string with xpath / hpple.
if (!string || (string.length == 0)) return string;
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *parser = [TFHpple hppleWithHTMLData:stringData];
    NSArray *textNodes = [parser searchWithXPathQuery:@"//text()"];
    NSMutableArray *results = [@[] mutableCopy];
    for (TFHppleElement *node in textNodes) {
        if(node.isTextNode) [results addObject:node.raw];
    }
    
    NSString *result = [results componentsJoinedByString:@""];

    // Also decode any "&amp;" strings.
    result = [result stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];

    return result;
}





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

/*
    NSString *selectedCell = nil;
    NSDictionary *dict = self.pageHistoryDataArray[indexPath.section];
    NSArray *array = dict[@"data"];
    selectedCell = array[indexPath.row];

    __block Saved *savedEntry = nil;
    [articleDataContext_.mainContext performBlockAndWait:^(){
        NSManagedObjectID *savedEntryId = (NSManagedObjectID *)array[indexPath.row];
        savedEntry = (Saved *)[articleDataContext_.mainContext objectWithID:savedEntryId];
    }];
    
    [NAV loadArticleWithTitle: savedEntry.article.title
                       domain: savedEntry.article.domain
                     animated: YES
              discoveryMethod: DISCOVERY_METHOD_SEARCH];
*/

}


#pragma mark - Delete

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return NO;
//}

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.tableView.editing = NO;
        [self performSelector:@selector(deleteSavedPageForIndexPath:) withObject:indexPath afterDelay:0.15f];
    }
}

-(void)deleteSavedPageForIndexPath:(NSIndexPath *)indexPath
{
    [articleDataContext_.mainContext performBlockAndWait:^(){
        NSManagedObjectID *savedEntryId = (NSManagedObjectID *)self.pageHistoryDataArray[indexPath.section][@"data"][indexPath.row];
        Saved *savedEntry = (Saved *)[articleDataContext_.mainContext objectWithID:savedEntryId];
        if (savedEntry) {
            
            [self.tableView beginUpdates];

            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            NSError *error = nil;
            [articleDataContext_.mainContext deleteObject:savedEntry];
            [articleDataContext_.mainContext save:&error];
            
            [self.pageHistoryDataArray[indexPath.section][@"data"] removeObject:savedEntryId];
            
            [self.tableView endUpdates];
        }
    }];
}
*/



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    NSDictionary *dict = self.pageHistoryDataArray[section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
    view.autoresizesSubviews = YES;
    UILabel *label = [[UILabel alloc] initWithFrame:
        CGRectMake(10, view.bounds.origin.y, view.bounds.size.width, view.bounds.size.height)
    ];
    label.font = [UIFont boldSystemFontOfSize:12];
    label.textColor = [UIColor darkGrayColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.backgroundColor = [UIColor clearColor];


NSDictionary *sectionDict = self.pageHistoryDataArray[section];

NSNumber *daysAgo = sectionDict[@"daysAgo"];
NSDate *date = [NSDate dateWithDaysBeforeNow:daysAgo.integerValue];

NSString *formattedDate = [NSDateFormatter localizedStringFromDate: date
                                                         dateStyle: NSDateFormatterLongStyle
                                                         timeStyle: NSDateFormatterNoStyle];


    NSString *title = formattedDate;
    //NSString *dateString = dict[@"sectionDateString"];

//NSLog(@"title = %@", title);

label.text = title;
//    label.attributedText = [self getAttributedHeaderForTitle:title dateString:dateString];

    [view addSubview:label];

    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 27;
}

@end
