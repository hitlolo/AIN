//
//  HITTableRefreshFooter.h
//  AIN
//
//  Created by Lolo on 16/5/27.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HITTableLoadmoreFooter : UIControl

@property(nonatomic,strong)UIColor*    textColor UI_APPEARANCE_SELECTOR;
@property(nonatomic,weak)UIScrollView* scrollView;

- (void)startLoadmore;
- (void)endLoadmoreWithMoreData:(BOOL)moredata infoMessage:(NSString*)message;
- (void)cleanUp;
@end
