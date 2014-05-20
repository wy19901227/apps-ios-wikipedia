//  Created by Monte Hurd on 5/15/14.
//  Copyright (c) 2014 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import <UIKit/UIKit.h>

@class TopMenuViewController, BottomMenuViewController, CenterNavController;

@interface RootViewController : UIViewController

@property (weak, nonatomic) TopMenuViewController *topMenuViewController;
@property (weak, nonatomic) CenterNavController *centerNavController;
@property (weak, nonatomic) BottomMenuViewController *bottomMenuViewController;

@property (nonatomic) BOOL topMenuHidden;
@property (nonatomic) BOOL bottomMenuHidden;

-(void)updateTopAndBottomMenuVisibilityForViewController:(UIViewController *)viewController;

-(void)animateTopAndBottomMenuToggle;





//TODO: override center nav controller versions of these and don't call
// super and output a msg saying use these ROOT versions instead

- (void)popToRootViewControllerAnimated:(BOOL)animated;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)popViewControllerAnimated:(BOOL)animated;
- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;




@end
