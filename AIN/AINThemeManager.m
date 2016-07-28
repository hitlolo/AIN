//
//  AINThemeManager.m
//  AIN
//
//  Created by Lolo on 16/5/26.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINThemeManager.h"
#import "AINBackgroundView.h"
#import "AINBackgroundCellView.h"
#import "HITRefresh/HITTableRefreshHeader.h"
#import "HITRefresh/HITTableLoadmoreFooter.h"
#import "AINGalleryTableCell.h"
#import "ONEArticleDescriptionCell.h"
#import "ONEArticleReadingController.H"
#import "ONEReadingIndexCell.h"
#import "AINRootToolBarBackground.h"
#import "AINCommentCell.h"
#import "AINSubCommentView.h"

#import "ONEElephantDescriptionCell.h"

#import "ONEFMChannelCell.h"
#import "AINTableHeaderView.h"
#import "ONEFMLyricCell.h"

#import "HITMarqueeLabel.h"

#import "AINHeaderView.h"

NSString* const mAINSettingManagerThemeChangeNotification = @"mAINSettingManagerThemeChangeNotification";


@implementation AINThemeManager{
    BOOL initializeFlag;
}


- (void)loadOnTheme:(BOOL)night{
    if (night) {
        [self loadOnThemeNight];
    }
    else{
        [self loadOnThemeDay];
    }
    //the first time theme set dont post notification
    if (!initializeFlag) {
        initializeFlag = YES;
    }
    //others :post
    else if (initializeFlag){
        [self loadOnThemeForGlobal];
    }
}


- (void)loadOnThemeDay{
    
    self.tableBGColor = tableBGColorDay;
    self.backgroundColor = globalBGColorDay;
    self.tintColor = globalTintDay;
    self.fontColor = globalTextColorDay;
    
    //[[UIView appearance]setTintColor:globalTintDay];
    //[[UIView appearance]setBackgroundColor:globalBGColorDay];
    [[UIWindow appearance]setTintColor:globalTintDay];
    //[[UISwitch appearance]setOnTintColor:switchOnTintDay];
    //[[UISwitch appearance]setThumbTintColor:switchThumbTintDay];
    [[UITableViewCell appearance]setTintColor:globalTintDay];
    [[UITableViewCell appearance]setBackgroundColor:cellBGColorDay];
    [[UITableView appearance]setBackgroundColor:tableBGColorDay];
    [[AINBackgroundView appearance]setBackgroundColor:tableBGColorDay];
    [[AINBackgroundCellView appearance]setBackgroundColor:cellCustomBGColorDay];

    
    [[HITTableRefreshHeader appearance]setAnimationTintColor:globalTintDay];
    [[HITTableLoadmoreFooter appearance]setTextColor:globalGrayTextColor];
    [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[UITableViewCell class]]]setTextColor:globalTextColorDay];
    
   
    [[AINGalleryTableCell appearance]setBackgroundImage:one_background_motto_day];
    [[UITextView appearanceWhenContainedInInstancesOfClasses:@[[AINGalleryTableCell class]]]setTextColor:[UIColor whiteColor]];
    
    [[UITextView appearance]setTextColor:globalTextColorDay];
    
    [[UIWebView appearance]setBackgroundColor:globalBGColorDay];
    
    //[[AINGalleryTableCell appearance]setCellBackgroundColor:cellBGColorDay];
    [[AINGalleryTableCell appearance]setBackgroundColor:tableBGColorDay];
    [[ONEArticleDescriptionCell appearance]setBackgroundColor:cellCustomBGColorDay];
    [[ONEReadingIndexCell appearance]setBackgroundColor:cellCustomBGColorDay];
    [[AINCommentCell appearance]setBackgroundColor:cellCustomBGColorDay];
    
    [[ONEElephantDescriptionCell appearance]setBackgroundColor:cellCustomBGColorDay];
    
    [[ONEFMChannelCell appearance]setBackgroundColor:cellCustomBGColorDay];
    [[ONEFMLyricCell appearance]setBackgroundColor:cellCustomBGColorDay];
    
    [[AINTableHeaderView appearance]setBackgroundColor:headerBGColorDay];
    [[AINTableHeaderView appearance]setTextColor:globalTextColorDay];
    
    [[AINHeaderView appearance]setBackgroundColor:headerBGColorDay];
    [[AINHeaderView appearance]setTextColor:globalTextColorDay];
    
    [[HITMarqueeLabel appearance]setTextColor:globalTextColorDay];
    
    //[[UITextView appearanceWhenContainedInInstancesOfClasses:@[[AINSubCommentView class]]]setBackgroundColor:cellBGColorDay];
    
    [[UIScrollView appearanceWhenContainedInInstancesOfClasses:@[[ONEArticleReadingController class]]]setBackgroundColor:tableBGColorDay];
    
    [[UINavigationBar appearance]setBarStyle:UIBarStyleDefault];
    //[[UINavigationBar appearance]setBarTintColor:naviBarBGDay];
    [[UINavigationBar appearance]setTintColor:globalTintDay];
    
    [[UIToolbar appearance]setBarStyle:UIBarStyleDefault];
    [[UIToolbar appearance]setTintColor:toolBarTintColorDay];
    //[[UINavigationBar appearance]setBarTintColor:naviBarBGDay];
    [[UIBarButtonItem appearance]setTintColor:toolBarTintColorDay];
    
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class]]]setTitleColor:toolBarTintColorDay forState:UIControlStateNormal];
    
    [[AINRootToolBarBackground appearance]setBackgroundColor:toolBarBGColorDay];
    [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[AINRootToolBarBackground class]]]setTextColor:globalTextColorDay];
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[AINRootToolBarBackground class]]]setTintColor:toolBarTintColorDay];
    
    [[UIActivityIndicatorView appearance]setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
}

