//  Created by Monte Hurd on 3/22/14.

#import "MWNetworkOp.h"

@interface TrelloDesignBoardCurrentOniOSCardsOp : MWNetworkOp

// Completion block is passed the retrieved list of "Current on iOS" cards - the
// dict key is the card id, and the dict value is the name of the list which
// contains the respective "Current on iOS" card. ie "#cardId#" = "Saved Pages".
- (id)initWithCompletionBlock: (void (^)(NSDictionary *))completionBlock
               cancelledBlock: (void (^)(NSError *))cancelledBlock
                   errorBlock: (void (^)(NSError *))errorBlock
;

@end

/*

Description:

    Op for getting list of "Current on iOS" cards from the "Latest App Design
    Assets by Page" trello board.

Future Use:

    Later hook this up so when in dev mode there's a quick way to send a screenshot
    to the relevant design board list's "Current on iOS" card. ie for "History" or
    "Saved Pages".

Example invocation:

    TrelloDesignBoardCurrentOniOSCardsOp *trelloOp =
        [[TrelloDesignBoardCurrentOniOSCardsOp alloc] initWithCompletionBlock:^(NSDictionary *currentOniOSCards){
            NSLog(@"\"Current on iOS\" cards = %@", currentOniOSCards);
        } cancelledBlock:^(NSError *error){
            [self showAlert:@"TrelloDesignBoardCurrentOniOSCardsOp Cancelled"];
        } errorBlock:^(NSError *error){
            [self showAlert:error.localizedDescription];
        }];
    trelloOp.delegate = self;
    [*SOME_NS_OPERATIONS_QUEUE* addOperation:trelloOp];

*/
