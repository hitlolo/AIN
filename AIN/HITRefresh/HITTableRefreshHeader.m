//
//  HITTableRefreshHeader.m
//  AIN
//
//  Created by Lolo on 16/5/27.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITTableRefreshHeader.h"
#import "HITArrowView.h"


typedef NS_ENUM(NSInteger, HITRefreshState) {
    HITRefreshStateListening = 0,
    HITRefreshStatePulling,
    HITRefreshStateReleasing,
    HITRefreshStateRefreshing,
};

@interface HITTableRefreshHeader ()

@property(nonatomic,assign)HITRefreshState refreshState;
@property(nonatomic,strong)UIView<HITRefreshView>* refreshView;
@property(nonatomic,assign)CGFloat maxPullDistance;
@property(nonatomic,assign)CGFloat pullProgress;
@property(nonatomic,assign)CGFloat originOffsetY;
@property(nonatomic,assign)CGPoint initialCenter;
@property(nonatomic,assign)CGPoint finalCenter;
@property(nonatomic,strong)CADisplayLink* rollbackTimer;
@property(nonatomic,assign)BOOL releasing;

@end

@implementation HITTableRefreshHeader

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

- (instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, self.screenWidth, 60)];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare{
    _releasing = NO;
    _pullProgress = 0.0f;
    _originOffsetY = 0.0f;
    _maxPullDistance = self.height;
    _refreshState = HITRefreshStateListening;
    _animationTintColor = [UIColor blackColor];
    
    [self addSubview:self.refreshView];
}

#pragma mark - Overrides

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
     [self.superview sendSubviewToBack:self];
}


#pragma mark - Getter & Setter

- (UIView<HITRefreshView>*)refreshView{
    if (_refreshView == nil) {
        _refreshView = [[HITArrowView alloc]initWithFrame:self.bounds];
        ((HITArrowView*)_refreshView).shapeType = HorizontalLineArrowShape;
        ((HITArrowView*)_refreshView).arrowColor = _animationTintColor;
    }
    return _refreshView;
}

- (void)setAnimationTintColor:(UIColor *)animationTintColor{
    _animationTintColor = animationTintColor;
    [((HITArrowView*)self.refreshView)setArrowColor:animationTintColor];
}

- (void)setScrollView:(UIScrollView *)scrollView{
    if (_scrollView == scrollView) {
        return;
    }
    
    [self removeOffsetObserver];
    
    _scrollView = scrollView;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.alwaysBounceVertical = YES;
    _originOffsetY = _scrollView.contentInset.top;
    
    //set initial location
    self.origin = CGPointMake(0, _originOffsetY + _scrollView.origin.y);
    self.initialCenter = CGPointMake(self.center.x, _originOffsetY + _scrollView.origin.y - 5);
    self.finalCenter = CGPointMake(self.initialCenter.x, self.initialCenter.y + self.height/2);
    self.center = self.initialCenter;
    
    [self addOffsetObserver];

}

- (void)setPullProgress:(CGFloat)pullProgress{
    _pullProgress = pullProgress;
    [self.refreshView setProgress:pullProgress];
}


#pragma mark - refresh

- (void)dealloc{
    [self removeOffsetObserver];
}

- (void)cleanUp{
    [self removeOffsetObserver];
}

- (void)addOffsetObserver{
    
    [self.scrollView addObserver:self
                      forKeyPath:@"contentOffset"
                         options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                         context:nil];
}

- (void)removeOffsetObserver{
    //NSLog(@"remove obsever");
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        if (self.refreshState == HITRefreshStateRefreshing) {
            return;
        }
        
        
        CGPoint old = [change[@"old"] CGPointValue];
        CGPoint new = [change[@"new"] CGPointValue];
        
        BOOL pullingDown = [self isPullingHeaderDown:old newPosition:new];
        BOOL bouncingUp = [self isBouncingHeaderUp:old newPosition:new];

        if (pullingDown && _scrollView.tracking) {
            self.refreshState = HITRefreshStatePulling;
            self.releasing = NO;
        }
        
        else if (bouncingUp && _scrollView.tracking) {
            self.refreshState = HITRefreshStatePulling;
            self.releasing = NO;
        }
        
        else if (bouncingUp && !_scrollView.tracking) {
            self.refreshState = HITRefreshStateReleasing;
        }
        else{
            self.refreshState = HITRefreshStateListening;
        }
        
        
        //do
        [self scrollViewContentOffsetDidChanged:change];
        
    }
}

- (BOOL)isPullingHeaderDown:(CGPoint)old newPosition:(CGPoint)new{
    if (new.y <=0 && [self isScrollingDown:old newPosition:new]) {
        return YES;
    }
    return NO;
}

