//
//  HITReadColumnPage.h
//  One
//
//  Created by Lolo on 16/5/15.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HITReadSegmentControllerDelegate.h"
@interface HITReadColumnIndexPage : UIViewController

@property(nonatomic,strong,readonly)UITableView* tableView;
@property(nonatomic,strong)id<HITReadSegmentColumnStrategy> strategy;
@property(nonatomic,assign)NSInteger index;
@end
