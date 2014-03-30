//  Created by Monte Hurd on 1/16/14.

#import "MWNetworkOp.h"

@interface EditTokenOp : MWNetworkOp

- (id)initForPageTitle: (NSString *)title
                domain: (NSString *)domain
       completionBlock: (void (^)(NSString *))completionBlock
        cancelledBlock: (void (^)(NSError *))cancelledBlock
            errorBlock: (void (^)(NSError *))errorBlock
;

@end
