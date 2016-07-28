//
//  HITRefreshView.h
//  One
//
//  Created by Lolo on 16/4/18.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HITRefreshView <NSObject>

- (void)setProgress:(CGFloat)progress;
- (void)startAnimation;
- (void)endAnimation;

@end
