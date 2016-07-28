//
//  AINBaseController.m
//  AIN
//
//  Created by Lolo on 16/5/26.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINBaseController.h"

@interface AINBaseController ()
<UIGestureRecognizerDelegate>
@property (strong, nonatomic, readwrite)UIPanGestureRecognizer* navibarHiddenGesture;

@end

@implementation AINBaseController

//- (void)loadView{
//    self.view = [[AINBackgroundView alloc]initWithFrame:CGRectMake(0, 0, self.screenSize.width, self.screenSize.height)];
//}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateThemeWhenNotificationReceived)
                                                name:mAINSettingManagerThemeChangeNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateNavigationBarAutoHide)
                                                name:mAINSettingManagerAutoHideBarChangeNotification
                                              object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateNavigationBarAutoHide];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//
//- (BOOL)prefersStatusBarHidden{
//    return YES;
//}

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    BOOL isNightOn = [[AINSettingManager sharedManager]isNightOn];
    if (isNightOn) {
        return UIStatusBarStyleLightContent;
    }
    else
        return UIStatusBarStyleDefault;
}

- (void)updateThemeWhenNotificationReceived{
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)updateNavigationBarAutoHide{
    BOOL isAutoHideNaviBar = [[AINSettingManager sharedManager]barAutoHide];
    if (self.navigationController) {
        
        [self setHideBarOnSwipe:isAutoHideNaviBar];
//        [self.navigationController setHidesBarsOnSwipe:isAutoHideNaviBar];
//        //[self setNeedsStatusBarAppearanceUpdate];
//        //[self updateViewConstraints];
//        if (!isAutoHideNaviBar) {
//            if ([self.navigationController.navigationBar isHidden]) {
//                [self.navigationController setNavigationBarHidden:NO];
//            }
//        }
    
    }
}


#pragma mark - custom toolbar

- (UIPanGestureRecognizer*)navibarHiddenGesture{
    if (_navibarHiddenGesture == nil) {
        _navibarHiddenGesture = [[UIPanGestureRecognizer alloc]init];
        _navibarHiddenGesture.delegate = self;
        [_navibarHiddenGesture addTarget:self action:@selector(swipedOnView:)];
    }
    return _navibarHiddenGesture;
}

- (void)swipedOnView:(UIPanGestureRecognizer*)pan{
    CGPoint translation = [pan translationInView:self.view];
    //swipe down
    
    if (pan.state == UIGestureRecognizerStateRecognized) {
        if (translation.y >= 0) {
            [self navibarShow];
        }
        //swipe up
        else{
            [self navibarHide];
        }
    }
    
}


- (void)setHideBarOnSwipe:(BOOL)hideCustomBarOnSwipe{
    
    if (hideCustomBarOnSwipe) {
        //[self toolbarShow];
        [self.view addGestureRecognizer:self.navibarHiddenGesture];
    }
    else{
        //[self toolbarHide];
        [self.view removeGestureRecognizer:self.navibarHiddenGesture];
    }
}

- (void)navibarHide{
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)navibarShow{
    
 [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
