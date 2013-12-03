//
//  Image.h
//  Wikipedia-iOS
//
//  Created by Monte Hurd on 12/3/13.
//  Copyright (c) 2013 Wikimedia Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Article, GalleryImage, Section;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSDate * dateRetrieved;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * imageDescription;
@property (nonatomic, retain) NSString * extension;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * sourceUrl;
@property (nonatomic, retain) Article *article;
@property (nonatomic, retain) Section *section;
@property (nonatomic, retain) GalleryImage *galleryImage;

@end
