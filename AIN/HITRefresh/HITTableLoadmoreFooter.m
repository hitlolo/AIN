//
//  HITTableRefreshFooter.m
//  AIN
//
//  Created by Lolo on 16/5/27.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITTableLoadmoreFooter.h"

typedef NS_ENUM(NSInteger, HITLoadmoreState) {
    HITLoadmoreStateListening = 0,
    HITLoadmoreStatePulling,
    HITLoadmoreStateReleasing,
    HITLoadmoreStateLoading
};

@interface HITTableLoadmoreFooter ()

@property(nonatomic,assign)HITLoadmoreState loadState;
@property(nonatomic,assign)CGFloat maxPullDistance;
@property(nonatomic,assign)CGFloat originOffsetY;
@property(nonatomic,assign)CGFloat pullProgress;
@property(nonatomic,assign)CGPoint initialOrigin;
@property(nonatomic,assign)CGPoint finalOrigin;

@property(nonatomic,assign)BOOL    releasing;
@property(nonatomic,assign)BOOL    moredata;

@property(nonatomic,strong)UIView* contentView;
@property(nonatomic,strong)UIActivityIndicatorView* indicator;
@property(nonatomic,strong)UILabel* infoLabel;


@property(nonatomic,strong)NSLayoutConstraint* topConstraint;
@property(nonatomic,strong)NSLayoutConstraint* widthConstraint;
@property(nonatomic,strong)NSLayoutConstraint* centerXConstraint;
@end

@implementation HITTableLoadmoreFooter

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

- (instancetype)init{
    CGRect frame = CGRectMake(0, 0, self.screenWidth - 20, 40);
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare{
    
    [self prepareDefault];
    [self prepareSubviews];
    [self prepareConstraints];
}

- (void)prepareDefault{
    
    _loadState = HITLoadmoreStateListening;
    _maxPullDistance = 60.0f;
    _pullProgress = 0.0f;
    _originOffsetY = 0.0f;
    _releasing = NO;
    _moredata = YES;

}

- (void)prepareSubviews{
    
    
    [self.contentView addSubview:self.infoLabel];
    [self.contentView addSubview:self.indicator];
    [self addSubview:self.contentView];

}

- (void)prepareConstraints{
    
    //self.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.indicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.infoLabel.widthAnchor constraintEqualToAnchor:_contentView.widthAnchor multiplier:1.0f].active = YES;
    [self.infoLabel.heightAnchor constraintEqualToAnchor:_contentView.heightAnchor multiplier:1.0f].active = YES;
    [self.infoLabel.centerXAnchor constraintEqualToAnchor:_contentView.centerXAnchor].active = YES;
    [self.infoLabel.centerYAnchor constraintEqualToAnchor:_contentView.centerYAnchor].active = YES;
    
    [self.indicator.widthAnchor constraintEqualToConstant:20.0f].active = YES;
    [self.indicator.heightAnchor constraintEqualToConstant:20.0f].active = YES;
    [self.indicator.centerXAnchor constraintEqualToAnchor:_contentView.centerXAnchor].active = YES;
    [self.indicator.centerYAnchor constraintEqualToAnchor:_contentView.centerYAnchor].active = YES;
    
    
    [self.contentView.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:1.0f constant:-20.0f].active = YES;
    [self.contentView.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:1.0f constant:-8.0f].active = YES;
    [self.contentView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.contentView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    
   
}


#pragma view arrangement

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self.superview sendSubviewToBack:self];
    
    //set initial location
    
    if (self.superview == nil) {
        return;
    }
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.topConstraint =  [self.topAnchor constraintEqualToAnchor:self.superview.bottomAnchor];
    self.widthConstraint = [self.widthAnchor constraintEqualToAnchor:self.superview.widthAnchor constant:-20];
    [self.heightAnchor constraintEqualToConstant:40].active = YES;
    self.centerXConstraint = [self.centerXAnchor constraintEqualToAnchor:self.superview.centerXAnchor];
    
    self.topConstraint.active = YES;
    self.widthConstraint.active = YES;
    self.centerXConstraint.active = YES;

//    self.center = self.superview.center;
//    CGPoint origin = self.origin;
//    origin.y = self.superview.height;
//    self.initialOrigin = origin;
//    self.finalOrigin = CGPointMake(origin.x, origin.y - self.height);
//    self.origin = self.initialOrigin;
//    
//    NSLog(@"%f,.%f",self.superview.height,self.scrollView.height);

}

