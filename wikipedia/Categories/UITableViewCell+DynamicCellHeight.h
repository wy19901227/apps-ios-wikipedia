//  Created by Monte Hurd on 11/22/14.
//  Copyright (c) 2014 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import <UIKit/UIKit.h>

@interface UITableViewCell (DynamicCellHeight)

// UITableView's "tableView:heightForRowAtIndexPath:" lets the table know how
// tall a cell needs to be. This method lets us easily determine the exact
// height via an offscreen sizing cell.
-(CGFloat)heightForSizingCellInTableView:(UITableView *)tableView;

@end
