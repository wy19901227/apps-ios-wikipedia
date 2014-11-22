//  Created by Monte Hurd on 11/21/14.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "SearchResultAttributedString.h"
#import "Defines.h"
#import "NSString+Extras.h"

@implementation SearchResultAttributedString

+(instancetype)initWithTitle: (NSString *)title
                     snippet: (NSString *)snippet
         wikiDataDescription: (NSString *)description
              highlightWords: (NSArray *)wordsToHighlight
                  resultType: (SearchType)resultType
             attributesTitle: (NSDictionary *)attributesTitle
       attributesDescription: (NSDictionary *)attributesDescription
         attributesHighlight: (NSDictionary *)attributesHighlight
           attributesSnippet: (NSDictionary *)attributesSnippet
  attributesSnippetHighlight: (NSDictionary *)attributesSnippetHighlight
{
    SearchResultAttributedString *s = (SearchResultAttributedString *)[[NSMutableAttributedString alloc] initWithString:title attributes:nil];
    if (self) {
        
        // Set base color and font of the entire result title
        [s setAttributes: attributesTitle
                   range: NSMakeRange(0, s.length)];
        
        switch (resultType) {
            case SEARCH_TYPE_TITLES:
                for (NSString *word in wordsToHighlight.copy) {
                    // Title search term highlighting
                    NSRange rangeOfThisWord =
                    [title rangeOfString: word
                                 options: NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch];
                    [s setAttributes: attributesHighlight
                               range: rangeOfThisWord];
                }
                
                break;
            case SEARCH_TYPE_IN_ARTCILES:
                [s setAttributes: attributesHighlight
                           range: NSMakeRange(0, s.length)];
                break;
            default:
                
                break;
        }
        
        // Capitalize first character of WikiData description.
        description = [description capitalizeFirstLetter];
        
        // Style and append the wikidata description.
        if ((description.length > 0)) {
            NSMutableAttributedString *attributedDesc = [[NSMutableAttributedString alloc] initWithString:description];
            
            [attributedDesc setAttributes: attributesDescription
                                    range: NSMakeRange(0, attributedDesc.length)];
            
            NSAttributedString *newline = [[NSMutableAttributedString alloc] initWithString:@"\n"];
            [s appendAttributedString:newline];
            [s appendAttributedString:attributedDesc];
        }
        
        // Style the snippet and highlight any matches.
        if (snippet.length > 0) {
            NSMutableAttributedString *attrSnippet = [[NSMutableAttributedString alloc] init];
            snippet = [@"\n" stringByAppendingString:snippet];
            attrSnippet = [[NSMutableAttributedString alloc] initWithString:snippet];
            
            [attrSnippet setAttributes: attributesSnippet
                                 range: NSMakeRange(0, attrSnippet.length)];
            
            // Highlight words, but only on regex word boundary matches.
            for (NSString *word in wordsToHighlight.copy) {
                NSString *pattern = [NSString stringWithFormat:@"\\b(?:%@)\\b", [NSRegularExpression escapedPatternForString: word]];
                
                NSError *error = nil;
                NSRegularExpression *regex =
                [NSRegularExpression regularExpressionWithPattern: pattern
                                                          options: NSRegularExpressionCaseInsensitive
                                                            error: &error];
                
                [regex enumerateMatchesInString: [attrSnippet string] options:0
                                          range: NSMakeRange(0, [[attrSnippet string] length])
                                     usingBlock: ^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                                         [attrSnippet setAttributes: attributesSnippetHighlight
                                                              range: match.range];
                                     }];
            }
            [s appendAttributedString:attrSnippet];
        }
        
        
    }
    
    return s;
}

@end
