//
//  ShareCardView.h
//  Wikipedia
//
//  Created by Adam Baso on 1/16/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareCardView : UIView

@property (strong, nonatomic) IBOutlet UILabel *shareSelectedText;
@property (strong, nonatomic) IBOutlet UILabel *shareArticleTitle;
@property (strong, nonatomic) IBOutlet UILabel *shareDescription;

@end
