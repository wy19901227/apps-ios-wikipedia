//  Created by Monte Hurd on 1/29/14.

#import "AlertWebView.h"

#define ALERT_WEB_VIEW_BOTTOM_BAR_HEIGHT 50

@implementation AlertWebView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.webView = [[UIWebView alloc] init];
        self.webView.backgroundColor = [UIColor whiteColor];

        self.webView.delegate = self;
        self.actionButton = [[UIButton alloc] init];
        self.actionLabel = [[UILabel alloc] init];

        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        self.actionButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.actionLabel.translatesAutoresizingMaskIntoConstraints = NO;

        self.actionButton.backgroundColor = [UIColor colorWithRed:0.19 green:0.71 blue:0.56 alpha:1.0];
        self.actionLabel.backgroundColor = [UIColor clearColor];

        self.actionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        self.actionLabel.textColor = [UIColor darkGrayColor];

        self.userInteractionEnabled = YES;
        
        [self.actionButton addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];

        self.actionLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self.actionLabel addGestureRecognizer:tap];

        self.actionButton.contentEdgeInsets = UIEdgeInsetsMake(14, 14, 14, 14);

        self.actionButton.userInteractionEnabled = YES;
        self.actionLabel.userInteractionEnabled = YES;

        self.actionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.actionLabel.numberOfLines = 10;

        [self addSubview:self.webView];
        [self addSubview:self.actionButton];
        [self addSubview:self.actionLabel];
        
        [self addConstraints];
    }
    return self;
}

// Force web view links to open in Safari.
// From: http://stackoverflow.com/a/2532884
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType; 
{
    NSURL *requestURL = [request URL];
    if (
        (
         [[requestURL scheme] isEqualToString:@"http"]
         ||
         [[requestURL scheme] isEqualToString:@"https"]
         ||
         [[requestURL scheme] isEqualToString:@"mailto"])
        && (navigationType == UIWebViewNavigationTypeLinkClicked)
        ) {
        return ![[UIApplication sharedApplication] openURL:requestURL];
    }
    return YES;
}


-(void)tap
{
    [self removeFromSuperview];
}

-(void)addConstraints
{
    NSDictionary *viewsDictionary = @{
        @"webView": self.webView,
        @"actionButton": self.actionButton,
        @"actionLabel": self.actionLabel
    };

    NSDictionary *metrics = @{@"height" : @(ALERT_WEB_VIEW_BOTTOM_BAR_HEIGHT)};

    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|[webView]|"
      options:0
      metrics:nil
      views:viewsDictionary
      ]
     ];
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-[actionLabel]-[actionButton(height)]|"
      options:0
      metrics:metrics
      views:viewsDictionary
      ]
     ];

    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:|[webView][actionButton(height)]|"
      options:0
      metrics:metrics
      views:viewsDictionary
      ]
     ];
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:|[webView][actionLabel(height)]|"
      options:0
      metrics:metrics
      views:viewsDictionary
      ]
     ];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextMoveToPoint(context, CGRectGetMinX(rect) + 10, CGRectGetMaxY(rect) - ALERT_WEB_VIEW_BOTTOM_BAR_HEIGHT);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) - ALERT_WEB_VIEW_BOTTOM_BAR_HEIGHT);

    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor] );
    CGContextSetLineWidth(context, 1.0f / [UIScreen mainScreen].scale);
    CGContextStrokePath(context);
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
