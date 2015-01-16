//
//  ShareCardViewController.m
//  Wikipedia
//
//  Created by Adam Baso on 1/16/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "ShareCardViewController.h"
#import "ShareCardView.h"
#import "FocalImage.h"
#import "NSString+Extras.h"
#import "FocalImageContainer.h"

@interface ShareCardViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *shareLeadImage;
@property (weak, nonatomic) IBOutlet FocalImageContainer *focalImage;
@property (weak, nonatomic) IBOutlet UILabel *shareSelectedText;
@property (weak, nonatomic) IBOutlet UILabel *shareArticleTitle;
@property (weak, nonatomic) IBOutlet UILabel *shareArticleDescription;
@end


@implementation ShareCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*
    UIView *shareCard = [[[NSBundle mainBundle] loadNibNamed:@"ShareCard" owner:self options:nil] firstObject];
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fillCardWithMWKArticle:(MWKArticle *) article snippet:(NSString *) snippet
{
    self.shareArticleTitle.textAlignment = NSTextAlignmentNatural;
    self.shareArticleTitle.text = [article.displaytitle getStringWithoutHTML];
    self.shareArticleDescription.textAlignment = NSTextAlignmentNatural;
    self.shareArticleDescription.text = [[article.entityDescription getStringWithoutHTML] capitalizeFirstLetter];
    self.shareSelectedText.textAlignment = NSTextAlignmentNatural;
    self.shareSelectedText.text = snippet;
    UIImage *leadImage = [article.image asUIImage];
    if (leadImage) {
        self.focalImage.image = [[FocalImage alloc] initWithCGImage:leadImage.CGImage];
        /*
        self.shareLeadImage.hidden = NO;
        
        CGFloat desiredHeightToWidthRatio = self.shareLeadImage.frame.size.height / self.shareLeadImage.frame.size.width;
        CGFloat actualHeightToWidthRatio = leadImage.size.height / leadImage.size.width;
        if (actualHeightToWidthRatio > desiredHeightToWidthRatio) {
            CGFloat scalingRequired = self.shareLeadImage.frame.size.width / leadImage.size.width;
            CGSize scaledSize = CGSizeMake(leadImage.size.width * scalingRequired, leadImage.size.height * scalingRequired);
            UIGraphicsBeginImageContextWithOptions(scaledSize, NO, 0.0);
            [leadImage drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
            leadImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.shareLeadImage.contentMode = UIViewContentModeTop;
        } else {
            self.shareLeadImage.contentMode = UIViewContentModeScaleAspectFill;
        }

        self.shareLeadImage.image = leadImage;
         */
    }
    
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
