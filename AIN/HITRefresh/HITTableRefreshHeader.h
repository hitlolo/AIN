//
//  HITTableRefreshHeader.h
//  AIN
//
//  Created by Lolo on 16/5/27.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HITTableRefreshHeader : UIControl

@property(nonatomic,weak)UIScrollView* scrollView;
@property(nonatomic,strong)UIColor* animationTintColor UI_APPEARANCE_SELECTOR;


- (void)startRefresh;
- (void)endRefresh;

- (void)cleanUp;

@end
