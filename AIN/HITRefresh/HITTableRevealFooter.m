//
//  HITTableRevealFooter.m
//  AIN
//
//  Created by Lolo on 16/5/27.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITTableRevealFooter.h"


typedef NS_ENUM(NSInteger, HITRefreshState) {
    HITRefreshStateListening = 0,
    HITRefreshStatePulling,
    HITRefreshStateTriggering,
    HITRefreshStateReleasing,
    HITRefreshStateRefreshing,
};

@interface HITTableRevealFooter ()
@property(nonatomic,weak)id<HITTableRevealInteractiveDelegate> interactiveTransitionDelegate;
@property(nonatomic,assign)HITRefreshState refreshState;

@property(nonatomic,assign)CGFloat triggerDistance;
@property(nonatomic,assign)CGFloat maxPullDistance;
@property(nonatomic,assign)CGFloat originalOffsetY;
@property(nonatomic,assign)CGFloat pullProgress;

@property(nonatomic,assign)BOOL triggered;
@property(nonatomic,assign)BOOL released;
@end

@implementation HITTableRevealFooter

- (instancetype)init{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}


- (void)prepare{
    _released = NO;
    _triggered = NO;
    _triggerDistance = 30.0f;
    _maxPullDistance = 80.0f;
    _originalOffsetY = 0.0f;
    _pullProgress = 0.0f;
    
    _transition = [[HITTableRevealTransition alloc]init];
    _interactiveTransitionDelegate = _transition.inInteractive;
}


#pragma mark - Overrides

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self.superview sendSubviewToBack:self];
}


#pragma mark - Getter & Setter

- (void)setScrollView:(UIScrollView *)scrollView{
    if (_scrollView == scrollView) {
        return;
    }
    
    [self removeOffsetObserver];
    
    _scrollView = scrollView;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.alwaysBounceVertical = YES;
    _originalOffsetY = _scrollView.contentInset.bottom;
    
    [self addOffsetObserver];
    
}


#pragma mark - refresh

- (void)dealloc{
    [self removeOffsetObserver];
}

- (void)addOffsetObserver{
    
    [self.scrollView addObserver:self
                      forKeyPath:@"contentOffset"
                         options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                         context:nil];
}

- (void)removeOffsetObserver{
    
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        CGPoint old = [change[@"old"] CGPointValue];
        CGPoint new = [change[@"new"] CGPointValue];
        
        BOOL pullingUp = [self isPullingFooterUp:old newPosition:new];
        BOOL bouncingDown = [self isBouncingFooterDown:old newPosition:new];
        
        CGFloat offset;
        if (_scrollView.contentSize.height >= _scrollView.height) {
            offset = _scrollView.height + new.y;
        }
        else{
            offset = _scrollView.contentSize.height + new.y;
        }

        offset = fabs(offset - _scrollView.contentSize.height);
        
        // pulling up and not triggered
        // trigger reveal
        
        
       
        
        if (pullingUp && _scrollView.dragging && self.triggered == NO && offset >= self.triggerDistance) {
            self.refreshState = HITRefreshStateTriggering;
        }
        // triggered
        // pulling up
        else if (pullingUp && offset >= self.triggerDistance && _scrollView.tracking && self.triggered == YES) {
            self.refreshState = HITRefreshStatePulling;
        }
        // triggered
        // pulling down
        else if (bouncingDown && _scrollView.dragging) {
            self.refreshState = HITRefreshStatePulling;
        }
        
        // bounce down but not release
        // trigger release
    
        else if (bouncingDown && !_scrollView.dragging && self.released == NO) {
            self.refreshState = HITRefreshStateReleasing;
            
        }
        
        // bounce down
        // under the trigger distance
        // restore to the default state
        else if (bouncingDown && offset <= self.triggerDistance && self.triggered == YES){
            self.triggered = NO;
            self.released = NO;
            self.refreshState = HITRefreshStateListening;
        }
        else{
            self.refreshState = HITRefreshStateListening;

        }
        //do
        [self scrollViewContentOffsetDidChanged:offset];
        
        
    }
}

- (BOOL)isPullingFooterUp:(CGPoint)old newPosition:(CGPoint)new{
    if ([self isScrollingUp:old newPosition:new]) {
        
        CGFloat offset;
        if (_scrollView.contentSize.height >= _scrollView.height) {
            offset = _scrollView.height + new.y;
        }
        else{
            offset = _scrollView.contentSize.height + new.y;
        }
        if (offset >= _scrollView.contentSize.height) {
             return YES;
        }
    }
    return NO;
}

- (BOOL)isBouncingFooterDown:(CGPoint)old newPosition:(CGPoint)new{
    // originalOffsetY为原始位置 new.y < - originalOffsetY 表示被下拉位置还未归位
    if ([self isScrollingDown:old newPosition:new]){
        
        CGFloat offset;
        if (_scrollView.contentSize.height >= _scrollView.height) {
            offset = _scrollView.height + new.y;
        }
        else{
            offset = _scrollView.contentSize.height + new.y;
        }
        
        if (offset >= _scrollView.contentSize.height) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isScrollingDown:(CGPoint)old newPosition:(CGPoint)new{
    if (new.y < old.y) {
        return YES;
    }
    return NO;
}

- (BOOL)isScrollingUp:(CGPoint)old newPosition:(CGPoint)new{
    if (new.y > old.y) {
        return YES;
    }
    return NO;
}



- (void)scrollViewContentOffsetDidChanged:(CGFloat)offset{
    
    
    if (self.refreshState == HITRefreshStateTriggering) {
        if (self.triggered) {
            return;
        }
        self.triggered = YES;
        [self handleRevealTrigger];
    }
    
    else if (self.refreshState == HITRefreshStatePulling) {
        [self handlePulling:offset];
    }
    
    else if (self.refreshState == HITRefreshStateReleasing) {
        if (self.released) {
           return;
        }
        [self handleReleasing];
        self.released = YES;
        
    }
}


- (void)handleRevealTrigger{

    [self.interactiveTransitionDelegate reavealTrasitionWillBegin];
    [self startReveal];
}

- (void)handlePulling:(CGFloat)offset{
    CGFloat progress = MAX(0.0, MIN((offset - self.triggerDistance) / (self.maxPullDistance), 1.0));
    self.pullProgress = progress;
    
 
    if (self.pullProgress > 0 ) {
        [self.interactiveTransitionDelegate reavealTransitionUpdateProgress:self.pullProgress];
    }
    else if (self.pullProgress <= 0) {
        [self.interactiveTransitionDelegate reavealTrasitionDidEndAtProgress:0.0f];
    }
}

- (void)handleReleasing{
    [self.interactiveTransitionDelegate reavealTrasitionDidEndAtProgress:self.pullProgress];
}

- (void)startReveal{
    //set current state
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
}

@end
