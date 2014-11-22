//  Created by Monte Hurd on 11/19/13.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "SearchResultCell.h"
#import "WikipediaAppUtils.h"
#import "NSObject+ConstraintsScale.h"
#import "PaddedLabel.h"
#import "Defines.h"

#define MINIMUM_VERTICAL_PADDING 6.0f

@implementation SearchResultCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    self.resultLabel.padding =
        UIEdgeInsetsMake(MINIMUM_VERTICAL_PADDING, 0.0f, MINIMUM_VERTICAL_PADDING, 0.0f);

    // Initial changes to ui elements go here.
    // See: http://stackoverflow.com/a/15591474 for details.

    self.resultLabel.textAlignment = [WikipediaAppUtils rtlSafeAlignment];
    
    [self adjustConstraintsScaleForViews:@[self.resultLabel, self.resultImageView]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    [self drawBottomBorder:rect];
}

-(void)drawBottomBorder:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, CHROME_OUTLINE_WIDTH);

    // Draw the border on the bottom of the cell from the label's left to right.
    // Done this way so when things get flipped around in RTL languages the
    // border moves too.
    CGContextMoveToPoint(context, CGRectGetMinX(self.resultLabel.frame), CGRectGetMaxY(rect) - CHROME_OUTLINE_WIDTH);
    CGContextAddLineToPoint(context, CGRectGetMaxX(self.resultLabel.frame), CGRectGetMaxY(rect) - CHROME_OUTLINE_WIDTH);

    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextStrokePath(context);
}

@end
