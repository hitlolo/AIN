
//
//  AINFMRootController.m
//  AIN
//
//  Created by Lolo on 16/7/7.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINFMRootController.h"
#import "AINRootController.h"
@interface AINFMRootController ()

@end

@implementation AINFMRootController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    [self.rootController setHideCustomBarOnSwipe:NO];
    [self.rootController setCustomToolbarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.rootController setHideCustomBarOnSwipe:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
