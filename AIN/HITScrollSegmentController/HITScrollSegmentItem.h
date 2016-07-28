//
//  HITScrollSegmentItem.h
//  HITScrollListController
//
//  Created by Lolo on 16/5/12.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HITScrollSegmentItem : UILabel

@property(nonatomic,assign)CGFloat highlightProgress;
@property(nonatomic,assign)NSInteger index;

- (CGPoint)scaleFactor;
- (UIFont*)defaultFont;
- (UIFont*)highlightedFont;
@end
