//  Created by Monte Hurd on 5/15/14.
//  Copyright (c) 2014 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import <UIKit/UIKit.h>

typedef enum {
    NAVBAR_BUTTON_UNKNOWN = 0,
    NAVBAR_BUTTON_X = 1,
    NAVBAR_BUTTON_PENCIL = 2,
    NAVBAR_BUTTON_CHECK = 3,
    NAVBAR_BUTTON_ARROW_LEFT = 4,
    NAVBAR_BUTTON_ARROW_RIGHT = 5,
    NAVBAR_BUTTON_LOGO_W = 6,
    NAVBAR_BUTTON_EYE = 7,
    NAVBAR_BUTTON_TOC = 8,
    NAVBAR_TEXT_FIELD = 9,
    NAVBAR_LABEL = 10,
    NAVBAR_VERTICAL_LINE = 11
} NavBarItemTag;

typedef enum {
    NAVBAR_MODE_UNKNOWN = 0,
    NAVBAR_MODE_SEARCH = 1,
    NAVBAR_MODE_SEARCH_WITH_TOC = 2,
    NAVBAR_MODE_EDIT_WIKITEXT = 3,
    NAVBAR_MODE_EDIT_WIKITEXT_WARNING = 4,
    NAVBAR_MODE_EDIT_WIKITEXT_DISALLOW = 5,
    NAVBAR_MODE_LOGIN = 6,
    NAVBAR_MODE_CREATE_ACCOUNT = 7,
    NAVBAR_MODE_EDIT_WIKITEXT_PREVIEW = 8,
    NAVBAR_MODE_EDIT_WIKITEXT_CAPTCHA = 9,
    NAVBAR_MODE_EDIT_WIKITEXT_SUMMARY = 10,
    NAVBAR_MODE_EDIT_WIKITEXT_LOGIN_OR_SAVE_ANONYMOUSLY = 11,
    NAVBAR_MODE_PAGE_HISTORY = 12,
    NAVBAR_MODE_CREDITS = 13,
    NAVBAR_MODE_EDIT_WIKITEXT_SAVE = 14
} NavBarMode;

typedef enum {
    NAVBAR_STYLE_UNKNOWN = 0,
    NAVBAR_STYLE_DAY = 1,
    NAVBAR_STYLE_NIGHT = 2
} NavBarStyle;


@interface TopMenuViewController : UIViewController <UITextFieldDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSString *currentSearchString;
@property (strong, atomic) NSMutableArray *currentSearchResultsOrdered;

@property (nonatomic) NavBarStyle navBarStyle;
@property (nonatomic) NavBarMode navBarMode;

-(id)getNavBarItem:(NavBarItemTag)tag;
-(void)updateTOCButtonVisibility;

@property (strong, nonatomic) IBOutlet UIView *navBarContainer;

@end