- (void)loadOnThemeNight{
    
    self.tableBGColor = tableBGColorNight;
    self.backgroundColor = globalBGColorNight;
    self.tintColor = globalTintNight;
    self.fontColor = globalTextColorNight;
    
    //[[UIView appearance]setTintColor:globalTintNight];
    //[[UIView appearance]setBackgroundColor:globalBGColorNight];
    [[UIWindow appearance]setTintColor:globalTintNight];
    //[[UISwitch appearance]setOnTintColor:swicthOnTintNight];
    //[[UISwitch appearance]setThumbTintColor:switchThumbTintNight];
    [[UITableViewCell appearance]setTintColor:globalTintNight];
    [[UITableViewCell appearance]setBackgroundColor:cellBGColorNight];
    [[UITableView appearance]setBackgroundColor:tableBGColorNight];
    [[AINBackgroundView appearance]setBackgroundColor:tableBGColorNight];
    [[AINBackgroundCellView appearance]setBackgroundColor:cellCustomBGColorNight];
    [[HITTableRefreshHeader appearance]setAnimationTintColor:globalTintNight];
    [[HITTableLoadmoreFooter appearance]setTextColor:globalTextColorNight];
    [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[UITableViewCell class]]]setTextColor:globalTextColorNight];
    
    
    [[AINGalleryTableCell appearance]setBackgroundImage:one_background_motto_night];
    [[UITextView appearanceWhenContainedInInstancesOfClasses:@[[AINGalleryTableCell class]]]setTextColor:globalGrayTextColor];
    //[[AINGalleryTableCell appearance]setCellBackgroundColor:cellBGColorNight];
    [[AINGalleryTableCell appearance]setBackgroundColor:tableBGColorNight];
    [[ONEArticleDescriptionCell appearance]setBackgroundColor:cellCustomBGColorNight];
    [[ONEReadingIndexCell appearance]setBackgroundColor:cellCustomBGColorNight];
    [[AINCommentCell appearance]setBackgroundColor:cellCustomBGColorNight];
    [[ONEElephantDescriptionCell appearance]setBackgroundColor:cellCustomBGColorNight];
    
    [[ONEFMChannelCell appearance]setBackgroundColor:cellCustomBGColorNight];
    [[ONEFMLyricCell appearance]setBackgroundColor:cellCustomBGColorNight];
    
    [[AINTableHeaderView appearance]setBackgroundColor:headerBGColorNight];
    [[AINTableHeaderView appearance]setTextColor:globalTextColorNight];
    
    [[AINHeaderView appearance]setBackgroundColor:headerBGColorNight];
    [[AINHeaderView appearance]setTextColor:globalTextColorNight];

    
    [[HITMarqueeLabel appearance]setTextColor:globalTextColorNight];
    //[[UITextView appearanceWhenContainedInInstancesOfClasses:@[[AINSubCommentView class]]]setBackgroundColor:cellBGColorNight];
    
    [[UIScrollView appearanceWhenContainedInInstancesOfClasses:@[[ONEArticleReadingController class]]]setBackgroundColor:tableBGColorNight];
    
    [[UITextView appearance]setTextColor:globalTextColorNight];
    
    [[UIWebView appearance]setBackgroundColor:globalBGColorNight];
    
    //[[UINavigationBar appearance]setBarTintColor:naviBarBGNight];
    [[UINavigationBar appearance]setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance]setTintColor:globalTintNight];
    //[[UINavigationBar appearance]setBarTintColor:naviBarBGNight];
    
    [[UIToolbar appearance]setBarStyle:UIBarStyleBlack];
    [[UIToolbar appearance]setTintColor:toolBarTintColorNight];
    [[UIBarButtonItem appearance]setTintColor:toolBarTintColorNight];
    
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class]]]setTitleColor:toolBarTintColorNight forState:UIControlStateNormal];
    
    [[AINRootToolBarBackground appearance]setBackgroundColor:toolBarBGColorNight];
    [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[AINRootToolBarBackground class]]]setTextColor:globalTextColorNight];
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[AINRootToolBarBackground class]]]setTintColor:toolBarTintColorNight];
    
    [[UIActivityIndicatorView appearance]setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];

}

- (void)loadOnThemeForGlobal{
    [[NSNotificationCenter defaultCenter]postNotificationName:mAINSettingManagerThemeChangeNotification
                                                       object:self];
    // reload all views to apply appearance change
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in windows) {
        for (UIView *view in window.subviews) {
            [view removeFromSuperview];
            [window addSubview:view];
        }        
    }

}

@end

//
//[[NSNotificationCenter defaultCenter]postNotificationName:mAINSettingManagerThemeChangeNotification
//                                                   object:self];