#pragma mark Defines



#define CHROME_MENUS_HEIGHT ((NSInteger)(MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width) * 0.08))

#define ICON_PERCENT_OF_CHROME_MENUS_HEIGHT 0.739f






#define SEARCH_THUMBNAIL_WIDTH (48 * 3)
#define SEARCH_RESULT_HEIGHT 60
#define SEARCH_MAX_RESULTS 24

#define SEARCH_TEXT_FIELD_FONT [UIFont systemFontOfSize:(14.0 * (1.0f / ICON_PERCENT_OF_CHROME_MENUS_HEIGHT))]

#define SEARCH_TEXT_FIELD_HIGHLIGHTED_COLOR [UIColor blackColor]

#define SEARCH_RESULT_FONT [UIFont systemFontOfSize:(16.0 * (1.0f / ICON_PERCENT_OF_CHROME_MENUS_HEIGHT))]
#define SEARCH_RESULT_FONT_COLOR [UIColor colorWithWhite:0.0 alpha:0.85]

#define SEARCH_RESULT_FONT_HIGHLIGHTED [UIFont boldSystemFontOfSize:(16.0  * (1.0f / ICON_PERCENT_OF_CHROME_MENUS_HEIGHT))]
#define SEARCH_RESULT_FONT_HIGHLIGHTED_COLOR [UIColor blackColor]

#define SEARCH_FIELD_PLACEHOLDER_TEXT_COLOR [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]

#define HIDE_KEYBOARD_ON_SCROLL_THRESHOLD 55.0f

#define THUMBNAIL_MINIMUM_SIZE_TO_CACHE CGSizeMake(100, 100)

#define EDIT_SUMMARY_DOCK_DISTANCE_FROM_BOTTOM 68.0f

#define CHROME_COLOR [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0]

#define ALERT_FONT_SIZE (12  * (1.0f / ICON_PERCENT_OF_CHROME_MENUS_HEIGHT))
#define ALERT_BACKGROUND_COLOR [UIColor colorWithRed:(0.94 * 0.85) green:(0.94 * 0.85) blue:(0.96 * 0.85) alpha:1.0]
#define ALERT_PADDING UIEdgeInsetsMake(2, 10, 2, 10)

#define CHROME_OUTLINE_COLOR ALERT_BACKGROUND_COLOR
#define CHROME_OUTLINE_WIDTH (1.0f / [UIScreen mainScreen].scale)