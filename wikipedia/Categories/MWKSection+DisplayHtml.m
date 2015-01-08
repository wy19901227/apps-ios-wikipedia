//  Created by Monte Hurd on 5/31/14.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "MWKSection+DisplayHtml.h"
#import "SessionSingleton.h"
#import "Defines.h"

@implementation MWKSection (DisplayHtml)

-(NSString *)displayHTML:(NSString *)html
{
    BOOL isMainPage = [[SessionSingleton sharedInstance] isCurrentArticleMain];

    return
        [NSString stringWithFormat:@"<div id='section_heading_and_content_block_%ld'>%@<div id='content_block_%ld'>%@</div></div>",
             (long)self.sectionId,
             (isMainPage ? @"" : [self getHeaderTag]),
             (long)self.sectionId,
             html
         ];
}

-(NSString *)getHeaderTag
{
    NSString *pencilAnchor = [self getEditPencilAnchor];

    if (self.sectionId == 0) {

        // Lead section.
            // The lead section is a special case because of the native component used
            // for lead image styling. Its 'section_heading' can be a div (no need for
            // 'H' tag) since it won't need to display any text. The title text is now
            // shown by the native component.
        return
            [NSString stringWithFormat:@"%@<div class='section_heading' data-id='0' id='0'>%@</div>",
                [self getLeadImagePlaceholderDiv],
                pencilAnchor
            ];

    }else{

        // Non-lead section.
        NSInteger headingTagSize = [self getHeadingTagSize];

        return
            [NSString stringWithFormat:@"<h%ld class='section_heading' data-id='%ld' id='%@'>%@%@</h%ld>",
                (long)headingTagSize,
                (long)self.sectionId,
                self.anchor,
                self.line,
                pencilAnchor,
                (long)headingTagSize
            ];
    }
}

-(NSInteger)getHeadingTagSize
{
    // Varies <H#> tag size based on section level.
    
    NSInteger size = self.level.integerValue;

    // Don't go smaller than 1 - ie "<H1>"
    size = MAX(size, 1);

    // Don't go larger than 6 - ie "<H6>"
    size = MIN(size, 6);

    return size;
}

-(NSString *)getEditPencilAnchor
{
    return
        [NSString stringWithFormat: @"<a class='edit_section_button' data-action='edit_section' data-id='%ld'></a>",
            (long)self.sectionId
        ];
}

-(NSString *)getLeadImagePlaceholderDiv
{
    // Placeholder div to reserve vertical space for the lead image native component.

    // Its height needs to be set right away, here, so there's no flicker on load.
    CGFloat initialLeadImageHeight =
        (!self.article.imageURL) ? 0.0f : LEAD_IMAGE_CONTAINER_HEIGHT;

    return
        [NSString stringWithFormat:@"<div id='lead_image_div' style='height:%fpx;background-color:white;'></div>",
            initialLeadImageHeight
        ];
}

@end
