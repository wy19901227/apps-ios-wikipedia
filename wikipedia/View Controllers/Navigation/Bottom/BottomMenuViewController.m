//  Created by Monte Hurd on 5/15/14.
//  Copyright (c) 2014 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "BottomMenuViewController.h"
#import "WebViewController.h"
#import "UINavigationController+SearchNavStack.h"
#import "SessionSingleton.h"
#import "WikiGlyph_Chars_iOS.h"
#import "WikiGlyph_Chars.h"
#import "WikiGlyphButton.h"
#import "WikiGlyphLabel.h"
#import "UIViewController+Alert.h"
#import "UIView+TemporaryAnimatedXF.h"
#import "NSString+Extras.h"
#import "ShareMenuSavePageActivity.h"
#import "Defines.h"
#import "WikipediaAppUtils.h"
#import "WMF_Colors.h"
#import "UIViewController+ModalPresent.h"
#import "UIViewController+ModalsSearch.h"
#import "UIViewController+ModalPop.h"
#import "NSObject+ConstraintsScale.h"
#import "LeadImageTitleLabel.h"
#import "MWLanguageInfo.h"

typedef NS_ENUM(NSInteger, BottomMenuItemTag) {
    BOTTOM_MENU_BUTTON_UNKNOWN,
    BOTTOM_MENU_BUTTON_PREVIOUS,
    BOTTOM_MENU_BUTTON_NEXT,
    BOTTOM_MENU_BUTTON_SHARE,
    BOTTOM_MENU_BUTTON_SAVE
};

@interface BottomMenuViewController ()

@property (weak, nonatomic) IBOutlet WikiGlyphButton *backButton;
@property (weak, nonatomic) IBOutlet WikiGlyphButton *forwardButton;
@property (weak, nonatomic) IBOutlet WikiGlyphButton *saveButton;
@property (weak, nonatomic) IBOutlet WikiGlyphButton *rightButton;

@property (strong, nonatomic) NSDictionary *adjacentHistoryEntries;

@property (strong, nonatomic) NSArray *allButtons;

@property (strong, nonatomic) UIPopoverController *popover;

@end

@implementation BottomMenuViewController{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIColor *buttonColor = [UIColor blackColor];

    BOOL isRTL = [WikipediaAppUtils isDeviceLanguageRTL];

    [self.backButton.label setWikiText: isRTL ? IOS_WIKIGLYPH_FORWARD : IOS_WIKIGLYPH_BACKWARD
                                 color: buttonColor
                                  size: MENU_BOTTOM_GLYPH_FONT_SIZE
                        baselineOffset: 0];
    self.backButton.accessibilityLabel = MWLocalizedString(@"menu-back-accessibility-label", nil);
    self.backButton.tag = BOTTOM_MENU_BUTTON_PREVIOUS;
    
    [self.forwardButton.label setWikiText: isRTL ? IOS_WIKIGLYPH_BACKWARD : IOS_WIKIGLYPH_FORWARD
                                    color: buttonColor
                                     size: MENU_BOTTOM_GLYPH_FONT_SIZE
                           baselineOffset: 0
     ];
    self.forwardButton.accessibilityLabel = MWLocalizedString(@"menu-forward-accessibility-label", nil);
    self.forwardButton.tag = BOTTOM_MENU_BUTTON_NEXT;
    // self.forwardButton.label.transform = CGAffineTransformMakeScale(-1, 1);

    [self.rightButton.label setWikiText: IOS_WIKIGLYPH_SHARE
                                  color: buttonColor
                                   size: MENU_BOTTOM_GLYPH_FONT_SIZE
                         baselineOffset: 0
     ];
    self.rightButton.tag = BOTTOM_MENU_BUTTON_SHARE;
    self.rightButton.accessibilityLabel = MWLocalizedString(@"menu-share-accessibility-label", nil);

    [self.saveButton.label setWikiText: IOS_WIKIGLYPH_HEART_OUTLINE
                                 color: buttonColor
                                  size: MENU_BOTTOM_GLYPH_FONT_SIZE
                        baselineOffset: 0
     ];
    self.saveButton.tag = BOTTOM_MENU_BUTTON_SAVE;
    self.saveButton.accessibilityLabel = MWLocalizedString(@"share-menu-save-page", nil);

    self.allButtons = @[self.backButton, self.forwardButton, self.rightButton, self.saveButton];

    self.view.backgroundColor = CHROME_COLOR;

    [self addTapRecognizersToAllButtons];
    
    UILongPressGestureRecognizer *saveLongPressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                  action: @selector(saveButtonLongPressed:)];
    saveLongPressRecognizer.minimumPressDuration = 0.5f;
    [self.saveButton addGestureRecognizer:saveLongPressRecognizer];

    UILongPressGestureRecognizer *backLongPressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                  action: @selector(backForwardButtonsLongPressed:)];
    backLongPressRecognizer.minimumPressDuration = 0.5f;
    [self.backButton addGestureRecognizer:backLongPressRecognizer];


    UILongPressGestureRecognizer *forwardLongPressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                  action: @selector(backForwardButtonsLongPressed:)];
    forwardLongPressRecognizer.minimumPressDuration = 0.5f;
    [self.forwardButton addGestureRecognizer:forwardLongPressRecognizer];

    [self adjustConstraintsScaleForViews:@[self.backButton, self.forwardButton, self.saveButton, self.rightButton]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shareButtonPushed:)
                                                 name:@"SelectionShare"
                                               object:nil];
}

