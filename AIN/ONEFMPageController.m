//
//  ONEFMPageController.m
//  One
//
//  Created by Lolo on 16/5/3.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEFMPageController.h"
#import "ONEFMPanelController.h"
#import "ONEFMChannelController.h"
#import "ONEFMLyricController.h"
#import "AINPlayer.h"


@interface ONEFMPageController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource,ONEChannelControllerSelectDelage>
@property (nonatomic,strong)UIPageViewController* pageController;
@property (nonatomic,strong)ONEFMPanelController* panelController;
@property (nonatomic,strong)ONEFMLyricController* lyricController;
@property (nonatomic,strong)ONEFMChannelController* channelController;
@end

@implementation ONEFMPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepare];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepare{
    
    [self prepareViewControllers];
    
    [self preparePageController];
    
}

- (void)preparePageController{
   

    self.pageController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
    
    [self.pageController setViewControllers:@[self.panelController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
 
}

- (void)prepareViewControllers{
    self.panelController = [self.storyboard instantiateViewControllerWithIdentifier:@"panel"];
    self.lyricController = [self.storyboard instantiateViewControllerWithIdentifier:@"lyric"];
    self.channelController = [self.storyboard instantiateViewControllerWithIdentifier:@"channel"];
    self.channelController.delegate = self;
}

- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    if (viewController == self.panelController) {
        return self.lyricController;
    }
    if (viewController == self.channelController) {
        return self.panelController;
    }
    if (viewController == self.lyricController) {
        return nil;
    }
    return nil;
}

- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    if (viewController == self.panelController) {
        return self.channelController;
    }
    if (viewController == self.channelController) {
        return nil;
    }
    if (viewController == self.lyricController) {
        return self.panelController;
    }
    return nil;
}

#pragma Channel delegate

- (void)channelController:(ONEFMChannelController *)channelController didSelectedChannel:(ONEChannel *)channel{
    [self.pageController setViewControllers:@[self.panelController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    
    [[AINPlayer sharedPlayer].fmPlayer playList].currentChannel = channel;
// TODO: selected channel
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
