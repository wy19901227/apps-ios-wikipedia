//  Created by Monte Hurd on 12/18/13.

#import "MainMenuTableViewController.h"
#import "MainMenuSectionHeadingLabel.h"
#import "SessionSingleton.h"
#import "LoginViewController.h"
#import "HistoryViewController.h"
#import "SavedPagesViewController.h"
#import "QueuesSingleton.h"
#import "DownloadTitlesForRandomArticlesOp.h"
#import "SessionSingleton.h"
#import "WebViewController.h"
#import "WikipediaAppUtils.h"
#import "NavController.h"
#import "LanguagesTableVC.h"
#import "MainMenuResultsCell.h"

#import "UINavigationController+SearchNavStack.h"
#import "UIViewController+HideKeyboard.h"
#import "UIView+TemporaryAnimatedXF.h"
#import "UIViewController+Alert.h"
#import "UIImage+ColorMask.h"
#import "NSString+FormattedAttributedString.h"
#import "UINavigationController+TopActionSheet.h"
#import "MainMenuRowView.h"

#define NAV ((NavController *)self.navigationController)

#define BACKGROUND_COLOR [UIColor colorWithWhite:0.97f alpha:1.0f]
#define THUMBNAIL_IMAGE_COLOR [UIColor blackColor]
#define THUMBNAIL_IMAGE_COLOR_UNSELECTED [UIColor lightGrayColor]






typedef enum {
    ROW_INDEX_LOGIN = 0,
    ROW_INDEX_RANDOM = 1,
    ROW_INDEX_HISTORY = 2,
    ROW_INDEX_SAVED_PAGES = 3,
    ROW_INDEX_SAVE_PAGE = 4,
    ROW_INDEX_SEARCH_LANGUAGE = 5,
    ROW_INDEX_ZERO_WARN_WHEN_LEAVING = 6,
    ROW_INDEX_SEND_FEEDBACK = 7

} MainMenuRowIndex;









// Section indices.
typedef enum {
    SECTION_INDEX_LOGIN_OPTIONS = 0,
    SECTION_INDEX_MENU_OPTIONS = 1,
    SECTION_INDEX_ARTICLE_OPTIONS = 2,
    SECTION_INDEX_SEARCH_LANGUAGE_OPTIONS = 3,
    SECTION_INDEX_ZERO_OPTIONS = 4
} MainMenuSectionIndex;

// Row indexes.
#define ROW_SAVED_PAGES 2

@interface MainMenuTableViewController (){
}

@property (strong, atomic) NSMutableArray *tableData;
@property (atomic) BOOL hidePagesSection;
@property (nonatomic, strong) dispatch_queue_t thumbColorDispatchQ;

@property (strong, atomic) NSMutableArray *rowData;
@property (strong, atomic) NSMutableArray *rowViews;

@end

@implementation MainMenuTableViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.thumbColorDispatchQ = dispatch_queue_create("com.wikimedia.wikipedia.menu.main.thumbColorQ", NULL);

    self.hidePagesSection = NO;
    self.navigationItem.hidesBackButton = YES;
    self.tableData = [[NSMutableArray alloc] init];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // Register the menu results cell for reuse
    [self.tableView registerNib: [UINib nibWithNibName:@"MainMenuResultPrototypeView" bundle:nil]
         forCellReuseIdentifier: @"MainMenuResultsCell"];

    self.view.backgroundColor = BACKGROUND_COLOR;
    
    // Makes iOS 6 not use gross striped background pattern.
    [self.tableView setBackgroundView:nil];

self.rowViews = @[].mutableCopy;

[self loadRowViews];

}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableData removeAllObjects];
    
    // Adds data for sections/rows to tableData (but does not load language rows)
    [self loadTableData];

    NSString *currentArticleTitle = [SessionSingleton sharedInstance].currentArticleTitle;

    if(!currentArticleTitle || (currentArticleTitle.length == 0)){
        self.hidePagesSection = YES;
        [[self sectionDict:SECTION_INDEX_ARTICLE_OPTIONS][@"rows"] removeAllObjects];
    }else{
        self.hidePagesSection = NO;
    }
    
    [self updateLoginButtons];
    [self updateLoginTitle];

    [self.tableView reloadData];
















//[self loadRowViews];
[self updateRowViews];

//show
[self.navigationController topActionSheetShowWithViews:self.rowViews orientation:TOP_ACTION_SHEET_LAYOUT_HORIZONTAL];


[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topActionSheetItemTappedNotification:) name:@"TopActionSheetItemTapped" object:nil];
}

-(void)loadRowViews
{
// Don't forget - had to select "File's Owner" in left column of xib and then choose
// this view controller in the Identity Inspector (3rd icon from left in right column)
// in the Custom Class / Class dropdown. See: http://stackoverflow.com/a/21991592
UINib *mainMenuRowViewNib = [UINib nibWithNibName:@"MainMenuRowView" bundle:nil];

//NSMutableArray *rows = @[].mutableCopy;

//for (NSDictionary *section in self.tableData) {
[self getRowData];
//[self updateLoginRow];
    for (NSUInteger i = 0; i < self.rowData.count; i++) {
//        NSMutableDictionary *row = self.rowData[i];
    //for (NSDictionary *row in [self getRowData]) {

        MainMenuRowView *rowView = [[mainMenuRowViewNib instantiateWithOwner:self options:nil] firstObject];

rowView.tag = i;

        [self.rowViews addObject:rowView];
        
//        id title = row[@"title"];
//        if([title isKindOfClass:[NSString class]]){
//            rowView.textLabel.text = title;
//        }else if([title isKindOfClass:[NSAttributedString class]]){
//            rowView.textLabel.attributedText = title;
//        }

//        row[@"label"] = rowView.textLabel;
//        row[@"view"] = rowView;

//        rowView.thumbnailImageView.image =[[UIImage imageNamed:row[@"imageName"]] getImageOfColor:[UIColor colorWithRed:0.03 green:0.68 blue:0.55 alpha:1.0].CGColor];
//        [rows addObject:rowView];
    }
//  [self.navigationController topActionSheetShowWithViews:self.rowViews orientation:TOP_ACTION_SHEET_LAYOUT_HORIZONTAL];
  

}