#pragma mark - Getters & Setter

- (UIView*)contentView{
    if (_contentView == nil) {
        _contentView = [[UIView alloc]init];
        _contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _contentView.layer.borderWidth = 2.0f;
        _contentView.layer.cornerRadius = 5.0f;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UIActivityIndicatorView*)indicator{
    if (_indicator == nil) {
        _indicator = [[UIActivityIndicatorView alloc]init];
        _indicator.hidesWhenStopped = YES;
    }
    return _indicator;
}

- (UILabel*)infoLabel{
    if (_infoLabel == nil) {
        _infoLabel = [[UILabel alloc]init];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.numberOfLines = 1;
        _infoLabel.text = @"上拉加载";
    }
    return _infoLabel;
}

- (void)setMoredata:(BOOL)moredata infoMessage:(NSString*)message{
    _moredata = moredata;
    
    //no more
    if (!_moredata) {
        self.infoLabel.text = message? message:@"没有更多数据";
    }
    else{
        self.infoLabel.text = @"上拉加载";
    }

}

- (void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    self.infoLabel.textColor = _textColor;
    self.contentView.layer.borderColor = _textColor.CGColor;
}


- (void)setScrollView:(UIScrollView *)scrollView{
    if (_scrollView == scrollView) {
        return;
    }
    
    [self removeOffsetObserver];
    
    _scrollView = scrollView;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.alwaysBounceVertical = YES;
    _originOffsetY = _scrollView.contentInset.bottom;
    
    [self addOffsetObserver];
    
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
    
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        
//        if (self.loadState == HITLoadmoreNomoreData) {
//            return;
//        }
        
        if (self.loadState == HITLoadmoreStateLoading) {
            return;
        }
        
        
        CGPoint old = [change[@"old"] CGPointValue];
        CGPoint new = [change[@"new"] CGPointValue];
        
        BOOL isScrollingUp = [self isPullingFooterUp:old newPosition:new];
        BOOL isScrollingDown = [self isBouncingFooterDown:old newPosition:new];
        
        BOOL isPullingUp = isScrollingUp && _scrollView.tracking;
        BOOL isPullingDown = isScrollingDown && _scrollView.tracking;
        
        BOOL isBouncingDown = isScrollingDown && !_scrollView.tracking;
        
        if (isPullingUp || isPullingDown) {
            self.loadState = HITLoadmoreStatePulling;
            self.releasing = NO;
        }
        
        else if (isBouncingDown) {
            self.loadState = HITLoadmoreStateReleasing;
        }
        else{
            self.loadState = HITLoadmoreStateListening;
        }
        
        
        //do
        [self scrollViewContentOffsetDidChanged:change];
        
    }
}