-(void)addTapRecognizersToAllButtons
{
    for (WikiGlyphButton *view in self.allButtons) {
        [view addGestureRecognizer:
         [[UITapGestureRecognizer alloc] initWithTarget: self
                                                 action: @selector(buttonPushed:)]];
    }
}

#pragma mark Bottom bar button methods

- (void)buttonPushed:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        // If the tapped item was a button, first animate it briefly, then perform action.
        if([recognizer.view isKindOfClass:[WikiGlyphButton class]]){
            WikiGlyphButton *button = (WikiGlyphButton *)recognizer.view;
            if (!button.enabled)return;
            CGFloat animationScale = 1.25f;
            [button.label animateAndRewindXF: CATransform3DMakeScale(animationScale, animationScale, 1.0f)
                                  afterDelay: 0.0
                                    duration: 0.06f
                                        then: ^{
                                            [self performActionForButton:button];
                                        }];
        }
    }
}

- (void)performActionForButton:(WikiGlyphButton *)button
{
    switch (button.tag) {
        case BOTTOM_MENU_BUTTON_PREVIOUS:
            [self backButtonPushed];
            break;
        case BOTTOM_MENU_BUTTON_NEXT:
            [self forwardButtonPushed];
            break;
        case BOTTOM_MENU_BUTTON_SHARE:
            // [self shareButtonPushed];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectionShare" object:self userInfo:nil];
            break;
        case BOTTOM_MENU_BUTTON_SAVE:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SavePage" object:self userInfo:nil];
            [self updateBottomBarButtonsEnabledState];
            break;
        default:
            break;
    }
}

-(void)saveButtonLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan){
        [self performModalSequeWithID: @"modal_segue_show_saved_pages"
                      transitionStyle: UIModalTransitionStyleCoverVertical
                                block: nil];
    }
}

-(void)backForwardButtonsLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan){
        [self performModalSequeWithID: @"modal_segue_show_history"
                      transitionStyle: UIModalTransitionStyleCoverVertical
                                block: nil];
    }
}