-(void)updateRowViews
{
    [self updateLoginRow];
    [self applyTitlesToLabels];
    [self applyHighlightToRows];
    [self applyThumbnailsToRows];

}

-(void)applyThumbnailsToRows
{

    for (NSUInteger i = 0; i < self.rowData.count; i++) {
        NSMutableDictionary *row = self.rowData[i];
    //for (NSDictionary *row in [self getRowData]) {

        MainMenuRowView *rowView = self.rowViews[i];
        rowView.imageName = row[@"imageName"];
        
//        NSNumber *highlighted = row[@"highlighted"];
//
//        UIColor *rowColor =(!highlighted) ?
//        [UIColor colorWithRed:0.03 green:0.68 blue:0.55 alpha:1.0]
//        :
//        [UIColor lightGrayColor]
//        ;
//        
//        rowView.thumbnailImageView.image =[[UIImage imageNamed:row[@"imageName"]] getImageOfColor:rowColor.CGColor];
//

    }

}

-(void)applyHighlightToRows
{

    for (NSUInteger i = 0; i < self.rowData.count; i++) {
        NSMutableDictionary *row = self.rowData[i];
    //for (NSDictionary *row in [self getRowData]) {

        MainMenuRowView *rowView = self.rowViews[i];
        NSLog(@"%@ %@", rowView.textLabel.text, row[@"highlighted"]);
        rowView.highlighted = row[@"highlighted"];
        
//        NSNumber *highlighted = row[@"highlighted"];
//
//        UIColor *rowColor =(!highlighted) ?
//        [UIColor colorWithRed:0.03 green:0.68 blue:0.55 alpha:1.0]
//        :
//        [UIColor lightGrayColor]
//        ;
//        
//        rowView.thumbnailImageView.image =[[UIImage imageNamed:row[@"imageName"]] getImageOfColor:rowColor.CGColor];
//

    }

}

-(void)applyTitlesToLabels
{

    for (NSUInteger i = 0; i < self.rowData.count; i++) {
        NSMutableDictionary *row = self.rowData[i];
    //for (NSDictionary *row in [self getRowData]) {

        MainMenuRowView *rowView = self.rowViews[i];
        id title = row[@"title"];
        if([title isKindOfClass:[NSString class]]){
            rowView.textLabel.text = title;
        }else if([title isKindOfClass:[NSAttributedString class]]){
            rowView.textLabel.attributedText = title;
        }
    }

}



- (void)topActionSheetItemTappedNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    MainMenuRowView *tappedItem = userInfo[@"tappedItem"];







    CGFloat animationDuration = 0.1f;

    NSMutableDictionary *row = self.rowData[tappedItem.tag];
    NSString *imageName = [row objectForKey:@"imageName"];

    if (tappedItem.tag == ROW_INDEX_ZERO_WARN_WHEN_LEAVING) {
        animationDuration = 0.0f;
    }

    if (imageName && (imageName.length > 0) && (animationDuration > 0)) {
//        MainMenuResultsCell *cell = (MainMenuResultsCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [tappedItem.thumbnailImageView animateAndRewindXF: CATransform3DMakeScale(1.35f, 1.35f, 1.0f)
                      afterDelay: 0.0
                        duration: animationDuration];
    }else{
        animationDuration = 0.0f;
    }






    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (animationDuration * 2.0f) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        switch (tappedItem.tag) {
            case ROW_INDEX_LOGIN:
                
            {
                NSString *userName = [SessionSingleton sharedInstance].keychainCredentials.userName;
                if (!userName) {
                    
                    LoginViewController *loginVC =
                        [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                    [self.navigationController pushViewController:loginVC animated:YES];
[self.navigationController topActionSheetHide];
                    
                }else{
                    
                    [SessionSingleton sharedInstance].keychainCredentials.userName = nil;
                    [SessionSingleton sharedInstance].keychainCredentials.password = nil;
                    [SessionSingleton sharedInstance].keychainCredentials.editTokens = nil;
                    
                    // Clear session cookies too.
                    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies copy]) {
                        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
                    }
                    
                    //                [self updateLoginButtons];
                    //                [self updateLoginTitle];
                    //                [self.tableView reloadData];
                    
                }
                [self updateRowViews];
                
                
            }
            
            
                break;
            case ROW_INDEX_RANDOM:
                [self showAlert:NSLocalizedString(@"fetching-random-article", nil)];
                [self fetchRandomArticle];
[self.navigationController topActionSheetHide];

                break;
            case ROW_INDEX_HISTORY:
            {
                HistoryViewController *historyVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
                [self.navigationController pushViewController:historyVC animated:YES];
[self.navigationController topActionSheetHide];
            }
                break;
            case ROW_INDEX_SAVED_PAGES:
            {
                SavedPagesViewController *savedPagesVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"SavedPagesViewController"];
                [self.navigationController pushViewController:savedPagesVC animated:YES];
[self.navigationController topActionSheetHide];
            }
                break;
            case ROW_INDEX_SAVE_PAGE:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SavePage" object:self userInfo:nil];
                [self animateArticleTitleMovingToSavedPages2];
