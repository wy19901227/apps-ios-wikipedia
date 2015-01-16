//
//  ShareCardViewController.m
//  Wikipedia
//
//  Created by Adam Baso on 1/16/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "ShareCardViewController.h"
#import "FocalImage.h"
#import "NSString+Extras.h"
#import "ShareCardImageContainer.h"

@interface ShareCardViewController ()

@property (weak, nonatomic) IBOutlet ShareCardImageContainer *shareCardImageContainer;
@property (weak, nonatomic) IBOutlet UILabel *shareSelectedText;
@property (weak, nonatomic) IBOutlet UILabel *shareArticleTitle;
@property (weak, nonatomic) IBOutlet UILabel *shareArticleDescription;
@end


@implementation ShareCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shareArticleTitle.textAlignment = NSTextAlignmentNatural;
    self.shareArticleTitle.layer.contentsGravity = kCAGravityTop;
    self.shareArticleDescription.textAlignment = NSTextAlignmentNatural;
    self.shareSelectedText.textAlignment = NSTextAlignmentNatural;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)fillCardWithMWKArticle:(MWKArticle *) article snippet:(NSString *) snippet
{

    self.shareArticleTitle.text = [article.displaytitle getStringWithoutHTML];
    self.shareArticleDescription.text = [[article.entityDescription getStringWithoutHTML] capitalizeFirstLetter];
    self.shareSelectedText.text = snippet;
    UIImage *leadImage = [article.image asUIImage];
    if (leadImage) {
        self.shareCardImageContainer.image = [[FocalImage alloc] initWithCGImage:leadImage.CGImage];
    }
}

@end
