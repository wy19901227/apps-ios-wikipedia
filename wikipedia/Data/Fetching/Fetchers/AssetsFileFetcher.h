//  Created by Monte Hurd on 10/9/14.
//  Copyright (c) 2014 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import <Foundation/Foundation.h>
#import "FetcherBase.h"
#import "AssetsFileEnum.h"

@class AFHTTPRequestOperationManager;

@interface AssetsFileFetcher : FetcherBase

/*
Syncs /AppData/Documents/assets/ file with a remote file.

Only does so if age of app file exceeds maxAge or if the file isn't found in app.

Nice because we can sync assets files with any periodicity
required just by firing these fetches off occasionally.

They self-cancel if maxAge has not been exceeded, so fire away.
*/

// Method to kick of download, results are reported to "delegate"
// via the FetchCompletionDelegate protocol method.
-(void)fetchAssetsFile: (AssetsFileEnum)file
                maxAge: (CGFloat)maxAge
           withManager: (AFHTTPRequestOperationManager *)manager;
@end
