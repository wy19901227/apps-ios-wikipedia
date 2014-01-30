//  Created by Monte Hurd on 1/29/14.

#import <UIKit/UIKit.h>

@interface AlertWebView : UIView <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UILabel *actionLabel;
@property (strong, nonatomic) UIButton *actionButton;

@end