//[self.navigationController topActionSheetHide];
                break;
            case ROW_INDEX_SEARCH_LANGUAGE:
[self showLanguages];
[self.navigationController topActionSheetHide];
                break;
            case ROW_INDEX_ZERO_WARN_WHEN_LEAVING:

NSLog(@"warnWhenLeaving = %d", [SessionSingleton sharedInstance].zeroConfigState.warnWhenLeaving);

[[SessionSingleton sharedInstance].zeroConfigState toggleWarnWhenLeaving];

NSLog(@"warnWhenLeaving = %d", [SessionSingleton sharedInstance].zeroConfigState.warnWhenLeaving);

[self getRowData];
[self updateRowViews];

                break;
            case ROW_INDEX_SEND_FEEDBACK:
            {
                NSString *mailtoUri =
                [NSString stringWithFormat:@"mailto:mobile-ios-wikipedia@wikimedia.org?subject=Feedback:%@", [WikipediaAppUtils appVersion]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailtoUri]];
            }
                break;
            default:
                break;
        }
        
        
        
        
        NSLog(@"ACTION TAPPED = %d", tappedItem.tag);
    });

//    [self.navigationController topActionSheetHide];
}
/*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (animationDuration * 2.0f) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[QueuesSingleton sharedInstance].randomArticleQ cancelAllOperations];
        NSDictionary *sectionDict = [self sectionDict:indexPath.section];
        
        NSString *selectedSectionKey = sectionDict[@"key"];
        
        NSMutableDictionary *rowDict = [self rowDict:indexPath];
        NSString *selectedRowKey = rowDict[@"key"];
        //NSLog(@"menu item selection key = %@", selectedKey);
        
        if ([selectedRowKey isEqualToString:@"login"]) {
            
            LoginViewController *loginVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self.navigationController pushViewController:loginVC animated:YES];
            
        }else if ([selectedRowKey isEqualToString:@"logout"]) {
            
            [SessionSingleton sharedInstance].keychainCredentials.userName = nil;
            [SessionSingleton sharedInstance].keychainCredentials.password = nil;
            [SessionSingleton sharedInstance].keychainCredentials.editTokens = nil;
            
            // Clear session cookies too.
            for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies copy]) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
            
            [self updateLoginButtons];
            [self updateLoginTitle];
            [self.tableView reloadData];
            
        }else if ([selectedRowKey isEqualToString:@"history"]) {
            
            HistoryViewController *historyVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
            [self.navigationController pushViewController:historyVC animated:YES];
            
        }else if ([selectedRowKey isEqualToString:@"savedPages"]) {
            
            SavedPagesViewController *savedPagesVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"SavedPagesViewController"];
            [self.navigationController pushViewController:savedPagesVC animated:YES];
            
        }else if ([selectedRowKey isEqualToString:@"savePage"]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SavePage" object:self userInfo:nil];
            
            [self animateArticleTitleMovingToSavedPages];
            
        }else if ([selectedSectionKey isEqualToString:@"searchLanguageOptions"]) {
            
            [self showLanguages];
            
        }  else if ([selectedRowKey isEqualToString:@"zeroWarnWhenLeaving"]) {
            
            [[SessionSingleton sharedInstance].zeroConfigState toggleWarnWhenLeaving];
            
            [self.tableView reloadData];
            
        } else if ([selectedRowKey isEqualToString:@"randomTappable"]) {
            
            [self showAlert:NSLocalizedString(@"fetching-random-article", nil)];
            [self fetchRandomArticle];
            
        } else if ([selectedRowKey isEqualToString:@"sendFeedback"]) {
            
            NSString *mailtoUri =
            [NSString stringWithFormat:@"mailto:mobile-ios-wikipedia@wikimedia.org?subject=Feedback:%@", [WikipediaAppUtils appVersion]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailtoUri]];
            
        }
    });

*/



