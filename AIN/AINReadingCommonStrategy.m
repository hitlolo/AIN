//
//  AINReadingCommonStrategy.m
//  AIN
//
//  Created by Lolo on 16/6/18.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINReadingCommonStrategy.h"


@interface AINReadingCommonStrategy ()
@end

@implementation AINReadingCommonStrategy

@synthesize hosterController = _hosterController;
@synthesize tableView = _tableView;
@synthesize columnContents = _columnContents;

- (instancetype)init{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(updateThemeWhenNotificationReceived)
                                                    name:mAINSettingManagerThemeChangeNotification
                                                  object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

- (void)updateThemeWhenNotificationReceived{
    UIColor* color = [[[AINSettingManager sharedManager]themeManager]backgroundColor];
    [self.hosterController.view setBackgroundColor:color];
    [self.tableView reloadData];
    
}



- (void)columnViewControllerDidLoad:(UIViewController*)hostController withTableView:(UITableView*)tableview{
    
    self.hosterController = hostController;
    self.tableView = tableview;
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

- (void)columnViewDidAppear:(BOOL)animated{
    
}

- (void)columnTableViewCellNeedRegisteredBeforeReuse:(UITableView *)tableview{
    
}

#pragma mark - Getter & Setter

- (NSMutableArray*)columnContents{
    if (_columnContents == nil) {
        _columnContents = [NSMutableArray array];
    }
    return _columnContents;
}
@end
