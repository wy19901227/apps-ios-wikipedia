//
//  ShareOptionsViewController.m
//  Wikipedia
//
//  Created by Adam Baso on 2/6/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "ShareOptionsViewController.h"
#import "ShareCardViewController.h"
#import "ShareOptionsView.h"
#import "PaddedLabel.h"
#import "WikipediaAppUtils.h"

@interface ShareOptionsViewController ()

@property (strong, nonatomic) UIView *grayOverlay;
@property (strong, nonatomic) UIView *containingView;
@property (strong, nonatomic) ShareOptionsView *shareOptions;
@property (strong, nonatomic) UIImage *shareImage;
@property (strong, nonatomic) NSString *shareText;
@property (strong, nonatomic) NSURL *desktopURL;
@property (strong, nonatomic) NSString *shareTitle;
@property (strong, nonatomic) MWKArticle *article;
@property (strong, nonatomic) UIPopoverController *popover;
@property (nonatomic, assign) id delegate;

@end

@implementation ShareOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithMWKArticle: (MWKArticle*) article snippet: (NSString *) snippet backgroundView: (UIView*) backgroundView delegate: (id) delegate
{
    self = [super init];
    if (self) {
        self.desktopURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@",
                                                    article.title.desktopURL.absoluteString,
                                                    @"?source=app"]];
        if (!self.desktopURL) {
            NSLog(@"Could not retrieve desktop URL for article.");
            return nil;
        }
        
        _delegate = delegate;
        self.article = article;
        self.shareTitle = article.title.prefixedText;
        ShareCardViewController* cardViewController = [[ShareCardViewController alloc] initWithNibName:@"ShareCard" bundle:nil];
        self.shareText = snippet;
        
        // get handle, fill, and render
        UIView *cardView = cardViewController.view;
        [cardViewController fillCardWithMWKArticle:article snippet:snippet];
        self.shareImage = [self cardAsUIImageWithView:cardView];
        
        ShareOptionsView *sov = [[[NSBundle mainBundle] loadNibNamed:@"ShareOptions" owner:self options:nil] objectAtIndex:0];
        sov.cardImageViewContainer.userInteractionEnabled = YES;
        sov.shareAsCardLabel.userInteractionEnabled = YES;
        sov.shareAsTextLabel.userInteractionEnabled = YES;
        sov.shareAsCardLabel.text = MWLocalizedString(@"share-card", nil);
        sov.shareAsTextLabel.text = MWLocalizedString(@"share-snippet", nil);
        sov.cardImageView.image = self.shareImage;
        self.containingView = backgroundView;
        [self makeTappableGrayBackgroundWithContainingView:backgroundView];
        [backgroundView addSubview:sov];
        self.shareOptions = sov;
        [self toastShareOptionsView:sov toContainingView:backgroundView];
        [_delegate didShowSharePreviewForMWKArticle:article withText:self.shareText];
        
    }
    return self;
}

- (UIImage*) cardAsUIImageWithView: (UIView*) theView
{
    UIGraphicsBeginImageContext(CGSizeMake(theView.bounds.size.width, theView.bounds.size.height));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:ctx];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

-(void) makeTappableGrayBackgroundWithContainingView: (UIView*) containingView
{
    UIView *grayOverlay = [[UIView alloc] initWithFrame:containingView.frame];
    grayOverlay.backgroundColor = [UIColor blackColor];
    grayOverlay.alpha = 0.42;
    [containingView addSubview:grayOverlay];
    self.grayOverlay = grayOverlay;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(respondToDimAreaTapGesture:)];
    [grayOverlay addGestureRecognizer:tapRecognizer];
    grayOverlay.translatesAutoresizingMaskIntoConstraints = NO;
    [containingView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"H:|[grayOverlay]|"
                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                    metrics:nil
                                    views:NSDictionaryOfVariableBindings(grayOverlay)]];
    [containingView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"V:|[grayOverlay]|"
                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                    metrics:nil
                                    views:NSDictionaryOfVariableBindings(grayOverlay)]];
}

