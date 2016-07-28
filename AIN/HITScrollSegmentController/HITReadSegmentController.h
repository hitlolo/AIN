//
//  HITScrollSegmentController.h
//  HITScrollListController
//
//  Created by Lolo on 16/5/12.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HITReadSegmentControllerDelegate.h"

@interface HITReadSegmentController : UIViewController

@property(strong,nonatomic)UIColor* segmentBackgroundColor;
@property(strong,nonatomic)UIColor* segmentDefaultColor;
@property(strong,nonatomic)UIColor* segmentHighlightColor;

@property(strong,nonatomic)id<HITReadSegmentControllerDelegate> delegate;
@end
