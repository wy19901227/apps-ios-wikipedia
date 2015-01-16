//
//  ShareableWebView.m
//  Wikipedia
//
//  Created by Adam Baso on 1/20/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "ShareableWebView.h"

NSString *const ShareableWebViewWillShareNotification = @"SelectionShare";
NSString* const selectedStringJS = @"window.getSelection().toString()";

@implementation ShareableWebView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(shareSnippet:)) {
        if ([self getSelectedtext].length > 5) {
            return YES;
        }
        return NO;
    }
    return [super canPerformAction:action
                        withSender:sender];
}

- (void)shareSnippet:(id)sender {
    NSString *selectedText = [self getSelectedtext];
    [[NSNotificationCenter defaultCenter] postNotificationName:ShareableWebViewWillShareNotification
                                                        object:self
                                                      userInfo:@{
                                                                 @"beginShare" : @YES,
                                                                 @"selectedText" : selectedText
                                                                 }];
}

- (NSString *) getSelectedtext
{
    return [self stringByEvaluatingJavaScriptFromString:selectedStringJS];
}

@end
