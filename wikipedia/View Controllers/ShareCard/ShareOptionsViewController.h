//
//  ShareOptionsViewController.h
//  Wikipedia
//
//  Created by Adam Baso on 2/6/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShareTapDelegate

-(void) didShowSharePreviewForMWKArticle: (MWKArticle*) article withText: (NSString*) text;
-(void) tappedToAbandonWithText: (NSString*) text;
-(void) tappedForCardWithText: (NSString*) text;
-(void) tappedForTextWithText: (NSString*) text;
-(void) finishShareWithActivityItemsArray: (NSArray*) activityItemsArray text: (NSString*) text;
@end

@interface ShareOptionsViewController : UIViewController

- (instancetype)initWithMWKArticle: (MWKArticle*) article snippet: (NSString *) snippet backgroundView: (UIView*) backgroundView delegate: (id) delegate;

@end