-(void)getRowData
{
    NSString *currentArticleTitle = [SessionSingleton sharedInstance].currentArticleTitle;

    NSDictionary *highlightedText = @{
        NSFontAttributeName: [UIFont italicSystemFontOfSize:16]
    };

    NSAttributedString *searchWikiTitle =
    [NSLocalizedString(@"main-menu-language-title", nil) attributedStringWithAttributes: nil
                                                                    substitutionStrings: @[[SessionSingleton sharedInstance].domainName]
                                                                 substitutionAttributes: @[highlightedText]
     ];

    NSAttributedString *saveArticleTitle =
    [NSLocalizedString(@"main-menu-current-article-save", nil) attributedStringWithAttributes: nil
                                                                    substitutionStrings: @[currentArticleTitle]
                                                                 substitutionAttributes: @[highlightedText]
     ];


/*

-(void)updateLoginButtons
{
    // Show login/logout buttons
    [[self sectionDict:SECTION_INDEX_LOGIN_OPTIONS][@"rows"] removeAllObjects];
    if([SessionSingleton sharedInstance].keychainCredentials.userName){
        [self addToTableDataRowWithTitle: NSLocalizedString(@"main-menu-account-logout", nil)
                               imageName: @"main_menu_face_smile_white.png"
                                     key: @"logout"
                                 section: SECTION_INDEX_LOGIN_OPTIONS];
    }else{
        [self addToTableDataRowWithTitle: NSLocalizedString(@"main-menu-account-login", nil)
                               imageName: @"main_menu_face_sleep_white.png"
                                     key: @"login"
                                 section: SECTION_INDEX_LOGIN_OPTIONS];
    }
}

-(void)updateLoginTitle
{
    NSString *userName = [SessionSingleton sharedInstance].keychainCredentials.userName;
    if(userName){
    
        NSString *loggedInAsTitle = NSLocalizedString(@"main-menu-account-title-logged-in", nil);
        loggedInAsTitle = [loggedInAsTitle stringByReplacingOccurrencesOfString:@"$1" withString:userName];
    
        [self sectionDict:SECTION_INDEX_LOGIN_OPTIONS][@"title"] = loggedInAsTitle;
    }else{
        [self sectionDict:SECTION_INDEX_LOGIN_OPTIONS][@"title"] = NSLocalizedString(@"main-menu-account-title-logged-out", nil);
    }
}

*/

//    id loginTitle = nil;
//    NSString *loginImageName = nil;
//    NSString *userName = [SessionSingleton sharedInstance].keychainCredentials.userName;
//    if(userName){
////        loginTitle = (NSString *)loginTitle;
//        NSString *loginTitle2 = [NSLocalizedString(@"main-menu-account-logout", nil) stringByAppendingString:@" $1"];
//  //      loginTitle = [loginTitle stringByAppendingString:@"$1" withString:userName];
//
//
//
//
//
//
//    loginTitle =
//    [loginTitle2 attributedStringWithAttributes: nil
//                            substitutionStrings: @[userName]
//                         substitutionAttributes: @[highlightedText]
//     ];
//
//
//
//        loginImageName = @"main_menu_face_smile_white.png";
//    }else{
//        loginTitle = NSLocalizedString(@"main-menu-account-login", nil);
//        loginImageName = @"main_menu_face_sleep_white.png";
//    }

    NSMutableArray *rowData =
    @[
      @{
          @"title": @"",
          @"imageName": @"",
          @"highlighted": @YES,
          }.mutableCopy
      ,
      @{
          @"title": NSLocalizedString(@"main-menu-random", nil),
          @"imageName": @"main_menu_dice_white.png",
          @"highlighted": @YES,
          }.mutableCopy
      ,
      @{
          @"title": NSLocalizedString(@"main-menu-show-history", nil),
          @"imageName": @"main_menu_clock_white.png",
          @"highlighted": @YES,
          }.mutableCopy
      ,
      @{
          @"title": NSLocalizedString(@"main-menu-show-saved", nil),
          @"imageName": @"main_menu_bookmark_white.png",
          @"highlighted": @YES,
          }.mutableCopy
      ,
      @{
          @"title": saveArticleTitle,
          @"imageName": @"main_menu_save.png",
          @"highlighted": @YES,
          }.mutableCopy
      ,
      @{
/*was key*/@"domain": [SessionSingleton sharedInstance].domain,
          @"title": searchWikiTitle,
          @"imageName": @"main_menu_foreign_characters_gray.png",
          @"highlighted": @YES,
          }.mutableCopy
      ,
      @{
          @"title": NSLocalizedString(@"zero-warn-when-leaving", nil),
          @"imageName": @"main_menu_flag_white.png",
          @"highlighted":
            (([SessionSingleton sharedInstance].zeroConfigState.warnWhenLeaving) ? @YES : @NO),
          }.mutableCopy
      ,
      @{
          @"title": NSLocalizedString(@"main-menu-send-feedback", nil),
          @"imageName": @"main_menu_envelope_white.png",
          @"highlighted": @YES,
          }.mutableCopy
      
      ].mutableCopy;

self.rowData = rowData;
}

-(void)updateLoginRow
{

    NSDictionary *highlightedText = @{
        NSFontAttributeName: [UIFont italicSystemFontOfSize:16]
    };



    id loginTitle = nil;
    NSString *loginImageName = nil;
    NSString *userName = [SessionSingleton sharedInstance].keychainCredentials.userName;
    if(userName){
        //loginTitle = (NSString *)loginTitle;
        NSString *loginTitle2 = [NSLocalizedString(@"main-menu-account-logout", nil) stringByAppendingString:@" $1"];
        //loginTitle = [loginTitle stringByAppendingString:@"$1" withString:userName];
        


        loginTitle =
        [loginTitle2 attributedStringWithAttributes: nil
                                substitutionStrings: @[userName]
                             substitutionAttributes: @[highlightedText]
         ];


        
        loginImageName = @"main_menu_face_smile_white.png";
    }else{
        loginTitle = NSLocalizedString(@"main-menu-account-login", nil);
        loginImageName = @"main_menu_face_sleep_white.png";
    }
    
    self.rowData[ROW_INDEX_LOGIN][@"title"] = loginTitle;
    self.rowData[ROW_INDEX_LOGIN][@"imageName"] = loginImageName;
    
//[self applyTitlesToLabels];

    
    
}

-(void)updateZeroWarningRow
{
    
//    self.rowData[ROW_INDEX_ZERO_WARN_WHEN_LEAVING][@"title"] = loginTitle;
//    self.rowData[ROW_INDEX_LOGIN][@"imageName"] = loginImageName;
//    
//
//    if ([row[@"key"] isEqualToString:@"zeroWarnWhenLeaving"]) {
//        if (![SessionSingleton sharedInstance].zeroConfigState.warnWhenLeaving) {
//            thumbnailColor = THUMBNAIL_IMAGE_COLOR_UNSELECTED;
//        }
//    }

    
    
}


