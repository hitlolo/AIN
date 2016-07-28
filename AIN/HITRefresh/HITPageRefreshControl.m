//
//  HITPageRefreshControl.m
//  UIViewTest
//
//  Created by Lolo on 16/4/9.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HITPageRefreshControl.h"
#import "HITArrowView.h"
#import "HITTreeView.h"


static NSString* const AnimationNameRollback = @"rollback";
static NSString* const AnimationNameEndrefresh = @"endRefresh";

typedef NS_ENUM(NSInteger, HITRefreshState) {
    HITRefreshStateListening = 0,
    HITRefreshStateCancelling,
    HITRefreshStateRefreshing,
};


@interface HITPageRefreshControl()<UIGestureRecognizerDelegate>

@property(nonatomic,strong)id<HITRefreshView> refreshView;
@property(nonatomic,assign,readwrite)HITRefreshState refreshState;
@property(nonatomic,assign)CGFloat pullProgress;
@property(nonatomic,assign)CGFloat maxPullDistance;
@property(nonatomic,assign)CGRect originalFrame;
@property(nonatomic,strong)UIPanGestureRecognizer* panGesture;
@property(nonatomic,strong)CADisplayLink* rollbackTimer;
@property(nonatomic,weak)UIScrollView* scrollView;

@end


@implementation HITPageRefreshControl


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare{
    
    _pullProgress = 0.0f;
    _maxPullDistance = 80.0f;
    _refreshState = HITRefreshStateListening;

}

#pragma mark - Setter & Getter

- (id<HITRefreshView>)refreshView{
    if (_refreshView == nil) {
        _refreshView = [[HITTreeView alloc]initWithFrame:self.bounds];
        //((HITArrowView*)_refreshView).shapeType = OneArrowShape;
        [self addSubview:(UIView*)_refreshView];
    }
    
    return _refreshView;
}

- (UIPanGestureRecognizer*)panGesture{
    if (_panGesture == nil) {
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(screenPaned:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

- (void)setProgress:(CGFloat)progress{
    _pullProgress = progress;
    [self.refreshView setProgress:progress];
}


#pragma mark - Gestures
- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    if (!newSuperview) {
        return;
    }
    self.scrollView = [self getScrollViewFromParent:newSuperview];
    //[self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self removeGestureFromSuperview];
    [self addGestureOnView:newSuperview];
    //ajust the original frame
    self.center = newSuperview.center;
    if (self.controlType == HITRefresh) {
        self.x = - self.frame.size.width;
    }else if (self.controlType == HITLoadmore){
        self.x = newSuperview.bounds.size.width;
    }
    self.originalFrame = self.frame;
    [self setProgress:0.0f];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
//    CGPoint offset = [[change objectForKey:NSKeyValueChangeNewKey]CGPointValue];
//    NSLog(@"%f",offset.x);
//}

- (void)addGestureOnView:(UIView*)view{
    [view addGestureRecognizer:self.panGesture];
}

- (void)removeGestureFromSuperview{
    if (!self.superview) {
        return;
    }
    [self.superview removeGestureRecognizer:self.panGesture];
}


- (void)screenPaned:(UIPanGestureRecognizer*)gesture{

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            [self handleGestureStateBegin:gesture];
            break;
        }            
        case UIGestureRecognizerStateChanged:{
            [self handleGestureStateChanged:gesture];
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            [self handleGestureStateCancelOrEnded:gesture];
            break;
        }
        default:
            break;
    }

}

- (void)handleGestureStateBegin:(UIPanGestureRecognizer*)panGesture{
    
    if (self.refreshState == HITRefreshStateRefreshing) {
        return;
    }
    else if (self.refreshState == HITRefreshStateCancelling){
        self.refreshState = HITRefreshStateListening;
        //cancel the on progress animation;
        [self cacelOnprogressRollbackAnimation];
    }
}

- (void)handleGestureStateChanged:(UIPanGestureRecognizer*)panGesture{
    
    CGRect toFrame = self.originalFrame;
    CGPoint translation = [panGesture translationInView:panGesture.view];
    toFrame.origin.x = [self translationLimits:translation.x + self.originalFrame.origin.x];
    translation.x = MIN(ABS(translation.x),+ self.maxPullDistance);
    [self setProgress:translation.x/ self.maxPullDistance] ;
    [self setFrame:toFrame];
    
}

- (void)handleGestureStateCancelOrEnded:(UIPanGestureRecognizer*)panGesture{
    
    if (self.pullProgress >= 0.95) {
        [self beginRefresh];
    }
    else{
        [self cancelRefresh];
    }
}

#pragma mark - gestuer delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if (self.refreshState == HITRefreshStateRefreshing) {
        return NO;
    }
    
    NSInteger currentPageIndex = [self.datasource currentPageIndex];
    NSInteger pageCount = [self.datasource pageCount];
    // -340 means At this point,there is no child viewcontroller for uiPageViewController's left or right.
    if ([gestureRecognizer isEqual:self.panGesture]) {
        CGPoint translation = [self.panGesture translationInView:self.panGesture.view];
        if (currentPageIndex == 0 && translation.x >= 0 && self.controlType == HITRefresh) {
            return YES;
        }
        else if (currentPageIndex == pageCount-1 && translation.x <= 0 && self.controlType == HITLoadmore){
            return YES;
        }
        else{
            return NO;
        }
    }
    return NO;
}


