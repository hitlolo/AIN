//
//  HITImageController.h
//  AIN
//
//  Created by Lolo on 16/6/3.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HITImageController;

@protocol HITImageControllerDatasource <NSObject>
- (NSInteger)numberOfImagesForImageController:(HITImageController*)imagecontroller;
- (NSURL*)imageController:(HITImageController*)imagecontroller urlOfImageAtIndex:(NSInteger)index;
- (CGRect)imageController:(HITImageController*)imagecontroller originalFrameOfImageAtIndex:(NSInteger)index;
@end


@protocol HITImageControllerDelegate <NSObject>
@optional
- (void)imageController:(HITImageController*)imagecontroller willDissmissFromImageIndex:(NSInteger)index;
- (void)imageController:(HITImageController *)imagecontroller didSlideToImageIndex:(NSInteger)index;
@end

@protocol HITImageTappedDelegate <NSObject>
- (void)tappedOnImageSource:(id)source startIndex:(NSInteger)index;
@end


@interface HITImageController : UIViewController
@property(nonatomic,assign)NSInteger count;
@property(nonatomic,assign)NSInteger startIndex;
@property(nonatomic,assign)NSInteger currentIndex;
@property(nonatomic,weak)id<HITImageControllerDatasource> dataSource;
@property(nonatomic,weak)id<HITImageControllerDelegate> delegate;

- (instancetype)initWithDatasource:(id<HITImageControllerDatasource>)datasource Delegate:(id<HITImageControllerDelegate>)delegate;
- (instancetype)initWithDatasource:(id<HITImageControllerDatasource>)datasource Delegate:(id<HITImageControllerDelegate>)delegate startIndex:(NSInteger)index;

@end
