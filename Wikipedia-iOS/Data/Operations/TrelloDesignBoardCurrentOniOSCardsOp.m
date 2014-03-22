//  Created by Monte Hurd on 3/22/14.

#import "TrelloDesignBoardCurrentOniOSCardsOp.h"
#import "MWNetworkActivityIndicatorManager.h"
#import "NSURLRequest+DictionaryRequest.h"

@implementation TrelloDesignBoardCurrentOniOSCardsOp

- (id)initWithCompletionBlock: (void (^)(NSDictionary *))completionBlock
               cancelledBlock: (void (^)(NSError *))cancelledBlock
                   errorBlock: (void (^)(NSError *))errorBlock
{
    self = [super init];
    if (self) {
    
        NSURL *latestDesignAssetsByPageBoardURL =
            [NSURL URLWithString:@"https://api.trello.com/1/board/Id6qXKSY"];
        
        NSMutableDictionary *parameters =
            @{
              @"cards":          @"open",
              @"lists":          @"open",
              @"list_fields":    @"name,idBoard",
              @"card_fields":    @"name,idShort,idList,idBoard"
              //@"key":          @"",
              }.mutableCopy;
        
        self.request = [NSURLRequest getRequestWithURL: latestDesignAssetsByPageBoardURL
                                             parameters: parameters
                        ];
        
        __weak TrelloDesignBoardCurrentOniOSCardsOp *weakSelf = self;
        self.aboutToStart = ^{
            [[MWNetworkActivityIndicatorManager sharedManager] push];
        };
        self.completionBlock = ^(){
            [[MWNetworkActivityIndicatorManager sharedManager] pop];
            
            if(weakSelf.isCancelled){
                cancelledBlock(weakSelf.error);
                return;
            }
            
            // Check for error retrieving section zero data.
            if(!weakSelf.jsonRetrieved || weakSelf.jsonRetrieved.count == 0){
                NSMutableDictionary *errorDict =
                @{
                  NSLocalizedDescriptionKey: @"TrelloDesignBoardCurrentOniOSCardsOp Unknown Error"
                  }.mutableCopy;
                
                // Set error condition so dependent ops don't even start and so the errorBlock below will fire.
                weakSelf.error = [NSError errorWithDomain:@"TrelloDesignBoardCurrentOniOSCardsOp" code:001 userInfo:errorDict];
            }
            
            if (weakSelf.error) {
                errorBlock(weakSelf.error);
                return;
            }

            //NSLog(@"weakSelf.jsonRetrieved = %@", weakSelf.jsonRetrieved);
  
            NSMutableDictionary *board = @{}.mutableCopy;
            board[weakSelf.jsonRetrieved[@"id"]] = weakSelf.jsonRetrieved[@"name"];
            
            NSMutableDictionary *lists = @{}.mutableCopy;
            for (NSDictionary *list in weakSelf.jsonRetrieved[@"lists"]) {
                lists[list[@"id"]] = list[@"name"];
            }
            
            NSMutableDictionary *cards = @{}.mutableCopy;
            for (NSDictionary *card in weakSelf.jsonRetrieved[@"cards"]) {
                if ([card[@"name"] isEqualToString:@"Current on iOS"]) {
                    if ([lists objectForKey:card[@"idList"]]) {
                        cards[card[@"id"]] = lists[card[@"idList"]];
                    }
                }
            }
            
            completionBlock(cards);
        };
    }
    return self;
}

@end
