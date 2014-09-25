//  Created by Monte Hurd on 11/19/13.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "PaddedLabel.h"

@interface PageHistoryResultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PaddedLabel *summaryLabel;
@property (weak, nonatomic) IBOutlet PaddedLabel *nameLabel;
@property (weak, nonatomic) IBOutlet PaddedLabel *timeLabel;
@property (weak, nonatomic) IBOutlet PaddedLabel *deltaLabel;
@property (weak, nonatomic) IBOutlet PaddedLabel *iconLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightConstraint;

@end
