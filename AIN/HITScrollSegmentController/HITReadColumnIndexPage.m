//
//  HITReadColumnPage.m
//  One
//
//  Created by Lolo on 16/5/15.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITReadColumnIndexPage.h"

@interface HITReadColumnIndexPage ()
@property(nonatomic,strong,readwrite)UITableView* tableView;
@end

@implementation HITReadColumnIndexPage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepare];
    
    [self.strategy columnViewControllerDidLoad:self withTableView:self.tableView];
    [self.strategy columnTableViewCellNeedRegisteredBeforeReuse:self.tableView];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.strategy columnViewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView{
    [super loadView];
    [self.view addSubview:self.tableView];
}

- (void)prepare{
 
    [self prepareTableView];
    [self prepareConstraints];
}

- (void)prepareTableView{
    
    self.tableView.delegate = self.strategy;
    self.tableView.dataSource = self.strategy;
}

- (void)prepareConstraints{
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:1.0f].active = YES;
    [self.tableView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:1.0f].active = YES;
    [self.tableView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.tableView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}


- (UITableView*)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]init];
        _tableView.estimatedRowHeight = 124.0f;
        _tableView.rowHeight = UITableViewAutomaticDimension;
    }
    return _tableView;
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