-(void) toastShareOptionsView: (UIView*) sov toContainingView: (UIView*) containingView
{
    
    [containingView addConstraint:[NSLayoutConstraint
                                   constraintWithItem:sov
                                   attribute:NSLayoutAttributeCenterX
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:containingView
                                   attribute:NSLayoutAttributeCenterX
                                   multiplier:1.0f
                                   constant:0.0f]];
    NSLayoutConstraint *verticalPositioning = [NSLayoutConstraint
                                               constraintWithItem:sov
                                               attribute:NSLayoutAttributeTop
                                               relatedBy:NSLayoutRelationEqual
                                               toItem:containingView
                                               attribute:NSLayoutAttributeBottom
                                               multiplier:1.0f
                                               constant:0.0f];
    [containingView addConstraint:verticalPositioning];
    
    [containingView addConstraint:[NSLayoutConstraint
                                   constraintWithItem:sov
                                   attribute:NSLayoutAttributeWidth
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                   multiplier:1.0f
                                   constant:sov.bounds.size.width]];
    
    [containingView addConstraint:[NSLayoutConstraint
                                   constraintWithItem:sov
                                   attribute:NSLayoutAttributeHeight
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                   multiplier:1.0f
                                   constant:sov.bounds.size.height]];
    
    [containingView layoutIfNeeded];
    
    
    [UIView animateWithDuration:0.42 animations:^{
        [containingView removeConstraint:verticalPositioning];
        [containingView addConstraint:[NSLayoutConstraint
                                       constraintWithItem:sov
                                       attribute:NSLayoutAttributeBottom
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:containingView
                                       attribute:NSLayoutAttributeBottom
                                       multiplier:1.0f
                                       constant:0.0f]];
        [containingView layoutIfNeeded];
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

- (void)respondToDimAreaTapGesture: (UITapGestureRecognizer*) recognizer
{
    [self fadeOutCardChoice];
    [self.delegate tappedToAbandonWithText:self.shareText];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)respondToTapForCardGesture: (UITapGestureRecognizer*) recognizer
{
    [self.delegate tappedForCardWithText: self.shareText];
    self.shareTitle = [MWLocalizedString(@"share-article-name-on-wikipedia", nil)
             stringByReplacingOccurrencesOfString:@"$1" withString:self.shareTitle];
    [self transferSharingToDelegate];
}

- (void)respondToTapForTextGesture: (UITapGestureRecognizer*) recognizer
{
    [self.delegate tappedForCardWithText: self.shareText];
    if ([self.shareText isEqualToString:@""]) {
        self.shareTitle = [MWLocalizedString(@"share-article-name-on-wikipedia", nil)
                 stringByReplacingOccurrencesOfString:@"$1" withString:self.shareTitle];
    } else {
        self.shareTitle = [[MWLocalizedString(@"share-article-name-on-wikipedia-with-selected-text", nil)
                  stringByReplacingOccurrencesOfString:@"$1" withString:self.shareTitle]
                 stringByReplacingOccurrencesOfString:@"$2" withString:self.shareText];
    }
    
    MWKImage *bestImage = self.article.image;
    if (!bestImage) {
        bestImage = self.article.thumbnail;
    }
    if (bestImage) {
        self.shareImage = [bestImage asUIImage];
    } else {
        // Well, there's no image and the user didn't want a card
        self.shareImage = nil;
    }
    [self transferSharingToDelegate];
}

-(void) transferSharingToDelegate
{
    NSMutableArray *activityItemsArray = @[self.shareTitle, self.desktopURL].mutableCopy;
    if (self.shareImage) {
        [activityItemsArray addObject:self.shareImage];
    }
    [self fadeOutCardChoice];
    [self.delegate finishShareWithActivityItemsArray: (NSArray*) activityItemsArray text: self.shareText];
    [self dismissViewControllerAnimated:NO completion:nil];

}

@end
