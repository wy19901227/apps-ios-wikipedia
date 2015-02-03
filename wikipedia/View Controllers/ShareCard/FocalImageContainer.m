//
//  FocalImageContainer.m
//  Wikipedia
//
//  Created by Adam Baso on 1/20/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "FocalImageContainer.h"
#import "FocalImage.h"


@implementation FocalImageContainer

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self drawGradientBackground];
    [self.image drawInRect: rect
               focalBounds: [self.image getFaceBounds]
            focalHighlight: NO
                 blendMode: kCGBlendModeMultiply
                     alpha: 1.0];
}

-(void)drawGradientBackground
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    void (^drawGradient)(CGFloat, CGFloat, CGRect) = ^void(CGFloat upperAlpha, CGFloat bottomAlpha, CGRect rect) {
        CGFloat locations[] = {
            0.0,  // Upper color stop.
            1.0   // Bottom color stop.
        };
        CGFloat colorComponents[8] = {
            0.0, 0.0, 0.0, upperAlpha,  // Upper color.
            0.0, 0.0, 0.0, bottomAlpha  // Bottom color.
        };
        CGGradientRef gradient =
        CGGradientCreateWithColorComponents(colorSpace, colorComponents, locations, 2);
        CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGPoint endPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        CGGradientRelease(gradient);
    };
    
    drawGradient(0.4, 0.6, self.frame);
    CGColorSpaceRelease(colorSpace);
}


@end
