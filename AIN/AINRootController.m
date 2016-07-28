//
//  AINRootControllerViewController.m
//  AIN
//
//  Created by Lolo on 16/5/26.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINRootController.h"
#import "AINTopdownTransition.h"
#import "AINCommandCenterController.h"
#import "AINTabBarController.h"
#import "AINRootToolbarController.h"


#import "AINReadArticleFetcher.h"
#import "ONEColumn.h"

#import "AINReadingRecommendController.h"


#import <AVFoundation/AVFoundation.h>

#import "AINPlayer.h"


@interface AINRootController ()
<AINTopdownTransitionDelegate,
AINCommandCenterDelegate,
UIGestureRecognizerDelegate,
AINRootToolbarDelegate,
AINCarouselDelegate,AINCarouselDataSource>


//toolbar hidden
@property (strong, nonatomic, readwrite)UIPanGestureRecognizer* toolbarHiddenGesture;
@property (strong, nonatomic) IBOutlet UIView *toolbar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *toolBarBottomConstraint;

//tabbar & command center
@property (strong, nonatomic) AINTopdownTransition* transition;
@property (strong, nonatomic) AINTabBarController* tabBarController;
@property (weak,   nonatomic) AINCommandCenterController* commandCenter;

@property (strong, nonatomic) NSMutableArray* columnsArray;



@end

@implementation AINRootController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _customToolbarHidden = NO;
    self.hideCustomBarOnSwipe = YES;
    _transition = [[AINTopdownTransition alloc]initWithInitialViewController:self];
    
    [self fetchCarouselColumns];
    
    [self setupBackgroundSession];
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    //远程控制中心
    [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    // 停止接受远程控制事件
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}



- (BOOL)canBecomeFirstResponder{
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupBackgroundSession{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
}

#pragma mark - Navigation


static NSString* const segueToolBarController = @"toolbarControllerSegue";
static NSString* const segueTabBarController = @"tabbarControllerSegue";
static NSString* const identifierCommandCenterController = @"commandCenter";

- (void)switchToTap:(AINTapSection)section{
    if (section == self.tabBarController.selectedIndex) {
        return;
    }
    [self.tabBarController setSelectedIndex:section];

}

- (AINTopdownTransition*)transition{
    if (_transition == nil) {
        _transition = [[AINTopdownTransition alloc]initWithInitialViewController:self];
    }
    return _transition;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:segueToolBarController]) {
        AINRootToolbarController* destinationViewController = segue.destinationViewController;
        destinationViewController.rootToolbarDelegate = self;
    }
    if ([segue.identifier isEqualToString:segueTabBarController]){
        AINTabBarController* destinationViewController = segue.destinationViewController;
        self.tabBarController = destinationViewController;
    }
}


- (void)presentCommandCenter{
    
    if (self.columnsArray == nil || [self.columnsArray count] == 0) {
        [self fetchCarouselColumns];
    }
    
    UIStoryboard* storyboard = nil;
    storyboard = self.storyboard;
    if (!storyboard) {
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    }
    AINCommandCenterController* destinationViewController = [storyboard instantiateViewControllerWithIdentifier:identifierCommandCenterController];
    destinationViewController.modalPresentationStyle = UIModalPresentationCustom;
    destinationViewController.transitioningDelegate = self.transition;
    destinationViewController.commandDelegate = self;
    destinationViewController.carouselHeader.delegate = self;
    destinationViewController.carouselHeader.datasource = self;
    self.commandCenter = destinationViewController;
    [self presentViewController:destinationViewController animated:YES completion:nil];

}


#pragma mark - AINTopdownTransition delegate

static NSString* identifierCommandCenter = @"commandCenter";

- (void)interactiveTransitionDelegateDidBinded:(UIGestureRecognizer *)gesture{
    [self.view addGestureRecognizer:gesture];
}

- (void)interactiveTransitionWillBegin{
    [self presentCommandCenter];
}

#pragma mark - AINCommandCenter delegate

- (void)commandCenterDidSelectedIndex:(NSInteger)index{
    [self.tabBarController setSelectedIndex:index];
}


#pragma mark - CommandCenter Carousel

- (NSMutableArray*)columnsArray{
    if (_columnsArray == nil) {
        _columnsArray = [NSMutableArray array];
    }
    return _columnsArray;
}


#pragma mark - carousel delegate

