//  Created by Monte Hurd on 7/20/14.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import <Foundation/Foundation.h>

// The whole point of MWBlockOperation is that they will have isCancelled set to YES
// if any of the ops they depend upon have cancelled.

@interface MWBlockOperation : NSBlockOperation

- (void)addExecutionBlock:(void (^)(void))block;

@end
