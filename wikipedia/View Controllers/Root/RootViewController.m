//  Created by Monte Hurd on 5/15/14.
//  Copyright (c) 2014 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "RootViewController.h"
#import "TopMenuViewController.h"
#import "BottomMenuViewController.h"
#import "WebViewController.h"

@interface RootViewController (){
    
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerContainerBottomConstraint;

@property (nonatomic) CGFloat initalCenterContainerTopConstraintConstant;
@property (nonatomic) CGFloat initalCenterContainerBottomConstraintConstant;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContainerHeightConstraint;

@end

@implementation RootViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.initalCenterContainerTopConstraintConstant = 0;
        self.initalCenterContainerBottomConstraintConstant = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat topMenuInitialHeight = 45;
    CGFloat bottomMenuInitialHeight = 45;
    
    // iOS 7 needs to have room for a view behind the top status bar.
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        topMenuInitialHeight += [self getStatusBarHeight];
    }
    
    self.centerContainerTopConstraint.constant = topMenuInitialHeight;
    self.topContainerHeightConstraint.constant = topMenuInitialHeight;
    
    self.centerContainerBottomConstraint.constant = bottomMenuInitialHeight;
    self.bottomContainerHeightConstraint.constant = bottomMenuInitialHeight;
}

-(void)setTopMenuHidden:(BOOL)topMenuHidden
{
    _topMenuHidden = topMenuHidden;

    // iOS 6 can blank out the web view this isn't scheduled for next run loop.
    [[NSRunLoop currentRunLoop] performSelector: @selector(animateUpdateToTopMenuVisibility)
                                         target: self
                                       argument: nil
                                          order: 0
                                          modes: [NSArray arrayWithObject:@"NSDefaultRunLoopMode"]];
}

-(void)setBottomMenuHidden:(BOOL)bottomMenuHidden
{
    _bottomMenuHidden = bottomMenuHidden;

    // iOS 6 can blank out the web view this isn't scheduled for next run loop.
    [[NSRunLoop currentRunLoop] performSelector: @selector(animateUpdateToBottomMenuVisibility)
                                         target: self
                                       argument: nil
                                          order: 0
                                          modes: [NSArray arrayWithObject:@"NSDefaultRunLoopMode"]];
}

-(void)animateUpdateToTopMenuVisibility
{
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [self updateTopMenuVisibility];
        [self.view layoutIfNeeded];

    } completion:^(BOOL done){
        
    }];
}

-(void)updateTopMenuVisibility
{
    // Remember the initial constants so they can be returned to when menu shown again.
    if (self.initalCenterContainerTopConstraintConstant == 0) {
        self.initalCenterContainerTopConstraintConstant = self.centerContainerTopConstraint.constant;
    }
    
    // Fade out the top menu when it is hidden.
    CGFloat alpha = self.topMenuHidden ? 0.0 : 1.0;
    
    // Height for top menu when visible.
    CGFloat visibleTopMenuHeight = self.initalCenterContainerTopConstraintConstant;
    
    // iOS 7 needs to have room for a view behind the top status bar.
    CGFloat statusBarHeight = 0;
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        statusBarHeight = [self getStatusBarHeight];
    }
    
    CGFloat topMenuHeight = self.topMenuHidden ? statusBarHeight : visibleTopMenuHeight;
    
    self.centerContainerTopConstraint.constant = topMenuHeight;
    
    //self.topMenuViewController.navBarContainer.alpha = alpha;
    for (UIView *v in self.topMenuViewController.navBarContainer.subviews) {
        v.alpha = alpha;
    }
}

-(void)animateUpdateToBottomMenuVisibility
{
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{

        [self updateBottomMenuVisibility];
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL done){
        
    }];
}

-(void)updateBottomMenuVisibility
{
    // Remember the initial constants so they can be returned to when menu shown again.
    if (self.initalCenterContainerBottomConstraintConstant == 0) {
        self.initalCenterContainerBottomConstraintConstant = self.centerContainerBottomConstraint.constant;
    }
    
    // Height for bottom menu when visible.
    CGFloat visibleBottomMenuHeight = self.initalCenterContainerBottomConstraintConstant;
    
    CGFloat bottomMenuHeight = self.bottomMenuHidden ? 0 : visibleBottomMenuHeight;
    
    self.centerContainerBottomConstraint.constant = bottomMenuHeight;
}

-(void)animateTopAndBottomMenuToggle
{
    // iOS 6 can blank out the web view this isn't scheduled for next run loop.
    [[NSRunLoop currentRunLoop] performSelector: @selector(animateTopAndBottomMenuToggleNextRunLoop)
                                         target: self
                                       argument: nil
                                          order: 0
                                          modes: [NSArray arrayWithObject:@"NSDefaultRunLoopMode"]];
}

-(void)animateTopAndBottomMenuToggleNextRunLoop
{
    // Don't use the setters here as we want both animations to happen in the single
    // animateWithDuration call here, not in the setters' animateWithDuration.
    _topMenuHidden = !self.topMenuHidden;
    _bottomMenuHidden = !self.bottomMenuHidden;

    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{

        [self updateBottomMenuVisibility];
        [self updateTopMenuVisibility];
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL done){
        
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString: @"TopMenuViewController_embed"]) {
		self.topMenuViewController = (TopMenuViewController *) [segue destinationViewController];
	}else if ([segue.identifier isEqualToString: @"BottomMenuViewController_embed"]) {
		self.bottomMenuViewController = (BottomMenuViewController *) [segue destinationViewController];
	}else if ([segue.identifier isEqualToString: @"CenterNavController_embed"]) {
		self.centerNavController = (CenterNavController *) [segue destinationViewController];
    }
}

-(CGFloat)getStatusBarHeight
{
    return 20;
}

-(void)updateTopAndBottomMenuVisibilityForViewController:(UIViewController *)viewController
{
    if([viewController isMemberOfClass:[WebViewController class]]){
        // Ensure the bottom menu is shown once the web view is loaded.
        self.bottomMenuHidden = NO;
    }else{
        // Ensure the top menu is shown and bottom menu is hidden after navigating
        // away from the web view.
        self.topMenuHidden = NO;
        self.bottomMenuHidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