-(void)animateArticleTitleMovingToSavedPages2
{
//    NSIndexPath *savedPagesIndexPath = [NSIndexPath indexPathForRow:ROW_SAVED_PAGES inSection:SECTION_INDEX_MENU_OPTIONS];
//    NSDictionary *savedPagesRow = [self rowDict:savedPagesIndexPath];
//
//    NSIndexPath *savedPageIndexPath = [NSIndexPath indexPathForRow:0 inSection:SECTION_INDEX_ARTICLE_OPTIONS];
//    NSDictionary *saveThisPageRow = [self rowDict:savedPageIndexPath];

//    @[
//      @{
//          @"title": loginTitle,
//          @"imageName": loginImageName,
//          @"label": @""
//          }.mutableCopy
//      ,

/*

typedef enum {
    ROW_INDEX_LOGIN = 0,
    ROW_INDEX_RANDOM = 1,
    ROW_INDEX_HISTORY = 2,
    ROW_INDEX_SAVED_PAGES = 3,
    ROW_INDEX_SAVE_PAGE = 4,
    ROW_INDEX_SEARCH_LANGUAGE = 5,
    ROW_INDEX_ZERO_WARN_WHEN_LEAVING = 6,
    ROW_INDEX_SEND_FEEDBACK = 7

} MainMenuRowIndex;

*/



    UILabel *savedPagesLabel = ((MainMenuRowView *)self.rowViews[ROW_INDEX_SAVED_PAGES]).textLabel;
    UILabel *articleTitleLabel = ((MainMenuRowView *)self.rowViews[ROW_INDEX_SAVE_PAGE]).textLabel;
    
    CGAffineTransform scale = CGAffineTransformMakeScale(0.4, 0.4);
    CGPoint destPoint = [self getLocationForView2:savedPagesLabel xf:scale];
    
    NSString *title = NSLocalizedString(@"main-menu-current-article-save", nil);
    NSAttributedString *attributedTitle =
    [title attributedStringWithAttributes: @{NSForegroundColorAttributeName: [UIColor clearColor]}
                      substitutionStrings: @[[SessionSingleton sharedInstance].currentArticleTitle]
                   substitutionAttributes: @[
                                             @{
                                                 NSFontAttributeName: [UIFont italicSystemFontOfSize:16],
                                                 NSForegroundColorAttributeName: [UIColor blackColor]
                                                 }]
     ];
    
    for (NSInteger i = 0; i < 4; i++) {

        UILabel *label = [self getLabelCopyToAnimate2:articleTitleLabel];
        label.attributedText = attributedTitle;

        [self animateView: label
            toDestination: destPoint
               afterDelay: (i * 0.06)
                 duration: 0.45f
                transform: scale];
    }

    [savedPagesLabel animateAndRewindXF: CATransform3DMakeScale(1.08f, 1.08f, 1.0f)
                             afterDelay: 0.33
                               duration: 0.17];
}

-(UILabel *)getLabelCopyToAnimate2:(UILabel *)labelToCopy
{
    UILabel *labelCopy = [[UILabel alloc] init];
    CGRect sourceRect = [labelToCopy convertRect:labelToCopy.bounds toView:self.navigationController.view];
    labelCopy.frame = sourceRect;
    labelCopy.text = labelToCopy.text;
    labelCopy.font = labelToCopy.font;
    labelCopy.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    labelCopy.backgroundColor = [UIColor clearColor];
    labelCopy.textAlignment = labelToCopy.textAlignment;
    labelCopy.lineBreakMode = labelToCopy.lineBreakMode;
    labelCopy.numberOfLines = labelToCopy.numberOfLines;
    [self.navigationController.view addSubview:labelCopy];
    return labelCopy;
}


-(CGPoint)getLocationForView2:(UIView *)view xf:(CGAffineTransform)xf
{
    CGPoint point = [view convertPoint:view.center toView:self.navigationController.view];
    CGPoint scaledPoint = [view convertPoint:CGPointApplyAffineTransform(view.center, xf) toView:self.tableView];
    scaledPoint.y = point.y;
    return scaledPoint;
}
















































-(void)viewWillDisappear:(BOOL)animated
{

[[NSNotificationCenter defaultCenter] removeObserver: self
                                            name: @"TopActionSheetItemTapped"
                                          object: nil];


    [super viewWillDisappear:animated];
    [[QueuesSingleton sharedInstance].randomArticleQ cancelAllOperations];
}

#pragma mark - Login / logout button

-(void)updateLoginButtons
{
    // Show login/logout buttons
    [[self sectionDict:SECTION_INDEX_LOGIN_OPTIONS][@"rows"] removeAllObjects];
    if([SessionSingleton sharedInstance].keychainCredentials.userName){
        [self addToTableDataRowWithTitle: NSLocalizedString(@"main-menu-account-logout", nil)
                               imageName: @"main_menu_face_smile_white.png"
                                     key: @"logout"
                                 section: SECTION_INDEX_LOGIN_OPTIONS];
    }else{
        [self addToTableDataRowWithTitle: NSLocalizedString(@"main-menu-account-login", nil)
                               imageName: @"main_menu_face_sleep_white.png"
                                     key: @"login"
                                 section: SECTION_INDEX_LOGIN_OPTIONS];
    }
}

-(void)updateLoginTitle
{
    NSString *userName = [SessionSingleton sharedInstance].keychainCredentials.userName;
    if(userName){
    
        NSString *loggedInAsTitle = NSLocalizedString(@"main-menu-account-title-logged-in", nil);
        loggedInAsTitle = [loggedInAsTitle stringByReplacingOccurrencesOfString:@"$1" withString:userName];
    
        [self sectionDict:SECTION_INDEX_LOGIN_OPTIONS][@"title"] = loggedInAsTitle;
    }else{
        [self sectionDict:SECTION_INDEX_LOGIN_OPTIONS][@"title"] = NSLocalizedString(@"main-menu-account-title-logged-out", nil);
    }
}

#pragma mark - Table section and row accessors

-(NSMutableDictionary *)sectionDict:(NSInteger)section
{
    return self.tableData[section];
}

-(NSMutableDictionary *)rowDict:(NSIndexPath *)indexPath
{
    return [self sectionDict:indexPath.section][@"rows"][indexPath.row];
}

