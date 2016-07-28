//
//  ONESerialContentListTable.m
//  One
//
//  Created by Lolo on 16/5/2.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONESerialContentListTableController.h"
#import "ONESerialContentListTransition.h"
#import "ONESerialList.h"

#import "AINTableHeaderView.h"

static NSString* const cellIdentifier = @"listCell";
@interface ONESerialContentListTableController ()
@property(nonatomic,strong)id<UIViewControllerTransitioningDelegate> transition;

@end

@implementation ONESerialContentListTableController


- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.transition = [[ONESerialContentListTransitionDelegate alloc]init];
        self.transitioningDelegate = self.transition;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableView.rowHeight = 50;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.serialContentList.list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    ONESerialListItem* item = self.serialContentList.list[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"第%@话",item.number];
    // Configure the cell...
    
    return cell;
}

- (CGSize)preferredContentSize{
    CGSize size = CGSizeZero;
    size.width = [[UIScreen mainScreen]bounds].size.width / 4;
    size.height = [[UIScreen mainScreen]bounds].size.height;
    return size;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    AINTableHeaderView* header = [[AINTableHeaderView alloc]initWithMessage:@"目录"];
    header.messageLabel.textAlignment = NSTextAlignmentCenter;
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ONESerialListItem* item = self.serialContentList.list[indexPath.row];
    [self.delegate serialContentListTable:self didSelectedItem:item];
}

@end
