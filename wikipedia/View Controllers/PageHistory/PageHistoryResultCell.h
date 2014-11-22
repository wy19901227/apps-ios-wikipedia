//  Created by Monte Hurd on 11/19/13.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

@class PageHistoryLabel;

@interface PageHistoryResultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PageHistoryLabel *summaryLabel;
@property (weak, nonatomic) IBOutlet PageHistoryLabel *nameLabel;
@property (weak, nonatomic) IBOutlet PageHistoryLabel *timeLabel;
@property (weak, nonatomic) IBOutlet PageHistoryLabel *deltaLabel;
@property (weak, nonatomic) IBOutlet PageHistoryLabel *iconLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightConstraint;

@end
