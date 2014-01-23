//  Created by Monte Hurd on 12/28/13.

#import "TOCNonSectionCellView.h"

@interface TOCNonSectionCellView(){

}

@property (strong, nonatomic) UILabel *titleLabel;

@property (nonatomic) CGFloat indentMarginMin;

@property (strong, nonatomic) NSMutableArray *titleLabelConstraints;

@end

@implementation TOCNonSectionCellView

- (id)init
{
    self = [super init];
    if (self) {
        
        self.titleLabelConstraints = [@[]mutableCopy];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.numberOfLines = 10;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.titleLabel];
        
        self.indentMarginMin = 6.0f;

        self.clipsToBounds = YES;

        self.titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        self.backgroundColor = [UIColor colorWithRed:0.333 green:0.6 blue:0.333 alpha:1.0];
    }
    return self;
}

-(void)constrainTitleLabel
{
    [self removeConstraints:self.titleLabelConstraints];
    void (^constrainTitleLabel)(NSLayoutAttribute, CGFloat) = ^void(NSLayoutAttribute a, CGFloat constant) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem: self.titleLabel
                                      attribute: a
                                      relatedBy: NSLayoutRelationEqual
                                         toItem: self
                                      attribute: a
                                     multiplier: 1.0
                                       constant: constant];

        [self addConstraint:constraint];
        [self.titleLabelConstraints addObject:constraint];
    };
    
    constrainTitleLabel(NSLayoutAttributeLeft, self.indentMarginMin);
    constrainTitleLabel(NSLayoutAttributeRight, -5);
    constrainTitleLabel(NSLayoutAttributeTop, 5);
    constrainTitleLabel(NSLayoutAttributeBottom, -5);

    CGFloat minTitleLabelHeight = 40;

    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[titleLabel(>=height)]"
                                             options: 0
                                             metrics: @{@"height": @(minTitleLabelHeight)}
                                               views: @{@"titleLabel": self.titleLabel}];
    [self addConstraints:constraints];
    [self.titleLabelConstraints addObjectsFromArray:constraints];
}

-(NSAttributedString *)getAttributedStringForString:(NSString *)str isLeadSection:(BOOL)isLeadSection
{
    NSUInteger fontSize = (isLeadSection) ? 22 : 15;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    return [[NSMutableAttributedString alloc]
            initWithString:str attributes: @{
                                             NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:fontSize],
                                             NSParagraphStyleAttributeName : paragraphStyle,
                                             NSStrokeWidthAttributeName : @0.0f, //@-1.0f,
                                             NSStrokeColorAttributeName : [UIColor blackColor],
                                             NSForegroundColorAttributeName : [UIColor whiteColor],
                                             }];
}

-(void)setText:(NSString *)text
{
    if (![_text isEqualToString:text]) {
        _text = text;
        self.titleLabel.attributedText = [self getAttributedStringForString:text isLeadSection:NO];
    }
}

-(void)updateConstraints
{
    [self removeConstraints:self.constraints];

    [self constrainTitleLabel];

    [super updateConstraints];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
