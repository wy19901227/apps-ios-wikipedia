//  Created by Monte Hurd on 11/19/13.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "PageHistoryResultCell.h"
#import "NSObject+ConstraintsScale.h"
#import "PageHistoryLabel.h"

@implementation PageHistoryResultCell

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

    // Initial changes to ui elements go here.
    // See: http://stackoverflow.com/a/15591474 for details.
    
    self.separatorHeightConstraint.constant = 1.0f / [UIScreen mainScreen].scale;

    [self adjustConstraintsScaleForViews:@[self.summaryLabel, self.nameLabel, self.timeLabel, self.deltaLabel, self.iconLabel]];
}

@end
