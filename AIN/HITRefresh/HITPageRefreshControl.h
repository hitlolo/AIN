//
//  HITPageRefreshControl.h
//  UIViewTest
//
//  Created by Lolo on 16/4/9.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,HITPageRefreshControlType) {
    HITRefresh,
    HITLoadmore
};

@protocol HITPageRefreshControlDataSource <NSObject>

- (NSInteger)currentPageIndex;
- (NSInteger)pageCount;

@end

@interface HITPageRefreshControl : UIControl

@property(nonatomic,weak)id<HITPageRefreshControlDataSource> datasource;
@property(nonatomic,assign)HITPageRefreshControlType controlType;
- (void)triggerRefresh;
- (void)endRefresh;
- (BOOL)isRefreshing;
@end
