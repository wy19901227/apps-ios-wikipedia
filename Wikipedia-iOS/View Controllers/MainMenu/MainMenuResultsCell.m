//  Created by Monte Hurd on 12/18/13.

#import "MainMenuResultsCell.h"

@implementation MainMenuResultsCell

@synthesize textLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    // Initial changes to ui elements go here.
    // See: http://stackoverflow.com/a/15591474 for details.

    //self.textLabel.layer.borderWidth = 1;
    //self.textLabel.layer.borderColor = [UIColor redColor].CGColor;
    //self.backgroundColor = [UIColor greenColor];

    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.textLabel.numberOfLines = 2;

    // Makes iOS 6 not use gross rounded cell borders.
    self.backgroundView = [[UIView alloc] init];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
