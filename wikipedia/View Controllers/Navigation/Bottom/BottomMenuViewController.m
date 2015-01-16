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
#import "ShareCardViewController.h"
#import "ShareCardView.h"
#import "ShareOptionsView.h"
#import "AppDelegate.h"
#import "ShareOptionsView.h"

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
@property (strong, nonatomic) UIView *grayOverlay;
@property (strong, nonatomic) ShareOptionsView *shareOptions;
@property (strong, nonatomic) UIImage *shareImage;
@property (strong, nonatomic) NSString *shareText;

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
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(shareButtonPushed:)
                                                 name: ShareableWebViewWillShareNotification
                                               object: nil];

    [self adjustConstraintsScaleForViews:@[self.backButton, self.forwardButton, self.saveButton, self.rightButton]];
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
        {
            WebViewController *webVC = [NAV searchNavStackForViewControllerOfClass:[WebViewController class]];
            ShareableWebView *swv = webVC.webView;
            NSString *selectedText = [swv getSelectedtext];
            if ([selectedText isEqualToString:@""]) {
                MWKSectionList *sections = [SessionSingleton sharedInstance].article.sections;
                for (MWKSection *section in sections) {
                    NSString *sectionText = section.text;
                    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"<p>(.+)</p>" options:0 error:nil];
                    NSArray *matches = [re matchesInString:sectionText options:0 range:NSMakeRange(0, sectionText.length)];
                    if ([matches count]) {
                        sectionText = [sectionText substringWithRange:[matches[0] rangeAtIndex:1]];
                        selectedText = [[sectionText getStringWithoutHTML] stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
                        if (selectedText.length > 77) {
                            selectedText = [NSString stringWithFormat:@"%@%@",
                                            [selectedText substringToIndex:77],
                                            @"..."];
                        }
                        break;
                    }
                }
                if (!selectedText) {
                    if (sections[0]) {
                        selectedText = [[sections[0].text getStringWithoutHTML] stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
                    }
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:ShareableWebViewWillShareNotification
                                                                object:self
                                                              userInfo:@{
                                                                         @"beginShare" : @YES,
                                                                         @"selectedText" : selectedText
                                                                         }];
            
            break;
        }
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
        desktopURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@",
                                                    article.title.desktopURL.absoluteString,
                                                    @"?source=app"]];
        
        if (!desktopURL) {
            NSLog(@"Could not retrieve desktop URL for article.");
            return;
        }
        title = article.title.prefixedText;
        
        if ([notification.userInfo[@"beginShare"] boolValue]) {
            ShareCardViewController* cardViewController = [[ShareCardViewController alloc] initWithNibName:@"ShareCard" bundle:nil];
            UIView *cardView = cardViewController.view;
            self.shareText = notification.userInfo[@"selectedText"];
            [cardViewController fillCardWithMWKArticle:article snippet:notification.userInfo[@"selectedText"]];
            UIGraphicsBeginImageContext(CGSizeMake(cardView.frame.size.width, cardView.frame.size.height));
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            [cardView.layer renderInContext:ctx];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            UIViewController *rootVC = appDelegate.window.rootViewController;
            UIView *grayOverlay = [[UIView alloc] initWithFrame:rootVC.view.frame];
            grayOverlay.backgroundColor = [UIColor blackColor];
            grayOverlay.alpha = 0.42;
            [rootVC.view addSubview:grayOverlay];
            self.grayOverlay = grayOverlay;
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self action:@selector(respondToDimAreaTapGesture:)];
            [grayOverlay addGestureRecognizer:tapRecognizer];
            grayOverlay.translatesAutoresizingMaskIntoConstraints = NO;
            [rootVC.view addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:@"H:|[grayOverlay]|"
                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                         metrics:nil
                                         views:NSDictionaryOfVariableBindings(grayOverlay)]];
            [rootVC.view addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:@"V:|[grayOverlay]|"
                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                         metrics:nil
                                         views:NSDictionaryOfVariableBindings(grayOverlay)]];
            ShareOptionsView *sov = [[[NSBundle mainBundle] loadNibNamed:@"ShareOptions" owner:self options:nil] objectAtIndex:0];
            sov.cardImageViewContainer.userInteractionEnabled = YES;
            // http://stackoverflow.com/questions/10316902/rounded-corners-only-on-top-of-a-uiview
            CAShapeLayer *topRoundingMaskLayer = [CAShapeLayer layer];
            topRoundingMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect: sov.cardImageViewContainer.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){7.0, 7.0f}].CGPath;
            sov.cardImageViewContainer.layer.mask = topRoundingMaskLayer;
            
            sov.shareAsCardLabel.userInteractionEnabled = YES;
            CAShapeLayer *bottomRoundingMaskLayer = [CAShapeLayer layer];
            bottomRoundingMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect: sov.shareAsCardLabel.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){7.0, 7.0f}].CGPath;
            sov.shareAsCardLabel.layer.mask = bottomRoundingMaskLayer;
            
            sov.shareAsTextLabel.userInteractionEnabled = YES;
            sov.shareAsTextLabel.layer.cornerRadius = 7.0f;
            sov.shareAsTextLabel.layer.masksToBounds = YES;
            
            sov.cardImageView.image = image;
            [rootVC.view addSubview:sov];
            self.shareImage = image;
            self.shareOptions = sov;
            sov.translatesAutoresizingMaskIntoConstraints = NO;
            [rootVC.view addConstraint:[NSLayoutConstraint
                                        constraintWithItem:sov
                                        attribute:NSLayoutAttributeCenterX
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:rootVC.view
                                        attribute:NSLayoutAttributeCenterX
                                        multiplier:1.0f
                                        constant:0.0f]];
            
            [rootVC.view addConstraint:[NSLayoutConstraint
                                        constraintWithItem:sov
                                        attribute:NSLayoutAttributeTop
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:rootVC.view
                                        attribute:NSLayoutAttributeBottom
                                        multiplier:1.0f
                                        constant:0.0f]];
            
            [rootVC.view addConstraint:[NSLayoutConstraint
                                        constraintWithItem:sov
                                        attribute:NSLayoutAttributeWidth
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0f
                                        constant:sov.bounds.size.width]];
            
            [rootVC.view addConstraint:[NSLayoutConstraint
                                        constraintWithItem:sov
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0f
                                        constant:sov.bounds.size.height]];
            
            [rootVC.view layoutIfNeeded];
            
            [UIView animateWithDuration:0.42 animations:^{
                [rootVC.view addConstraint:[NSLayoutConstraint
                                            constraintWithItem:sov
                                            attribute:NSLayoutAttributeBottom
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:rootVC.view
                                            attribute:NSLayoutAttributeBottom
                                            multiplier:1.0f
                                            constant:0.0f]];
                [rootVC.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                UITapGestureRecognizer *tapForCardOnCardImageViewRecognizer = [[UITapGestureRecognizer alloc]
                                                                initWithTarget:self action:@selector(respondToTapForCardGesture:)];
                UITapGestureRecognizer *tapForCardOnButtonRecognizer = [[UITapGestureRecognizer alloc]
                                                                               initWithTarget:self action:@selector(respondToTapForCardGesture:)];
                UITapGestureRecognizer *tapForTextRecognizer = [[UITapGestureRecognizer alloc]
                                                                initWithTarget:self action:@selector(respondToTapForTextGesture:)];
                [self.shareOptions.cardImageViewContainer addGestureRecognizer:tapForCardOnCardImageViewRecognizer];
                [self.shareOptions.shareAsCardLabel addGestureRecognizer:tapForCardOnButtonRecognizer];

                [self.shareOptions.shareAsTextLabel addGestureRecognizer:tapForTextRecognizer];
            }];
            return;

        } else if ([notification.userInfo[@"useCard"] boolValue]) {
            title = [MWLocalizedString(@"share-article-name-on-wikipedia", nil)
                     stringByReplacingOccurrencesOfString:@"$1" withString:title];
        } else if ([notification.userInfo[@"useText"] boolValue]) {
            // Conventional share
            if ([self.shareText isEqualToString:@""]) {
                title = [MWLocalizedString(@"share-article-name-on-wikipedia", nil)
                          stringByReplacingOccurrencesOfString:@"$1" withString:title];
            } else {
                title = [[MWLocalizedString(@"share-article-name-on-wikipedia-with-selected-text", nil)
                          stringByReplacingOccurrencesOfString:@"$1" withString:title]
                         stringByReplacingOccurrencesOfString:@"$2" withString:self.shareText];
            }
            MWKImage *bestImage = article.image;
            if (!bestImage) {
                bestImage = article.thumbnail;
            }
            if (bestImage) {
                self.shareImage = [bestImage asUIImage];
            } else {
                // Well, there's no image and the user didn't want a card
                self.shareImage = nil;
            }
        }
    }

    
    //ShareMenuSavePageActivity *shareMenuSavePageActivity = [[ShareMenuSavePageActivity alloc] init];

    NSMutableArray *activityItemsArray = @[title, desktopURL].mutableCopy;
    if (self.shareImage) {
        [activityItemsArray addObject:self.shareImage];
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
    [self fadeOutCardChoice];
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
    
    [shareActivityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
        [self releaseShareItems];
        NSLog(@"activityType = %@", activityType);
    }];
}

- (void)respondToDimAreaTapGesture: (UITapGestureRecognizer*) recognizer
{
    [self fadeOutCardChoice];
    [self releaseShareItems];
}

- (void) fadeOutCardChoice
{

    [UIView animateWithDuration:0.42 animations:^{
        self.grayOverlay.backgroundColor = [UIColor clearColor];
        self.shareOptions.hidden = YES;
    } completion:^(BOOL finished) {
        [self.grayOverlay removeFromSuperview];
        [self.shareOptions removeFromSuperview];
        self.grayOverlay = nil;
        self.shareOptions = nil;
    }];
}

- (void) releaseShareItems
{
    self.shareImage = nil;
    self.shareText = nil;

}

- (void)respondToTapForCardGesture: (UITapGestureRecognizer*) recognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ShareableWebViewWillShareNotification
                                                        object:self
                                                      userInfo:@{
                                                                 @"useCard" : @YES
                                                                 }];
    
    // TODO cleanup
}

- (void)respondToTapForTextGesture: (UITapGestureRecognizer*) recognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ShareableWebViewWillShareNotification
                                                        object:self
                                                      userInfo:@{
                                                                 @"useText" : @YES
                                                                 }];
    
    // TODO cleanup
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
