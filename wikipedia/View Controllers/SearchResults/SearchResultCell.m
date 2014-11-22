//  Created by Monte Hurd on 11/19/13.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "SearchResultCell.h"
#import "WikipediaAppUtils.h"
#import "NSObject+ConstraintsScale.h"
#import "Defines.h"
#import "NSString+Extras.h"

@implementation SearchResultCell

@synthesize imageView;
@synthesize textLabel;
@synthesize bottomBorder;

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

    // Use finer line on retina displays
    self.bottomBorderHeight.constant = 1.0f / [UIScreen mainScreen].scale;

    // Initial changes to ui elements go here.
    // See: http://stackoverflow.com/a/15591474 for details.

    //self.textLabel.layer.borderWidth = 1;
    //self.textLabel.layer.borderColor = [UIColor redColor].CGColor;
    //self.backgroundColor = [UIColor greenColor];

    self.textLabel.textAlignment = [WikipediaAppUtils rtlSafeAlignment];
    
    [self adjustConstraintsScaleForViews:@[self.textLabel, self.imageView]];
}

-(void)prepareForReuse
{
    //NSLog(@"imageView frame = %@", NSStringFromCGRect(self.imageView.frame));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