//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    UIPanGestureRecognizer* superViewGesture = self.scrollView.panGestureRecognizer;
//    if ([otherGestureRecognizer isEqual:superViewGesture]) {
//        return YES;
//    }
//    return NO;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    UIPanGestureRecognizer* superViewGesture = self.scrollView.panGestureRecognizer;
    if ([otherGestureRecognizer isEqual:superViewGesture]) {
        return YES;
    }
    return NO;
}



#pragma mark - Refresh Action

- (BOOL)isRefreshing{
    if (self.refreshState == HITRefreshStateRefreshing) {
        return YES;
    }
    return NO;
}

- (void)triggerRefresh{
    if (self.refreshState == HITRefreshStateRefreshing) {
        return;
    }
    
    int correction;;
    if (self.controlType == HITRefresh) {
        correction = 1;
    }else if (self.controlType == HITLoadmore){
        correction = -1;
    }
    
    CGRect toFrame = self.originalFrame;
    toFrame.origin.x += self.maxPullDistance * correction;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = toFrame;
    } completion:^(BOOL finished) {
        [self beginRefresh];
    }];
}


- (void)beginRefresh{
    
    [self setRefreshState:HITRefreshStateRefreshing];
    [self startSpinning];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
}

- (void)cancelRefresh{
    
    [self setRefreshState:HITRefreshStateCancelling];
    
    NSTimeInterval duration = [self animationDurationForAnimationDistance:(self.center.x - CGRectGetCenter(self.originalFrame).x)];
    CABasicAnimation* rollbackAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    rollbackAnimation.fromValue = [NSValue valueWithCGPoint:self.center];
    rollbackAnimation.toValue = [NSValue valueWithCGPoint:CGRectGetCenter(self.originalFrame)];
    rollbackAnimation.duration = duration;
    rollbackAnimation.delegate = self;
    rollbackAnimation.removedOnCompletion = YES;
    [rollbackAnimation setValue:AnimationNameRollback forKey:@"name"];
    [self.layer addAnimation:rollbackAnimation forKey:AnimationNameRollback];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.layer.frame = self.originalFrame;
    [CATransaction commit];

}

- (void)endRefresh{
    
    [self stopSpinning];
    
    CABasicAnimation* rollbackAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    rollbackAnimation.fromValue = [NSValue valueWithCGPoint:self.center];
    rollbackAnimation.toValue = [NSValue valueWithCGPoint:CGRectGetCenter(self.originalFrame)];
    rollbackAnimation.duration = 0.5f;
    rollbackAnimation.delegate = self;
    rollbackAnimation.removedOnCompletion = YES;
    [rollbackAnimation setValue:AnimationNameEndrefresh forKey:@"name"];
    [self.layer addAnimation:rollbackAnimation forKey:AnimationNameEndrefresh];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.layer.frame = self.originalFrame;
    [CATransaction commit];

}


- (void)startSpinning{
    
    [self.refreshView startAnimation];
}

- (void)stopSpinning{
    [self.refreshView endAnimation];
}


- (void)cacelOnprogressRollbackAnimation{
     [self.layer removeAnimationForKey:AnimationNameRollback];
}

- (void)animationDidStart:(CAAnimation *)anim{
    
    self.rollbackTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(progressBack)];
    [self.rollbackTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    
    [self.rollbackTimer invalidate];
    self.rollbackTimer = nil;
    
    
    
    NSString* name = [anim valueForKey:@"name"];
    
    //not completed animation
    if (!flag && [name isEqualToString:AnimationNameRollback]) {
        
        CGFloat offsetX = self.pullProgress * self.maxPullDistance;
        if (self.controlType == HITRefresh) {
            self.origin = CGPointMake(self.originalFrame.origin.x + offsetX, self.originalFrame.origin.y);
        }
        else if (self.controlType == HITLoadmore){
            self.origin = CGPointMake(self.originalFrame.origin.x - offsetX, self.originalFrame.origin.y);
        }
        
    }
    else if ([name isEqualToString:AnimationNameEndrefresh]){
        
        [self setRefreshState:HITRefreshStateListening];
        [self setProgress:0];
    }

}

- (void)progressBack{
    CGPoint origin = [self.layer.presentationLayer frame].origin;
    CGFloat progress;
    if (self.controlType == HITRefresh) {
        progress = (origin.x -  self.originalFrame.origin.x)/self.maxPullDistance;
    }
    else if (self.controlType == HITLoadmore){
        progress = (self.originalFrame.origin.x - origin.x )/self.maxPullDistance;
    }
    [self setProgress:progress];
}


-(NSTimeInterval)animationDurationForAnimationDistance:(CGFloat)distance{
    NSTimeInterval duration = MAX(distance/(self.maxPullDistance*2),0.15f);
    return duration;
}


#pragma mark - Helpers

- (CGFloat)translationLimits:(CGFloat)translation{
    
    if (self.controlType == HITRefresh) {
        if (translation < self.originalFrame.origin.x) {
            return self.originalFrame.origin.x;
        }
        else if(translation > (self.originalFrame.origin.x + self.maxPullDistance)){
            return (self.originalFrame.origin.x + self.maxPullDistance);
        }
    }
    else if (self.controlType == HITLoadmore){
        if (translation > self.originalFrame.origin.x) {
            return self.originalFrame.origin.x;
        }
        else if(translation < (self.originalFrame.origin.x - self.maxPullDistance )){
            return (self.originalFrame.origin.x - self.maxPullDistance);
        }
    }
    
    return translation;
}


- (UIScrollView*)getScrollViewFromParent:(UIView*)parent{
    for (UIView *view in parent.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            return (UIScrollView*)view;
        }
    }
    return nil;
}
@end
