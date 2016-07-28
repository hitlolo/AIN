//
//  AINSettingCenterController.m
//  AIN
//
//  Created by Lolo on 16/5/25.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINSettingCenterController.h"
#import "AINSettingManager.h"
#import "AINDBManager.h"

typedef NS_ENUM(NSInteger,SettingSection){
    AutoShutdown = 0,
    NightMode,
    ReadMode,
    Cache,
    About
};

@interface AINSettingCenterController ()
@property (strong, nonatomic) IBOutlet UISwitch *themeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *autoThemeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *autoHideBarSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *readModeSwitch;
@property (strong, nonatomic) IBOutlet UISegmentedControl *fontSizeSegment;
@property (strong, nonatomic) IBOutlet UILabel *cacheSizeLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *cacheSizeAcitivity;

@property(nonatomic,strong,readwrite)UINavigationItem* navigationItem;
@end

@implementation AINSettingCenterController

- (void)viewDidLoad{
    [super viewDidLoad];
    

    [self prepare];
}


- (void)prepare{
    [self prepareInitialStates];
    [self prepareActions];

}

- (void)prepareInitialStates{
    AINSettingManager * tempManager = [AINSettingManager sharedManager];
    self.themeSwitch.on = [tempManager isNightOn];
    self.autoThemeSwitch.on = [tempManager nightAutoChange];
    self.autoHideBarSwitch.on = [tempManager barAutoHide];
    self.readModeSwitch.on = [tempManager readInPageMode];
    self.fontSizeSegment.selectedSegmentIndex = [tempManager fontSize];
    
    
    [self.cacheSizeAcitivity startAnimating];
    //cache
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat cachedSize = [tempManager cachedSize];
        NSString* cachedSizeString;
        if (cachedSize <= 1.0f) {
            cachedSizeString = @"";
        }
        else{
            cachedSizeString = [NSString stringWithFormat:@"%.1fM",cachedSize];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cacheSizeLabel.text = cachedSizeString;
            [self.cacheSizeAcitivity stopAnimating];

        });
    });
    
}

- (void)prepareActions{
    [self.themeSwitch addTarget:self action:@selector(switchNightMode:) forControlEvents:UIControlEventValueChanged];
    [self.autoThemeSwitch addTarget:self action:@selector(switchAutoTheme:) forControlEvents:UIControlEventValueChanged];
    [self.autoHideBarSwitch addTarget:self action:@selector(swicthAutoHideBar:) forControlEvents:UIControlEventValueChanged];
    [self.readModeSwitch addTarget:self action:@selector(switchReadMode:) forControlEvents:UIControlEventValueChanged];
    [self.fontSizeSegment addTarget:self action:@selector(selecteFontSize:) forControlEvents:UIControlEventValueChanged];
}


//override
- (UINavigationItem*)navigationItem{
   
    if (_navigationItem == nil) {
        _navigationItem = [super navigationItem];
        //_navigationItem = [[UINavigationItem alloc]init];
        UIButton* dismissButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [dismissButton setImage:[UIImage imageNamed:@"ic_back_alpha"] forState:UIControlStateNormal];
        [dismissButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* dissmissItem = [[UIBarButtonItem alloc]initWithCustomView:dismissButton];
        
        [_navigationItem setTitle:@"设置"];
        [_navigationItem setLeftBarButtonItem:dissmissItem];
        
    }
    return _navigationItem;
}

#pragma mark - Actions

- (void)dismiss:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchNightMode:(UISwitch*)switcher{

    [[AINSettingManager sharedManager]setNightMode:switcher.isOn];
}

- (void)switchAutoTheme:(UISwitch*)switcher{
    [[AINSettingManager sharedManager]setNightAutoChange:switcher.isOn];
}

- (void)swicthAutoHideBar:(UISwitch*)switcher{
    [[AINSettingManager sharedManager]setBarAutoHide:switcher.isOn];
}

- (void)switchReadMode:(UISwitch*)switcher{
    [[AINSettingManager sharedManager]setReadInPageMode:switcher.isOn];
}

- (void)selecteFontSize:(UISegmentedControl*)segment{
    [[AINSettingManager sharedManager]setFontSize:segment.selectedSegmentIndex];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == Cache) {
        [self clearCache];
    }
}

- (void)clearCache{
    
    [self.cacheSizeLabel setHidden:YES];
    [self.cacheSizeAcitivity startAnimating];
    //cache
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[AINDBManager sharedManager]cleanDatabase];
        
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[SDImageCache sharedImageCache]clearDisk];
        
        
        dispatch_group_leave(group);
    });
    

    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CGFloat cachedSize = [[AINSettingManager sharedManager] cachedSize];
        NSString* cachedSizeString;
        if (cachedSize <= 1.0f) {
            cachedSizeString = @"";
        }
        else{
            cachedSizeString = [NSString stringWithFormat:@"%.1fM",cachedSize];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cacheSizeLabel.text = cachedSizeString;
            [self.cacheSizeLabel setHidden:NO];
            [self.cacheSizeAcitivity stopAnimating];

            
        });

    });
    


}

@end
