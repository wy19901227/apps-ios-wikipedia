//
//  ShareCardViewController.m
//  Wikipedia
//
//  Created by Adam Baso on 1/14/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "ShareCardViewController.h"
#import "PaddedLabel.h"
#import "LeadImageContainer.h"
#import "SessionSingleton.h"

@interface ShareCardViewController ()
@property (strong, nonatomic) IBOutlet PaddedLabel *quote;
@property (strong, nonatomic) IBOutlet UIView *leadContainer;

@end

@implementation ShareCardViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    LeadImageContainer *lead = [[[NSBundle mainBundle] loadNibNamed: @"LeadImageContainer"
                                                              owner: nil
                                                            options: nil] firstObject];
    [lead showForArticle:[SessionSingleton sharedInstance].article];
    self.quote.text = @"yeeeeeeah";
    //UIView *l = self.leadImageContainer;
    //self.leadImageContainer.hidden = NO;
    [self.leadContainer addSubview:lead];
    UIView *l = self.leadContainer;
    NSString *d = @"hi";
    NSLog(@"%@", d);
    /*
    __weak ShareCardViewController *weakSelf = self;
    [weakSelf.leadImageContainer showForArticle:[SessionSingleton sharedInstance].article];
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
