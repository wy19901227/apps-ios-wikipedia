//
//  ShareOptionsView.m
//  Wikipedia
//
//  Created by Adam Baso on 1/23/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "ShareOptionsView.h"
#import "PaddedLabel.h"

@implementation ShareOptionsView

-(void) didMoveToSuperview
{
    // http://stackoverflow.com/questions/10316902/rounded-corners-only-on-top-of-a-uiview
    CAShapeLayer *topRoundingMaskLayer = [CAShapeLayer layer];
    topRoundingMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.cardImageViewContainer.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){4.2, 4.2f}].CGPath;
    self.cardImageViewContainer.layer.mask = topRoundingMaskLayer;
    CAShapeLayer *bottomRoundingMaskLayer = [CAShapeLayer layer];
    bottomRoundingMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.shareAsCardLabel.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){4.2, 4.2f}].CGPath;
    self.shareAsCardLabel.layer.mask = bottomRoundingMaskLayer;
    self.shareAsTextLabel.layer.cornerRadius = 7.0f;
    self.shareAsTextLabel.layer.masksToBounds = YES;
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

@end
