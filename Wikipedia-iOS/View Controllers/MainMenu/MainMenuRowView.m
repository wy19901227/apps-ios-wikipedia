//  Created by Monte Hurd on 3/27/14.

#import "MainMenuRowView.h"
#import "UIImage+ColorMask.h"

@interface MainMenuRowView()

@property (strong, nonatomic) UIColor *imageColor;

@end

/*

finish cleanup - make variant of top action sheet that doesn't get added
to the nav controller - actually the "TopActionSheetScrollView.m" can do 
what i need directly! just add it to the VC's view. will need to 
remove those couple places where i referenced the nav view for animation
of save page stuff etc

*/


@implementation MainMenuRowView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.highlighted = @YES;
        self.imageColor = [UIColor clearColor];
    }
    return self;
}

-(void)setImageName:(NSString *)imageName
{


//NSLog(@"tag = %@ highlighed %@", self.textLabel.text, self.highlighted);

        UIColor *rowColor =(self.highlighted.boolValue) ?
        [UIColor blackColor]
        :
        [UIColor lightGrayColor]
        ;
    
if (CGColorEqualToColor(rowColor.CGColor, self.imageColor.CGColor))return;
    
        self.thumbnailImageView.image =
            [[UIImage imageNamed:imageName] getImageOfColor:rowColor.CGColor];

self.imageColor = rowColor;

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
