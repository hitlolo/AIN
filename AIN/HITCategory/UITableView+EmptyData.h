//
//  UITableView+EmptyData.h
//  hitDota
//
//  Created by Lolo on 16/1/26.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (EmptyData)

- (void)tableViewDisplayMessage:(NSString*)message forRow:(NSUInteger)row;
- (void)tableViewDisplayMessage:(NSString*)message forRow:(NSUInteger)row separator:(UITableViewCellSeparatorStyle)style;
@end