#pragma mark - Table data

-(void)addToTableDataRowWithTitle: (NSString *)title
                         imageName: (NSString *)imageName
                               key: (NSString *)key
                           section: (NSInteger)section
{
    [[self sectionDict:section][@"rows"] addObject:
     [@{
        @"key": key,
        @"title": title,
        @"imageName": (imageName ? imageName : @""),
        @"label": @"",
        } mutableCopy]
     ];
}

-(void)loadTableData
{
    NSString *currentArticleTitle = [SessionSingleton sharedInstance].currentArticleTitle;

    NSDictionary *highlightedText = @{
        NSFontAttributeName: [UIFont italicSystemFontOfSize:16]
    };

    NSAttributedString *searchWikiTitle =
    [NSLocalizedString(@"main-menu-language-title", nil) attributedStringWithAttributes: nil
                                                                    substitutionStrings: @[[SessionSingleton sharedInstance].domainName]
                                                                 substitutionAttributes: @[highlightedText]
     ];

    NSAttributedString *saveArticleTitle =
    [NSLocalizedString(@"main-menu-current-article-save", nil) attributedStringWithAttributes: nil
                                                                    substitutionStrings: @[currentArticleTitle]
                                                                 substitutionAttributes: @[highlightedText]
     ];

    self.tableData =
    @[
      @{
          @"key": @"menuOptions",
          @"title": NSLocalizedString(@"main-menu-account-title-logged-out", nil),
          @"label": @"",
          @"subTitle": @"",
          @"rows": @[].mutableCopy
          }.mutableCopy
      ,
      @{
          @"key": @"menuOptions",
          @"title": NSLocalizedString(@"main-menu-show-title", nil),
          @"label": @"",
          @"subTitle": @"",
          @"rows": @[
                  @{
                      @"key": @"randomTappable",
                      @"title": NSLocalizedString(@"main-menu-random", nil),
                      @"imageName": @"main_menu_dice_white.png",
                      @"label": @""
                      }.mutableCopy
                  ,
                  @{
                      @"key": @"history",
                      @"title": NSLocalizedString(@"main-menu-show-history", nil),
                      @"imageName": @"main_menu_clock_white.png",
                      @"label": @""
                      }.mutableCopy
                  ,
                  @{
                      @"key": @"savedPages",
                      @"title": NSLocalizedString(@"main-menu-show-saved", nil),
                      @"imageName": @"main_menu_bookmark_white.png",
                      @"label": @""
                      }.mutableCopy
                  ]
          }.mutableCopy
      ,
      @{
          @"key": @"articleOptions",
          @"title": [NSString stringWithFormat:@"\"%@\"", currentArticleTitle],
          @"label": @"",
          @"subTitle": @"",
          @"rows": @[
                  @{
                      @"key": @"savePage",
                      @"title": saveArticleTitle,
                      @"imageName": @"main_menu_save.png",
                      @"label": @""
                      }.mutableCopy
                  ].mutableCopy
          }.mutableCopy
      ,
      @{
          @"key": @"searchLanguageOptions",
          @"title": NSLocalizedString(@"main-menu-language-title", nil),
          @"label": @"",
          @"subTitle": @"",
          @"rows": @[
                  @{
                      @"key": [SessionSingleton sharedInstance].domain,
                      @"title": searchWikiTitle,
                      @"imageName": @"main_menu_foreign_characters_gray.png",
                      @"label": @""
                      }.mutableCopy
                  ].mutableCopy
          }.mutableCopy
      ,
      @{
          @"key": @"wikipediaZero",
          @"title": NSLocalizedString(@"zero-wikipedia-zero-heading", nil),
          @"label": @"",
          @"subTitle": @"",
          @"rows": @[
                  @{
                      @"key": @"zeroWarnWhenLeaving",
                      @"title": NSLocalizedString(@"zero-warn-when-leaving", nil),
                      @"imageName": @"main_menu_flag_white.png",
                      @"label": @""
                      }.mutableCopy
                  ].mutableCopy
          }.mutableCopy
      ,
      @{
          @"key": @"sendFeedbackHeading",
          @"title": NSLocalizedString(@"main-menu-feedback-heading", nil),
          @"label": @"",
          @"subTitle": @"",
          @"rows": @[
                  @{
                      @"key": @"sendFeedback",
                      @"title": NSLocalizedString(@"main-menu-send-feedback", nil),
                      @"imageName": @"main_menu_envelope_white.png",
                      @"label": @""
                      }.mutableCopy
                  ].mutableCopy
          }.mutableCopy
      ].mutableCopy;
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionRows = [self sectionDict:section][@"rows"];
    return sectionRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainMenuResultsCell *cell = [tableView dequeueReusableCellWithIdentifier: @"MainMenuResultsCell"
                                                            forIndexPath: indexPath];

    NSMutableDictionary *row = [self rowDict:indexPath];
    
    row[@"label"] = cell.textLabel;
    
    UIColor *thumbnailColor = THUMBNAIL_IMAGE_COLOR;

    if ([row[@"key"] isEqualToString:@"zeroWarnWhenLeaving"]) {
        if (![SessionSingleton sharedInstance].zeroConfigState.warnWhenLeaving) {
            thumbnailColor = THUMBNAIL_IMAGE_COLOR_UNSELECTED;
        }
    }
    
    NSString *imageName = [row objectForKey:@"imageName"];
    if (imageName && imageName.length > 0) {
        __block UIImage *i = nil;
        dispatch_sync(self.thumbColorDispatchQ, ^(void){
            // Background thread, but synchronously: http://stackoverflow.com/a/12739384
            // Note: Could refactor this later to take care of this in viewDidLoad for all
            // images used by this page.
            i = [[UIImage imageNamed:imageName] getImageOfColor:thumbnailColor.CGColor];
        });
        cell.thumbnailImageView.image = i;
    }
 
    cell.backgroundColor = BACKGROUND_COLOR;

    id title = row[@"title"];
    
    if([title isKindOfClass:[NSString class]]){
        cell.textLabel.text = title;
    }else if([title isKindOfClass:[NSAttributedString class]]){
        cell.textLabel.attributedText = title;
    }

    return cell;
}

