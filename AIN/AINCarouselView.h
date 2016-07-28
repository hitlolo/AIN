//
//  AINCarouselView.h
//  AIN
//
//  Created by Lolo on 16/5/25.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AINCarouselView;

@protocol AINCarouselDataSource <NSObject>
- (NSInteger)numberOfItemsForCarousel:(AINCarouselView *)carousel ;
- (UIView*)viewForIndex:(NSInteger)index forCarousel:(AINCarouselView*)carousel;
@end

@protocol AINCarouselDelegate <NSObject>
- (void)carousel:(AINCarouselView *)carousel didSelectedIndex:(NSInteger)index;
@end

@interface AINCarouselView : UIView

@property(nonatomic,assign)NSInteger numberOfPages;
@property(nonatomic,assign)NSInteger currentIndex;

@property(nonatomic,weak)id<AINCarouselDataSource> datasource;
@property(nonatomic,weak)id<AINCarouselDelegate> delegate;
- (void)reloadData;
@end
