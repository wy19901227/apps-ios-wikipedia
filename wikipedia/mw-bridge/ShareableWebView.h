//
//  ShareableWebView.h
//  Wikipedia
//
//  Created by Adam Baso on 1/20/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const ShareableWebViewWillShareNotification;

@interface ShareableWebView : UIWebView
- (void)shareSnippet:(id)sender;
- (NSString *) getSelectedtext;
@end
