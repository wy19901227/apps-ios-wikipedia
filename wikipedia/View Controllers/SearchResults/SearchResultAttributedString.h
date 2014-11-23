//  Created by Monte Hurd on 11/21/14.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "SearchResultFetcher.h"

@interface SearchResultAttributedString : NSMutableAttributedString

-(instancetype)initWithTitle: (NSString *)title
                     snippet: (NSString *)snippet
         wikiDataDescription: (NSString *)description
              highlightWords: (NSArray *)wordsToHighlight
                  resultType: (SearchType)resultType
// Note: pointers to attributes dictionaries are passed to this method for performance/memory reasons.
             attributesTitle: (NSDictionary *)attributesTitle
       attributesDescription: (NSDictionary *)attributesDescription
         attributesHighlight: (NSDictionary *)attributesHighlight
           attributesSnippet: (NSDictionary *)attributesSnippet
  attributesSnippetHighlight: (NSDictionary *)attributesSnippetHighlight;

@property (readonly, copy) NSString *string;
- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range;
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str;
- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range;

@end