- (void)fetchCarouselColumns{
    
    [[AINReadArticleFetcher sharedFetcher]fetchColumnWithCompletion:^(ColumnArray * _Nullable columnArray, NSError * _Nullable error) {
        if (!error) {
            [self.columnsArray addObjectsFromArray:columnArray];
            if (self.commandCenter) {
                if ([self.columnsArray count] != 0 && self.commandCenter.carouselHeader.numberOfPages == 0) {
                    [self.commandCenter.carouselHeader reloadData];
                }
            }
        }
    }];
}


- (NSInteger)numberOfItemsForCarousel:(AINCarouselView *)carousel{
    return [self.columnsArray count];
}

- (UIView*)viewForIndex:(NSInteger)index forCarousel:(AINCarouselView *)carousel{
    
    ONEColumn* column = self.columnsArray[index];
    NSURL* url = [NSURL URLWithString:column.cover];
    
    UIImageView* imageview = [[UIImageView alloc]init];
    [imageview sd_setImageWithURL:url];
    return imageview;
}

- (void)carousel:(AINCarouselView *)carousel didSelectedIndex:(NSInteger)index{
    
    [self dismissViewControllerAnimated:YES completion:^{
        AINReadingRecommendController* columnController = [[AINReadingRecommendController alloc]init];
        columnController.column = self.columnsArray[index];
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:columnController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:navigationController animated:YES completion:nil];
    }];
}



#pragma mark - custom toolbar

- (UIPanGestureRecognizer*)toolbarHiddenGesture{
    if (_toolbarHiddenGesture == nil) {
        _toolbarHiddenGesture = [[UIPanGestureRecognizer alloc]init];
        _toolbarHiddenGesture.delegate = self;
        [_toolbarHiddenGesture addTarget:self action:@selector(swipedOnView:)];
    }
    return _toolbarHiddenGesture;
}

- (void)swipedOnView:(UIPanGestureRecognizer*)pan{
    CGPoint translation = [pan translationInView:self.view];
    //swipe down
    
    if (pan.state == UIGestureRecognizerStateRecognized) {
        if (translation.y >= 0) {
            [self toolbarShow];
        }
        //swipe up
        else{
            [self toolbarHide];
        }
    }
    
}

- (void)setCustomToolbarHidden:(BOOL)customToolbarHidden{
    
//    if (_customToolbarHidden == customToolbarHidden) {
//        return;
//    }
    _customToolbarHidden = customToolbarHidden;
    
    if (_customToolbarHidden) {
        [self toolbarHide];
    }
    else{
        [self toolbarShow];
    }
}

- (void)setHideCustomBarOnSwipe:(BOOL)hideCustomBarOnSwipe{
    if (_hideCustomBarOnSwipe == hideCustomBarOnSwipe) {
        return;
    }
    
    _hideCustomBarOnSwipe = hideCustomBarOnSwipe;
    
    if (_hideCustomBarOnSwipe) {
        //[self toolbarShow];
        [self.view addGestureRecognizer:self.toolbarHiddenGesture];
    }
    else{
        //[self toolbarHide];
        [self.view removeGestureRecognizer:self.toolbarHiddenGesture];
    }
}

- (void)toolbarHide{

    self.toolBarBottomConstraint.constant = self.toolbar.height;
    [UIView animateWithDuration:0.4f animations:^{
        self.toolbar.alpha = 0.0f;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.toolbar.hidden = YES;
    }];
}

- (void)toolbarShow{

    self.toolbar.hidden = NO;
    self.toolBarBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.4f animations:^{
        self.toolbar.alpha = 1.0f;
        [self.view layoutIfNeeded];
    } completion:nil];

}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}




#pragma mark - custom toolbar deleagte

- (void)toolbar:(AINRootToolbarController *)toolbar windowButtonDidClicked:(id)sender{
    [self presentCommandCenter];
}



#pragma mark - remote controll & info center
// MARK: 响应远程音乐播放控制消息
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent{
    
    if (receivedEvent.type == UIEventTypeRemoteControl)
    {
        
        switch (receivedEvent.subtype)
        {
                
            case UIEventSubtypeRemoteControlPlay:
                [[AINPlayer sharedPlayer]unpause];
                break;
            case UIEventSubtypeRemoteControlPause:
                [[AINPlayer sharedPlayer]pause];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [[AINPlayer sharedPlayer]next];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                break;
            default:
                break;
        }
    }
}

@end





#pragma mark - Category

@implementation UIViewController (AINRootController)

- (AINRootController*)rootController{
    UIViewController *parent = self;
    Class slideClass = [AINRootController class];
    while ( parent != nil  ) {
        if( [parent isKindOfClass:slideClass] ){
            break;
        }
        parent = [parent parentViewController];
    }
    return (id)parent;
}

@end
