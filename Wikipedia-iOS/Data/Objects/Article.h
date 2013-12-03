//
//  Article.h
//  Wikipedia-iOS
//
//  Created by Monte Hurd on 12/3/13.
//  Copyright (c) 2013 Wikimedia Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DiscoveryContext, DiscoveryMethod, GalleryImage, History, Image, Saved, Section;

@interface Article : NSManagedObject

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSNumber * lastScrollLocation;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *discoveryContext;
@property (nonatomic, retain) DiscoveryMethod *discoveryMethod;
@property (nonatomic, retain) NSSet *history;
@property (nonatomic, retain) NSSet *saved;
@property (nonatomic, retain) NSSet *section;
@property (nonatomic, retain) Image *thumbnailImage;
@property (nonatomic, retain) NSSet *galleryImage;
@end

@interface Article (CoreDataGeneratedAccessors)

- (void)addDiscoveryContextObject:(DiscoveryContext *)value;
- (void)removeDiscoveryContextObject:(DiscoveryContext *)value;
- (void)addDiscoveryContext:(NSSet *)values;
- (void)removeDiscoveryContext:(NSSet *)values;

- (void)addHistoryObject:(History *)value;
- (void)removeHistoryObject:(History *)value;
- (void)addHistory:(NSSet *)values;
- (void)removeHistory:(NSSet *)values;

- (void)addSavedObject:(Saved *)value;
- (void)removeSavedObject:(Saved *)value;
- (void)addSaved:(NSSet *)values;
- (void)removeSaved:(NSSet *)values;

- (void)addSectionObject:(Section *)value;
- (void)removeSectionObject:(Section *)value;
- (void)addSection:(NSSet *)values;
- (void)removeSection:(NSSet *)values;

- (void)addGalleryImageObject:(GalleryImage *)value;
- (void)removeGalleryImageObject:(GalleryImage *)value;
- (void)addGalleryImage:(NSSet *)values;
- (void)removeGalleryImage:(NSSet *)values;

@end
