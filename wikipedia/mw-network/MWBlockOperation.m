//  Created by Monte Hurd on 7/20/14.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "MWBlockOperation.h"

@implementation MWBlockOperation

- (void)addExecutionBlock:(void (^)(void))block
{
    // Before block is added, add a block which will cause cancel to be called if any
    // op which this op depends upon has been cancelled.
    __weak MWBlockOperation *weakSelf = self;
    [super addExecutionBlock:^{
        for (id obj in weakSelf.dependencies) {
            if ([obj isKindOfClass:[NSOperation class]]){
                NSOperation *op = (NSOperation *)obj;
                if ([op isCancelled]) {
                    [weakSelf cancel];
                    return;
                }
            }
        }
    }];

    // Now add block.
    [super addExecutionBlock:block];
}

@end