#pragma mark - Table view delegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ((section == SECTION_INDEX_ARTICLE_OPTIONS) && self.hidePagesSection) {
        return nil;
    }

    NSMutableDictionary *sectionDict = [self sectionDict:section];

    // Don't show header if no items in this section.
    NSArray *sectionRows = sectionDict[@"rows"];
    if (sectionRows.count == 0) {
        return nil;
    }
    
    return [self getHeaderViewForSection:section];
}

-(UIView *)getHeaderViewForSection:(NSInteger)section
{
    NSMutableDictionary *sectionDict = [self sectionDict:section];

    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BACKGROUND_COLOR;
    
    MainMenuSectionHeadingLabel *label = [[MainMenuSectionHeadingLabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    label.useDottedLine = NO; // (section == SECTION_MENU_OPTIONS) ? NO : YES ;
    
    id title = sectionDict[@"title"];
    
    if([title isKindOfClass:[NSString class]]){
        label.text = title;
    }else if([title isKindOfClass:[NSAttributedString class]]){
        label.attributedText = title;
    }

    sectionDict[@"label"] = label;
    
    [view addSubview:label];

    NSDictionary *views = @{@"label":label};
    
    NSArray *constraints =
        @[
          [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-10-[label]-10-|"
                                                  options: 0
                                                  metrics: nil
                                                    views: views]
          ,
          [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-0-[label]-0-|"
                                                  options: 0
                                                  metrics: nil
                                                    views: views]
          ];
    
    [view addConstraints:[constraints valueForKeyPath:@"@unionOfArrays.self"]];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if (section == SECTION_INDEX_ARTICLE_OPTIONS && self.hidePagesSection) {
        return 0.0;
    }
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat animationDuration = 0.1f;

    NSMutableDictionary *row = [self rowDict:indexPath];
    NSString *imageName = [row objectForKey:@"imageName"];

    if ([row[@"key"] isEqualToString:@"zeroWarnWhenLeaving"]) {
        animationDuration = 0.0f;
    }

    if (imageName && (imageName.length > 0) && (animationDuration > 0)) {
        MainMenuResultsCell *cell = (MainMenuResultsCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.thumbnailImageView animateAndRewindXF: CATransform3DMakeScale(1.35f, 1.35f, 1.0f)
                      afterDelay: 0.0
                        duration: animationDuration];
    }else{
        animationDuration = 0.0f;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (animationDuration * 2.0f) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[QueuesSingleton sharedInstance].randomArticleQ cancelAllOperations];
        NSDictionary *sectionDict = [self sectionDict:indexPath.section];
        
        NSString *selectedSectionKey = sectionDict[@"key"];
        
        NSMutableDictionary *rowDict = [self rowDict:indexPath];
        NSString *selectedRowKey = rowDict[@"key"];
        //NSLog(@"menu item selection key = %@", selectedKey);
        
        if ([selectedRowKey isEqualToString:@"login"]) {
            
            LoginViewController *loginVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self.navigationController pushViewController:loginVC animated:YES];
            
        }else if ([selectedRowKey isEqualToString:@"logout"]) {
            
            [SessionSingleton sharedInstance].keychainCredentials.userName = nil;
            [SessionSingleton sharedInstance].keychainCredentials.password = nil;
            [SessionSingleton sharedInstance].keychainCredentials.editTokens = nil;
            
            // Clear session cookies too.
            for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies copy]) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
            
            [self updateLoginButtons];
            [self updateLoginTitle];
            [self.tableView reloadData];
            
        }else if ([selectedRowKey isEqualToString:@"history"]) {
            
            HistoryViewController *historyVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
            [self.navigationController pushViewController:historyVC animated:YES];
            
        }else if ([selectedRowKey isEqualToString:@"savedPages"]) {
            
            SavedPagesViewController *savedPagesVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"SavedPagesViewController"];
            [self.navigationController pushViewController:savedPagesVC animated:YES];
            
        }else if ([selectedRowKey isEqualToString:@"savePage"]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SavePage" object:self userInfo:nil];
            
            [self animateArticleTitleMovingToSavedPages];
            
        }else if ([selectedSectionKey isEqualToString:@"searchLanguageOptions"]) {
            
            [self showLanguages];
            
        }  else if ([selectedRowKey isEqualToString:@"zeroWarnWhenLeaving"]) {
            
            [[SessionSingleton sharedInstance].zeroConfigState toggleWarnWhenLeaving];
            
            [self.tableView reloadData];
            
        } else if ([selectedRowKey isEqualToString:@"randomTappable"]) {
            
            [self showAlert:NSLocalizedString(@"fetching-random-article", nil)];
            [self fetchRandomArticle];
            
        } else if ([selectedRowKey isEqualToString:@"sendFeedback"]) {
            
            NSString *mailtoUri =
            [NSString stringWithFormat:@"mailto:mobile-ios-wikipedia@wikimedia.org?subject=Feedback:%@", [WikipediaAppUtils appVersion]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailtoUri]];
            
        }
    });
}

#pragma mark - Sage page animation

