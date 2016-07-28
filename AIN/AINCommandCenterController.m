//
//  AINCommandCenterController.m
//  AIN
//
//  Created by Lolo on 16/5/25.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINCommandCenterController.h"

static const NSInteger kControllerSection = 0;
//static const NSInteger kProfileSection = 1;

@interface AINCommandCenterController ()


@end

@implementation AINCommandCenterController

- (void)awakeFromNib{
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(20, 0, 0, 0);
    
    CGSize screenSize = self.screenSize;
    _carouselHeader.width = screenSize.width;
    _carouselHeader.height = screenSize.width * 0.45;

}

- (CGSize)preferredContentSize{
    CGSize size = self.screenSize;
    size.height = size.height - self.statusBarHeight - 44;
    return size;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.carouselHeader reloadData];
}


#pragma mark - Tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == kControllerSection) {
        [self.commandDelegate commandCenterDidSelectedIndex:indexPath.row];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}





@end
