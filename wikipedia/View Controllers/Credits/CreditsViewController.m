//  Created by Monte Hurd on 4/18/14.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "CreditsViewController.h"
#import "WikipediaAppUtils.h"

@interface CreditsViewController ()

@end

@implementation CreditsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.hidesBackButton = YES;

    self.titleLabel.text = MWLocalizedString(@"credits-title", nil);
    self.wikimediaReposLabel.text = MWLocalizedString(@"credits-wikimedia-repos", nil);
    self.externalLibrariesLabel.text = MWLocalizedString(@"credits-external-libraries", nil);
    self.githubLabel.text = MWLocalizedString(@"credits-github-mirror", nil);
    self.gerritLabel.text = MWLocalizedString(@"credits-gerrit-repo", nil);
    
    [self addTapRecognizerToView:self.githubLabel];
    [self addTapRecognizerToView:self.gerritLabel];
    [self addTapRecognizerToView:self.wikiFontLabel];
    [self addTapRecognizerToView:self.hppleLabel];
    [self addTapRecognizerToView:self.nsdateLabel];
}

-(void)addTapRecognizerToView:(UIView *)view
{
    [view addGestureRecognizer:
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)]
     ];
}

-(void)viewTapped:(UITapGestureRecognizer *)recognizer
{
    NSString *url = nil;
    if (recognizer.view == self.githubLabel) {
        url = @"https://github.com/wikimedia/apps-ios-wikipedia";
    }else if (recognizer.view == self.gerritLabel) {
        url = @"https://gerrit.wikimedia.org/r/#/q/project:apps/ios/wikipedia,n,z";
    }else if (recognizer.view == self.wikiFontLabel) {
        url = @"https://github.com/munmay/WikiFont";
    }else if (recognizer.view == self.hppleLabel) {
        url = @"https://github.com/topfunky/hpple";
    }else if (recognizer.view == self.nsdateLabel) {
        url = @"https://github.com/erica/NSDate-Extensions";
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
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
