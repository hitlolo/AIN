//
//  AINBaseEmbededTableController.m
//  AIN
//
//  Created by Lolo on 16/5/30.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINBaseEmbededTableController.h"
#import "AINRootController.h"

@interface AINBaseEmbededTableController ()

@property(assign,nonatomic)BOOL isStatusbarHidden;
@end

@implementation AINBaseEmbededTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self embededTableView]) {
    
        CGFloat top = self.statusBarHeight + self.navigationBarHeight;
        UIEdgeInsets insets = UIEdgeInsetsMake(top, 0, 0, 0);
        [[self embededTableView]setContentInset:insets];
    }
    
    
}




- (UITableView*)embededTableView{
    return nil;
}


@end
