//
//  HITZoomImageView.h
//  AIN
//
//  Created by Lolo on 16/6/11.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>


@protocol HITZoomImageViewDismissDelegate <NSObject>
- (void)dismiss;
@end
@interface HITZoomImageView : UIScrollView
@property(nonatomic,weak)id<HITZoomImageViewDismissDelegate> dismissDelegate;
@property(nonatomic,strong,readonly)UIImageView* imageView;
- (void)scaleBack;
@end
