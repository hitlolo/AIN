//
//  HITScrollSegmentView.h
//  HITScrollListController
//
//  Created by Lolo on 16/5/12.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HITScrollSegmentViewDatasource <NSObject>
- (NSArray*)segmentTitlesForScrollSegmentView;
@end

@protocol HITScrollSegmentViewDelegate <NSObject>
- (void)segmentItemDidSelected:(NSInteger)index;
- (void)segmentEditDidSelected:(UIButton*)sender;
@end



@interface HITScrollSegmentView : UIView

@property(nonatomic,weak)id<HITScrollSegmentViewDatasource> segmentDatasource;
@property(nonatomic,weak)id<HITScrollSegmentViewDelegate> segmentDelegate;

@property(nonatomic,strong)UIColor* titleDefaultColor;
@property(nonatomic,strong)UIColor* titleHighlightedColor;

- (void)highLightSegmentAtIndex:(NSInteger)index;
- (void)reloadData;

@end
