//
//  SharableWebView.m
//  Wikipedia
//
//  Created by Adam Baso on 1/12/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "SharableWebView.h"

// NSString* const selectedStringJS = @"window.getSelection().toString().replace(/^[\r\n]+/,'').toString()";
NSString* const selectedStringJS = @"window.getSelection().toString()";

@implementation SharableWebView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(share:)) {
        if ([self getSelectedtext].length > 5) {
            return YES;
        }
        return NO;
    }
    return [super canPerformAction:action
                               withSender:sender];
}

- (void)share:(id)sender {
    NSString *selectedText = [self getSelectedtext];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectionShare"
                                                        object:self
                                                      userInfo:@{@"selectedText":selectedText}];
}

- (NSString *) getSelectedtext
{
    return [self stringByEvaluatingJavaScriptFromString:selectedStringJS];
}

@end
