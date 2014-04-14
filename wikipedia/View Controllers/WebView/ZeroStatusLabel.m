//  Created by Monte Hurd on 12/9/13.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "ZeroStatusLabel.h"

@implementation ZeroStatusLabel

- (id)init
{
    self = [super init];
    if (self) {

        self.paddingEdgeInsets = UIEdgeInsetsZero;

//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
//        [self addGestureRecognizer:tap];
    }
    return self;
}

//-(void)tap
//{
//    // Hide without delay.
//    self.alpha = 0.0f;
//}

//-(void)setHidden:(BOOL)hidden
//{
//    if (hidden){
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:0.35];
//        [UIView setAnimationDelay:1.0f];
//        [self setAlpha:0.0f];
//        [UIView commitAnimations];
//    }else{
//        [self setAlpha:1.0f];
//    }
//}

//-(void)setText:(NSString *)text
//{
//    if (text.length == 0){
//        // Just fade out if message is set to empty string
//        self.hidden = YES;
//    }else{
//        super.text = text;
//        self.hidden = NO;
//    }
//}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
//    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
//
//    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
//    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
//
//    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor] );
//    CGContextSetLineWidth(context, 1.0);
//
//    CGContextStrokePath(context);
//}

// Label padding edge insets! From: http://stackoverflow.com/a/21934948

-(void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.paddingEdgeInsets)];
}

-(CGSize)intrinsicContentSize {
    CGSize contentSize = [super intrinsicContentSize];
    UIEdgeInsets insets = self.paddingEdgeInsets;
    contentSize.height += insets.top + insets.bottom;
    contentSize.width += insets.left + insets.right;
    return contentSize;
}

@end