-(void)animateArticleTitleMovingToSavedPages
{
    NSIndexPath *savedPagesIndexPath = [NSIndexPath indexPathForRow:ROW_SAVED_PAGES inSection:SECTION_INDEX_MENU_OPTIONS];
    NSDictionary *savedPagesRow = [self rowDict:savedPagesIndexPath];

    NSIndexPath *savedPageIndexPath = [NSIndexPath indexPathForRow:0 inSection:SECTION_INDEX_ARTICLE_OPTIONS];
    NSDictionary *saveThisPageRow = [self rowDict:savedPageIndexPath];

    UILabel *savedPagesLabel = savedPagesRow[@"label"];
    UILabel *articleTitleLabel = saveThisPageRow[@"label"];
    
    CGAffineTransform scale = CGAffineTransformMakeScale(0.4, 0.4);
    CGPoint destPoint = [self getLocationForView:savedPagesLabel xf:scale];
    
    NSString *title = NSLocalizedString(@"main-menu-current-article-save", nil);
    NSAttributedString *attributedTitle =
    [title attributedStringWithAttributes: @{NSForegroundColorAttributeName: [UIColor clearColor]}
                      substitutionStrings: @[[SessionSingleton sharedInstance].currentArticleTitle]
                   substitutionAttributes: @[
                                             @{
                                                 NSFontAttributeName: [UIFont italicSystemFontOfSize:16],
                                                 NSForegroundColorAttributeName: [UIColor blackColor]
                                                 }]
     ];
    
    for (NSInteger i = 0; i < 4; i++) {

        UILabel *label = [self getLabelCopyToAnimate:articleTitleLabel];
        label.attributedText = attributedTitle;

        [self animateView: label
            toDestination: destPoint
               afterDelay: (i * 0.06)
                 duration: 0.45f
                transform: scale];
    }

    [savedPagesLabel animateAndRewindXF: CATransform3DMakeScale(1.08f, 1.08f, 1.0f)
                             afterDelay: 0.33
                               duration: 0.17];
}

-(UILabel *)getLabelCopyToAnimate:(UILabel *)labelToCopy
{
    UILabel *labelCopy = [[UILabel alloc] init];
    CGRect sourceRect = [labelToCopy convertRect:labelToCopy.bounds toView:self.tableView];
    labelCopy.frame = sourceRect;
    labelCopy.text = labelToCopy.text;
    labelCopy.font = labelToCopy.font;
    labelCopy.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    labelCopy.backgroundColor = [UIColor clearColor];
    labelCopy.textAlignment = labelToCopy.textAlignment;
    labelCopy.lineBreakMode = labelToCopy.lineBreakMode;
    labelCopy.numberOfLines = labelToCopy.numberOfLines;
    [self.tableView addSubview:labelCopy];
    return labelCopy;
}

-(CGPoint)getLocationForView:(UIView *)view xf:(CGAffineTransform)xf
{
    CGPoint point = [view convertPoint:view.center toView:self.tableView];
    CGPoint scaledPoint = [view convertPoint:CGPointApplyAffineTransform(view.center, xf) toView:self.tableView];
    scaledPoint.y = point.y;
    return scaledPoint;
}

-(void)animateView: (UIView *)view
     toDestination: (CGPoint)destPoint
        afterDelay: (CGFloat)delay
          duration: (CGFloat)duration
         transform: (CGAffineTransform)xf
{
    [UIView animateWithDuration: duration
                          delay: delay
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         view.center = destPoint;
                         view.alpha = 0.3f;
                         view.transform = xf;
                     }completion: ^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
}

#pragma mark - Search languages

-(void)showLanguages
{
    LanguagesTableVC *languagesTableVC =
    [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"LanguagesTableVC"];
    
    languagesTableVC.downloadLanguagesForCurrentArticle = NO;
    
    CATransition *transition = [languagesTableVC getTransition];
    
    languagesTableVC.selectionBlock = ^(NSDictionary *selectedLangInfo){

        [self showAlert:NSLocalizedString(@"main-menu-language-selection-saved", nil)];
        [self showAlert:@""];

        [self switchPreferredLanguageToId:selectedLangInfo[@"code"] name:selectedLangInfo[@"name"]];
        
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        // Don't animate - so the transistion set above will be used.
        [self.navigationController popViewControllerAnimated:NO];

    };
    
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    // Don't animate - so the transistion set above will be used.
    [self.navigationController pushViewController:languagesTableVC animated:NO];
}

-(void)switchPreferredLanguageToId:(NSString *)languageId name:(NSString *)name
{
    [SessionSingleton sharedInstance].domain = languageId;
    [SessionSingleton sharedInstance].domainName = name;
}

#pragma mark - Random

-(void)fetchRandomArticle {

    [[QueuesSingleton sharedInstance].randomArticleQ cancelAllOperations];

    DownloadTitlesForRandomArticlesOp *downloadTitlesForRandomArticlesOp =
        [[DownloadTitlesForRandomArticlesOp alloc] initForDomain: [SessionSingleton sharedInstance].domain
                                                 completionBlock: ^(NSString *title) {
                                                     if (title) {
                                                         dispatch_async(dispatch_get_main_queue(), ^(){
                                                             [NAV loadArticleWithTitle: title
                                                                                domain: [SessionSingleton sharedInstance].domain
                                                                              animated: YES];
                                                         });
                                                     }
                                                 } cancelledBlock: ^(NSError *errorCancel) {
                                                    [self showAlert:@""];
                                                 } errorBlock: ^(NSError *error) {
                                                    [self showAlert:error.localizedDescription];
                                                 }];

    [[QueuesSingleton sharedInstance].randomArticleQ addOperation:downloadTitlesForRandomArticlesOp];
}

#pragma mark - Scroll

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyboard];
}

@end
