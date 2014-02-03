//  Created by Monte Hurd on 2/9/14.

#import <Foundation/Foundation.h>

@interface KeychainCredentials : NSObject

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *editToken;

@end
