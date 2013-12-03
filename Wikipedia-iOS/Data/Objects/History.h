//
//  History.h
//  Wikipedia-iOS
//
//  Created by Monte Hurd on 12/3/13.
//  Copyright (c) 2013 Wikimedia Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Article;

@interface History : NSManagedObject

@property (nonatomic, retain) NSDate * dateVisited;
@property (nonatomic, retain) Article *article;

@end
