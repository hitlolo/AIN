//
//  AINReadingRecommendCell.h
//  AIN
//
//  Created by Lolo on 16/6/23.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ONEColumnItem;
@interface AINReadingRecommendCell : UITableViewCell

- (void)setIndex:(NSInteger)index;
- (void)setColumnItem:(ONEColumnItem*)columnItem;
@end