- (void)shareButtonPushed:(NSNotification *)notification
{
    NSString *title = @"";
    NSURL *desktopURL = nil;
    UIImage *image = nil;
    
    MWKArticle *article = [SessionSingleton sharedInstance].article;
    if (article) {
        desktopURL = article.title.desktopURL;
        if (!desktopURL) {
            NSLog(@"Could not retrieve desktop URL for article.");
            return;
        }
        
        title = [[NSString alloc] initWithFormat:@"\"%@\" on @Wikipedia", article.title.prefixedText];
        BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
        WebViewController *webVC = nil;
        UIView *lead = nil;
        CGContextRef ctx;
        
        // TODO: deal with Main Page
        
        NSScanner *scanner = [NSScanner scannerWithString:@"111111"];
        unsigned hex;
        [scanner scanHexInt:&hex];
        UIColor *bg = UIColorFromRGBWithAlpha(hex, 1.0);
        scanner = [NSScanner scannerWithString:@"ededed"];
        [scanner scanHexInt:&hex];
        UIColor *fg = UIColorFromRGBWithAlpha(hex, 1.0);
        scanner = [NSScanner scannerWithString:@"cccccc"];
        [scanner scanHexInt:&hex];
        UIColor *quoteColor = UIColorFromRGBWithAlpha(hex, 1.0);
        
        webVC = [NAV searchNavStackForViewControllerOfClass:[WebViewController class]];
        
        MWLanguageInfo *languageInfo = [MWLanguageInfo languageInfoForCode:article.title.site.language];
        NSTextAlignment textAlignment = [languageInfo.dir isEqualToString:@"rtl"] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        
        // TODO: deal with case of no lead image even when in portrait mode
        if (!notification.userInfo) {
            MWKImage *bestImage = article.image;
            if (!bestImage) {
                bestImage = article.thumbnail;
            }
            if (bestImage) {
                image = [bestImage asUIImage];
            }
        } else if (isPortrait &&
                   [(LeadImageContainer*)webVC.leadImageContainer imageExists]) {

            lead = webVC.leadImageContainer;
            UIGraphicsBeginImageContext(CGSizeMake(lead.frame.size.width, lead.frame.size.height));
            ctx = UIGraphicsGetCurrentContext();
            [lead.layer renderInContext:ctx];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        } else {
            // deal with landscape
            // make a padded label and assign it to *lead
            // lead needs to become a standard webview
            // LeadImageTitleLabel *lit
            LeadImageTitleLabel *lit = [[LeadImageTitleLabel alloc] init];
            [lit setTitle:article.displaytitle description:article.description];
            lit.padding = UIEdgeInsetsMake(16.0, 16.0, 16.0, 16.0);
            lit.textColor = fg;
            lit.textAlignment = textAlignment;

            //lit.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.08];
            lead = lit;
            lead.bounds = CGRectMake(0,
                                     0,
                                     [UIScreen mainScreen].bounds.size.width,
                                     0);
            lead.frame = CGRectMake(0, 0, lead.bounds.size.width, lead.intrinsicContentSize.height);
            lead.backgroundColor = bg;
            UIGraphicsBeginImageContext(CGSizeMake(lead.frame.size.width, lead.frame.size.height));
            ctx = UIGraphicsGetCurrentContext();
            [lead.layer renderInContext:ctx];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
        }

        if (notification.userInfo) {
            CGFloat heightWidthRatio = lead.frame.size.height / lead.frame.size.width;
            CGFloat scaledDownWidth = MIN(320.0, lead.frame.size.width);
            CGFloat adjustedHeight = heightWidthRatio * scaledDownWidth;
            
            UIImageView *leadImageView = [[UIImageView alloc] initWithImage:image];
            leadImageView.frame = CGRectMake(0, 0, scaledDownWidth, adjustedHeight);
            
            
            PaddedLabel *snippet = [[PaddedLabel alloc] init];
            snippet.lineBreakMode = NSLineBreakByTruncatingTail;
            snippet.numberOfLines = 10;
            
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 18.0 * 0.6;
            // paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            NSDictionary *attributes =
            @{
              NSFontAttributeName : [UIFont systemFontOfSize:18.0],
              NSParagraphStyleAttributeName : paragraphStyle,
              NSForegroundColorAttributeName : fg,
              };
            
            
            // snippet.attributedText = [[NSAttributedString alloc] initWithString:@"She skipped high school altogether, enrolling in an alternative junior high in the public school system that took her through tenth grade, when she passed the GED." attributes:attributes];
            // snippet.attributedText = [[NSAttributedString alloc] initWithString:@"Skipped school." attributes:attributes];
            
            
            snippet.attributedText = [[NSAttributedString alloc]
                                      initWithString: notification.userInfo[@"selectedText"] attributes:attributes];
            snippet.textAlignment = textAlignment;
            
            snippet.backgroundColor = bg;
            snippet.padding = UIEdgeInsetsMake(42.0, 18.0, 18.0, 36.0);
            //        snippet.textColor = [UIColor whiteColor];
            //        snippet.font = [UIFont systemFontOfSize:(32.0 / snippet.contentScaleFactor)];
            
            //        snippet.bounds = CGRectMake(0, 0, lead.frame.size.width, 0);
            //        snippet.frame = CGRectMake(0, lead.frame.size.height, lead.frame.size.width, snippet.intrinsicContentSize.height);
            snippet.bounds = CGRectMake(0, 0, leadImageView.bounds.size.width, 0);
            snippet.frame = CGRectMake(0, 0, leadImageView.bounds.size.width, snippet.intrinsicContentSize.height);
            
            PaddedLabel *quotationMark = [[PaddedLabel alloc] init];
            NSDictionary *quotationMarkAttributes =
            @{
              NSFontAttributeName : [UIFont fontWithName:@"Times New Roman" size:60.0],
              NSForegroundColorAttributeName : quoteColor,
              };
            quotationMark.attributedText = [[NSAttributedString alloc] initWithString:@"“" attributes:quotationMarkAttributes];
            quotationMark.bounds = CGRectZero;
            quotationMark.frame = CGRectMake(0, 0, quotationMark.intrinsicContentSize.width, quotationMark.intrinsicContentSize.height);
            quotationMark.padding = UIEdgeInsetsMake(0,
                                                     textAlignment == NSTextAlignmentLeft ? 18.0 : 0,
                                                     0,
                                                     textAlignment == NSTextAlignmentRight ? 18.0 : 0);
            
            UIImage *logoImage = [UIImage imageNamed:@"Wikipedia_wordmark_gray.png"];
            UIImageView *logo = [[UIImageView alloc] initWithImage:logoImage];
            heightWidthRatio = logoImage.size.height / logoImage.size.width;
            scaledDownWidth = (logoImage.size.width / 4.5);
            adjustedHeight = heightWidthRatio * scaledDownWidth;
            logo.bounds = CGRectMake(0, 0, scaledDownWidth, adjustedHeight);
            UIView *logoContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, snippet.frame.size.width, logo.bounds.size.height + 36)];
            logoContainer.backgroundColor = snippet.backgroundColor;
            [logoContainer addSubview:logo];
            logo.frame = CGRectMake(18.0, 12.0, logo.bounds.size.width, logo.bounds.size.height);
            UIGraphicsBeginImageContext(CGSizeMake(leadImageView.bounds.size.width, leadImageView.bounds.size.height + snippet.bounds.size.height + logoContainer.frame.size.height));
            ctx = UIGraphicsGetCurrentContext();
            [leadImageView.layer renderInContext:ctx];
            // TODO: There's a strange gray border below the "lead image" when
            // it's just the title, so -2 instead of -1
            CGContextTranslateCTM(ctx, 0, leadImageView.bounds.size.height - 2.0);
            [snippet.layer renderInContext:ctx];
            CGFloat rightOffset = textAlignment == NSTextAlignmentRight ? leadImageView.bounds.size.width - quotationMark.bounds.size.width : 0.0;
            CGContextTranslateCTM(ctx, rightOffset, 0.0);
            [quotationMark.layer renderInContext:ctx];
            CGContextTranslateCTM(ctx, rightOffset == 0 ? rightOffset : -(rightOffset), 0.0);
            CGContextTranslateCTM(ctx, 0, snippet.frame.size.height - 1.0);
            [logoContainer.layer renderInContext:ctx];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    
    //ShareMenuSavePageActivity *shareMenuSavePageActivity = [[ShareMenuSavePageActivity alloc] init];
    
    NSMutableArray *activityItemsArray = @[title, desktopURL].mutableCopy;
    if (image) {
        [activityItemsArray addObject:image];
    }
    
    UIActivityViewController *shareActivityVC =
    [[UIActivityViewController alloc] initWithActivityItems: activityItemsArray
                                      applicationActivities: @[/*shareMenuSavePageActivity*/]];
    NSMutableArray *exclusions = @[
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll
                                   ].mutableCopy;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [exclusions addObject:UIActivityTypeAirDrop];
        [exclusions addObject:UIActivityTypeAddToReadingList];
    }
    
    shareActivityVC.excludedActivityTypes = exclusions;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:shareActivityVC animated:YES completion:nil];
    } else {
        // iPad crashes if you present share dialog modally. Whee!
        self.popover = [[UIPopoverController alloc] initWithContentViewController:shareActivityVC];
        [self.popover presentPopoverFromRect:self.saveButton.frame
                                      inView:self.view
                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                    animated:YES];
    }
    
    
    // TODO: Extract out the essential stuff. Really,
    // at this point we only care about the activityType and completed status
    if ([shareActivityVC respondsToSelector:@selector(setCompletionWithItemsHandler:)]) {
        [shareActivityVC setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            NSLog(@"activityType = %@", activityType);
        }];
    } else if ([shareActivityVC respondsToSelector:@selector(setCompletionHandler:)]) {
        [shareActivityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
            NSLog(@"activityType = %@", activityType);
        }];
    }
    
    
}