- (BOOL)isBouncingHeaderUp:(CGPoint)old newPosition:(CGPoint)new{
    // originalOffsetY为原始位置 new.y < - originalOffsetY 表示被下拉位置还未归位
    if ([self isScrollingUp:old newPosition:new] && new.y < - self.originOffsetY){
        return YES;
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



- (void)scrollViewContentOffsetDidChanged:(NSDictionary*)change{
    
    CGPoint contentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];

    if (self.refreshState == HITRefreshStateRefreshing) {
        return;
    }
    
    if (self.refreshState == HITRefreshStatePulling) {
        [self handlePulling:contentOffset];
    }
    
    if (self.refreshState == HITRefreshStateReleasing) {
        [self handleReleasing:contentOffset];
    }
    
}

- (void)handlePulling:(CGPoint)contentOffset{
    
    [self updateAnimationAndLocation:contentOffset];
    
    if (self.pullProgress >= 1.0) {
        CGFloat diff = fabs(self.scrollView.contentOffset.y + self.originOffsetY) - self.maxPullDistance ;
        self.transform = CGAffineTransformMakeRotation(M_PI * (diff/180));
    }
}

- (void)handleReleasing:(CGPoint)contentOffset{
    
    [self updateAnimationAndLocation:contentOffset];
    //releasing
    if (self.releasing) {
        return;
    }
    
    //initial releasing
    self.releasing = YES;
    
    if (self.pullProgress < 0.95f) {
        self.transform = CGAffineTransformIdentity;
    }
    if (self.pullProgress >= 0.95f) {
        //即将开始刷新
        [self startRefresh];
    }

}


- (void)updateAnimationAndLocation:(CGPoint)contentOffset{

    BOOL isIdentity = CGAffineTransformIsIdentity(self.transform);
    if (!isIdentity) {
        self.transform = CGAffineTransformIdentity;
    }
    //animation progress
    CGFloat progress = MAX(0.0, MIN(fabs(contentOffset.y + _originOffsetY) / self.maxPullDistance, 1.0));
    
    self.pullProgress = progress;
    
    //loaction progress
    CGPoint center = CGPointMake(self.initialCenter.x, self.initialCenter.y + self.refreshView.height/2 * progress);
    [self setCenter:center];
}




- (void)startRefresh{

    //set current state
    [self setRefreshState:HITRefreshStateRefreshing];
    [self startRefreshAction];

}

- (void)startRefreshAction{

    [self.refreshView startAnimation];
    
    
    //fix scrollview's position first
    [UIView animateWithDuration:0.2f animations:^{
        
        self.scrollView.contentInset = UIEdgeInsetsMake(self.maxPullDistance + self.originOffsetY, 0, 0, 0);
        self.scrollView.contentOffset = CGPointMake(0, -self.maxPullDistance - self.originOffsetY);
        [self setCenter:_finalCenter];
    } completion:^(BOOL finished) {
        //trigger action
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }];
}


- (void)endRefresh{
    
    //restore states
    [self.refreshView endAnimation];
    self.refreshState = HITRefreshStateListening;
    
    
    self.transform = CGAffineTransformIdentity;
    [self progressRollback];
    
    //CGPoint offset = self.scrollView.contentOffset;
    //reset scrollview states
    [UIView animateWithDuration:0.3f animations:^{
        
        //self.refreshView.alpha = 0.0f;
        self.scrollView.contentInset = UIEdgeInsetsMake(self.originOffsetY, 0, 0, 0);
        //self.scrollView.contentOffset = CGPointMake(0, offset.y + self.originOffsetY);
    } completion:^(BOOL finished) {
        self.refreshView.alpha = 1.0f;
        
    }];
    
   
    //progress back
 
}


static NSString* const kAnimationNameRollBack = @"rollingback";

- (void)progressRollback{
    
    CABasicAnimation* rollbackAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    rollbackAnimation.fromValue = [NSValue valueWithCGPoint:self.center];
    rollbackAnimation.toValue = [NSValue valueWithCGPoint:self.initialCenter];
    rollbackAnimation.duration = 0.3f;
    rollbackAnimation.delegate = self;
    rollbackAnimation.removedOnCompletion = YES;
    [rollbackAnimation setValue:kAnimationNameRollBack forKey:@"name"];
    [self.layer addAnimation:rollbackAnimation forKey:kAnimationNameRollBack];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.layer.position = self.initialCenter;
    [CATransaction commit];
}

- (void)animationDidStart:(CAAnimation *)anim{
    
    self.rollbackTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(progressBack)];
    [self.rollbackTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    

    [self.rollbackTimer invalidate];
    self.rollbackTimer = nil;

}

- (void)progressBack{
    
    if (self.layer.presentationLayer) {
        CGPoint origin = [self.layer.presentationLayer position];
        CGFloat progress;
        progress = (origin.y - self.initialCenter.y) / (self.maxPullDistance/2);
        [self.refreshView setProgress:progress];
        
        //NSLog(@"%f",progress);
        //    self.pullProgress = progress;
        
        //loaction progress
        //CGPoint center = CGPointMake(self.initialCenter.x, self.initialCenter.y + self.refreshView.height/2 * progress);
        //[self setCenter:center];
    }
    
   

}


@end
