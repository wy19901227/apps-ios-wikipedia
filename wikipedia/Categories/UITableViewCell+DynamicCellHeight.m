//  Created by Monte Hurd on 11/22/14.
//  Copyright (c) 2014 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "UITableViewCell+DynamicCellHeight.h"

@implementation UITableViewCell (DynamicCellHeight)

// Based on this insanity: http://stackoverflow.com/a/18746930/135557
// However, I think best practice is to re-use a single offscreen cell for size determination.
-(CGFloat)heightForSizingCellInTableView:(UITableView *)tableView
{
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    self.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(self.bounds));
    [self setNeedsLayout];
    [self layoutIfNeeded];
    return [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1.0f;
}

@end