- (void)backButtonPushed
{
    MWKHistoryEntry *historyEntry = self.adjacentHistoryEntries[@"before"];
    if (historyEntry){
        WebViewController *webVC = [NAV searchNavStackForViewControllerOfClass:[WebViewController class]];

        [webVC showAlert:historyEntry.title.prefixedText type:ALERT_TYPE_BOTTOM duration:0.8];

        [webVC navigateToPage: historyEntry.title
              discoveryMethod: MWK_DISCOVERY_METHOD_BACKFORWARD
            invalidatingCache: NO
         showLoadingIndicator: YES];
    }
}

- (void)forwardButtonPushed
{
    MWKHistoryEntry *historyEntry = self.adjacentHistoryEntries[@"after"];
    if (historyEntry){
        WebViewController *webVC = [NAV searchNavStackForViewControllerOfClass:[WebViewController class]];

        [webVC showAlert:historyEntry.title.prefixedText type:ALERT_TYPE_BOTTOM duration:0.8];

        [webVC navigateToPage: historyEntry.title
             discoveryMethod: MWK_DISCOVERY_METHOD_BACKFORWARD
            invalidatingCache: NO
         showLoadingIndicator: YES];
    }
}

-(NSDictionary *)getAdjacentHistoryEntries
{
    SessionSingleton *session = [SessionSingleton sharedInstance];
    MWKHistoryList *historyList = session.userDataStore.historyList;

    MWKHistoryEntry *currentHistoryEntry = [historyList entryForTitle:session.title];
    MWKHistoryEntry *beforeHistoryEntry = [historyList entryBeforeEntry:currentHistoryEntry];
    MWKHistoryEntry *afterHistoryEntry = [historyList entryAfterEntry:currentHistoryEntry];

    NSMutableDictionary *result = [@{} mutableCopy];
    if(beforeHistoryEntry) result[@"before"] = beforeHistoryEntry;
    if(currentHistoryEntry) result[@"current"] = currentHistoryEntry;
    if(afterHistoryEntry) result[@"after"] = afterHistoryEntry;

    return result;
}

-(void)updateBottomBarButtonsEnabledState
{
    self.adjacentHistoryEntries = [self getAdjacentHistoryEntries];
    self.forwardButton.enabled = (self.adjacentHistoryEntries[@"after"]) ? YES : NO;
    self.backButton.enabled = (self.adjacentHistoryEntries[@"before"]) ? YES : NO;

    NSString *saveIconString = IOS_WIKIGLYPH_HEART_OUTLINE;
    UIColor *saveIconColor = [UIColor blackColor];
    if([self isCurrentArticleSaved]){
        saveIconString = IOS_WIKIGLYPH_HEART;
        saveIconColor = UIColorFromRGBWithAlpha(0xf27072, 1.0);
    }
    
    [self.saveButton.label setWikiText: saveIconString
                                 color: saveIconColor
                                  size: MENU_BOTTOM_GLYPH_FONT_SIZE
                        baselineOffset: 0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)isCurrentArticleSaved
{
    SessionSingleton *session = [SessionSingleton sharedInstance];
    return [session.userDataStore.savedPageList isSaved:session.title];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
