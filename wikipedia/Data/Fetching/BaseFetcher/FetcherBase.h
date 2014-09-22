//  Created by Monte Hurd on 10/9/14.
//  Copyright (c) 2014 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import <Foundation/Foundation.h>

// Enums for the FetchCompletionDelegate protocol method.
typedef NS_ENUM(NSInteger, FetchResult) {
    FETCH_RESULT_SUCCEEDED,
    FETCH_RESULT_CANCELLED,
    FETCH_RESULT_FAILED
};

// Protocol for notifying fetchCompletionDelegate that download has completed.
@protocol FetchCompletionDelegate <NSObject>

- (void)fetchFinishedForObject: (id)object
                        sender: (id)sender
                        result: (FetchResult)result
                          type: (NSInteger)type
                         error: (NSError *)error;

@end

@interface FetcherBase : NSObject

// Object to receive fetch completion notifications.
@property (nonatomic, assign) id <FetchCompletionDelegate> fetchCompletionDelegate;

@end
