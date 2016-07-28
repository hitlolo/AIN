//
//  AINGalleryPaintingFetcher.h
//  AIN
//
//  Created by Lolo on 16/6/2.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AINPainting;
typedef NSMutableArray <__kindof AINPainting *> GalleryArray;

typedef void(^completionHttp)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error);
typedef void(^completionGallery)(GalleryArray* _Nullable galleryArray, NSError* _Nullable error);


@interface AINGalleryPaintingFetcher : NSObject


- (void)fetchPaintingsFromDatabaseWithOffset:(nonnull NSString*)paintingID
                           completionHandler:(nonnull completionGallery)handler;

- (void)fetchPaintingsFromHTTPWithOffset:(nonnull NSString*)paintingID
                      completionHandler:(nonnull completionGallery)handler;

- (void)fetchPaintingsByMonth:(nonnull NSString*)selectedMonth
            completionHandler:(nonnull completionGallery)handler;

- (void)fetchPaintingsByKeywords:(nonnull NSString*)keywords
               completionHandler:(nonnull completionGallery)handler;
@end
