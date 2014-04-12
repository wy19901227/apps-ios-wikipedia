//  Created by Monte Hurd on 4/11/14.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "LogEventOp.h"
#import "NSURLRequest+DictionaryRequest.h"
#import "NSString+Extras.h"

#define LOG_ENDPOINT @"https://bits.wikimedia.org/event.gif"

@implementation LogEventOp

-(NSUInteger)getRevisionForSchema:(EventLogSchema)schema
{
    switch (schema) {
        case LOG_SCHEMA_CREATEACCOUNT:
            return 8134803;
            break;
        case LOG_SCHEMA_READINGSESSION:
            return 8134785;
            break;
        case LOG_SCHEMA_EDIT:
            return 8134783;
            break;
        case LOG_SCHEMA_LOGIN:
            return 8134781;
            break;
        default:
            return 0;
            break;
    }
}

-(NSString *)getNameForSchema:(EventLogSchema)schema
{
    switch (schema) {
        case LOG_SCHEMA_CREATEACCOUNT:
            return @"MobileWikiAppCreateAccount";
            break;
        case LOG_SCHEMA_READINGSESSION:
            return @"MobileWikiAppReadingSession";
            break;
        case LOG_SCHEMA_EDIT:
            return @"MobileWikiAppEdit";
            break;
        case LOG_SCHEMA_LOGIN:
            return @"MobileWikiAppLogin";
            break;
        default:
            return @"";
            break;
    }
}

- (id)initWithSchema: (EventLogSchema)schema
               event: (NSDictionary *)event
{
    self = [super init];
    if (self) {

        NSDictionary *payload =
        @{
          @"event"    : event,
          @"revision" : @([self getRevisionForSchema:schema]),
          @"schema"   : [self getNameForSchema:schema]
          };

        NSData *payloadJsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
        NSString *payloadJsonString = [[NSString alloc] initWithData:payloadJsonData encoding:NSUTF8StringEncoding];
        NSString *encodedPayloadJsonString = [payloadJsonString urlEncodedUTF8String];
        NSString *urlString = [NSString stringWithFormat:@"%@?%@;", LOG_ENDPOINT, encodedPayloadJsonString];
        
        self.request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        
        self.completionBlock = ^(){
            //NSLog(@"EVENT LOGGING COMPLETED");
        };
    }
    return self;
}

@end
