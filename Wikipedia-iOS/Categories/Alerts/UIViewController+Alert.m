//  Created by Monte Hurd on 1/15/14.

#import "UIViewController+Alert.h"
#import "AlertLabel.h"

@implementation UIViewController (Alert)

-(void)showAlert:(NSString *)alertText
{
    AlertLabel *alertLabel = nil;

    UIView *alertLabelContainer = self.view;

    // Special case for web view alerts so they attach not to the view controller's
    // view but to the top of the webView itself.
//TODO: invoke in way that doesn't show annoying compiler warning.
    if ([self respondsToSelector:NSSelectorFromString(@"webView")]) {
        alertLabelContainer = [self performSelector:NSSelectorFromString(@"webView") withObject:nil];
    }

    // Reuse existing alert label if any.
    for (UIView *view in alertLabelContainer.subviews) {
        if ([view isMemberOfClass:[AlertLabel class]]) {
            alertLabel = (AlertLabel *)view;
            break;
        }
    }

    // If none to reuse, add one.
    if (!alertLabel) {
        alertLabel = [[AlertLabel alloc] init];
        alertLabel.translatesAutoresizingMaskIntoConstraints = NO;
        if (alertLabelContainer) {
            [alertLabelContainer addSubview:alertLabel];
            [self constrainAlertLabel:alertLabel];
        }
    }
    
    alertLabel.text = alertText;
}

-(void)constrainAlertLabel:(AlertLabel *)alertLabel
{
    id topGuide = self.topLayoutGuide;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (alertLabel, topGuide);

    [self.view addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|[alertLabel]|"
      options:0
      metrics:nil
      views:viewsDictionary
      ]
     ];
    [self.view addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:[topGuide][alertLabel(18)]"
      options:0
      metrics:nil
      views:viewsDictionary
      ]
     ];
}

@end
