//  Created by Monte Hurd on 2/21/14.

#import "AccountCreationViewController.h"
#import "NavController.h"

#define NAV ((NavController *)self.navigationController)

@interface AccountCreationViewController ()

@end

@implementation AccountCreationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.hidesBackButton = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NAV.navBarMode = NAVBAR_MODE_CREATE_ACCOUNT;
    ((UILabel *)[NAV getNavBarItem:NAVBAR_LABEL]).text = @"Create Account";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Listen for nav bar taps.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navItemTappedNotification:) name:@"NavItemTapped" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NavItemTapped" object:nil];

    NAV.navBarMode = NAVBAR_MODE_SEARCH;

    [super viewWillDisappear:animated];
}

// Handle nav bar taps.
- (void)navItemTappedNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    UIView *tappedItem = userInfo[@"tappedItem"];

    switch (tappedItem.tag) {
        case NAVBAR_BUTTON_CHECK:
            [self save];
            break;
        case NAVBAR_BUTTON_ARROW_LEFT:
            [self hide];
            break;
        default:
            break;
    }
}

-(void)save
{
    NSLog(@"SAVE");
}

-(void)hide
{
    [self.navigationController popViewControllerAnimated:YES];
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