- (BOOL)isPullingFooterUp:(CGPoint)old newPosition:(CGPoint)new{
    if ([self isScrollingUp:old newPosition:new]) {
        if ([self offset:new.y] >= _scrollView.contentSize.height) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isBouncingFooterDown:(CGPoint)old newPosition:(CGPoint)new{
    // originalOffsetY为原始位置 new.y < - originalOffsetY 表示被下拉位置还未归位
    if ([self isScrollingDown:old newPosition:new]){
        
        if ([self offset:new.y]  >= _scrollView.contentSize.height) {
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



- (void)scrollViewContentOffsetDidChanged:(NSDictionary*)change{
    
    CGPoint contentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
    
    if (self.loadState == HITLoadmoreStateLoading) {
        return;
    }
    
    else if (self.loadState == HITLoadmoreStatePulling) {
        [self handlePulling:contentOffset];
    }
    
    else if (self.loadState == HITLoadmoreStateReleasing) {
        [self handleReleasing:contentOffset];
    }
    
}

- (void)handlePulling:(CGPoint)contentOffset{
    
    [self updateAnimationAndLocation:contentOffset];
    
}

- (void)handleReleasing:(CGPoint)contentOffset{
    
    [self updateAnimationAndLocation:contentOffset];
    //releasing
    if (self.releasing) {
        return;
    }
    //initial releasing
    self.releasing = YES;
    
    //if no more data, do not trigger action
    if (!self.moredata) {
        return;
    }
    
    if (self.pullProgress < 1.0f) {
        return;
    }
    if (self.pullProgress >= 1.0f) {
        //即将开始刷新
        [self startLoadmore];
    }
    
}


- (void)updateAnimationAndLocation:(CGPoint)contentOffset{
    //animation progress
    CGFloat scrollOffset = ([self offset:contentOffset.y] - _scrollView.contentSize.height);
    CGFloat offset = scrollOffset - self.originOffsetY;

    CGFloat progress = MAX(0.0, MIN(offset / self.maxPullDistance, 1.0));
    self.pullProgress = progress;
    
    if (progress > 1.0) {
        return;
    }
    //loaction progress
    //CGPoint origin = CGPointMake(0, self.initialOrigin.y - self.height * progress);
//    CGPoint origin = self.origin;
//    
//    //origin.y = self.initialOrigin.y - offset;
//    origin.y = self.initialOrigin.y - self.height * progress;
//    [self setOrigin:origin];
    
    self.topConstraint.constant = - self.height * progress;
}



- (void)startLoadmore{
    
    //set current state
    [self setLoadState:HITLoadmoreStateLoading];
    [self.infoLabel setHidden:YES];
    [self.indicator setHidden:NO];
    [self.indicator startAnimating];
    [self startLoadAction];
    
}

- (void)startLoadAction{
    
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.bottom = self.height + self.originOffsetY;
    
//    CGFloat offsetY = self.scrollView.contentSize.height;
//    offsetY += self.height;
    //fix scrollview's position first
    
    self.topConstraint.constant = - self.height;

    [UIView animateWithDuration:0.2f animations:^{
        
        self.scrollView.contentInset = insets;
        //self.scrollView.contentOffset = CGPointMake(0, offsetY);
        //self.origin = self.finalOrigin;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        //trigger action
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }];
}


- (void)endLoadmoreWithMoreData:(BOOL)moredata infoMessage:(NSString*)message{
    
    //restore states
    self.loadState = HITLoadmoreStateListening;
    [self setMoredata:moredata infoMessage:message];
    [self.infoLabel setHidden:NO];
    [self.indicator stopAnimating];
    

    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.bottom = self.originOffsetY;
    
//    CGFloat offsetY = self.scrollView.contentOffset.y;
//    offsetY -= self.maxPullDistance;
    //reset scrollview states
    self.topConstraint.constant = 0;
    [UIView animateWithDuration:0.3f animations:^{
        [self layoutIfNeeded];
        //self.origin = self.initialOrigin;
        self.scrollView.contentInset = insets;
        //self.scrollView.contentOffset = CGPointMake(0, offsetY);
    } completion:^(BOOL finished) {
        
    }];
}


#pragma mark - helper

- (CGFloat)offset:(CGFloat)contentSizeY{
    CGFloat offset;
    if (_scrollView.contentSize.height >= _scrollView.height) {
        offset = _scrollView.height + contentSizeY;
    }
    else{
        offset = _scrollView.contentSize.height + contentSizeY;
    }
    return offset;
}
@end
