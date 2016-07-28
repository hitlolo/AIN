//
//  AINCarouselView.m
//  AIN
//
//  Created by Lolo on 16/5/25.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINCarouselView.h"

@interface AINCarouselView ()
<UIScrollViewDelegate>

@property(nonatomic,strong)UIPageControl* pageControl;
@property(nonatomic,strong)UIScrollView* scrollView;
@property(nonatomic,strong)UIImageView* placeHolder;
@property(nonatomic,strong)UITapGestureRecognizer* tapGesture;


@property(nonatomic,strong)NSTimer* timer;

@end

@implementation AINCarouselView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self ) {
        [self prepare];
    }
    return self;
}

- (void)dealloc{
    [self stopCarouseling];
}

- (void)prepare{
    
    _numberOfPages = 0;
    _currentIndex = 0;
    
    [self prepareSubviews];
    [self prepareConstraints];
}

- (void)prepareSubviews{
    
    [self setClipsToBounds:YES];
    [self addSubview:self.scrollView];
    [self addSubview:self.pageControl];

}

- (void)prepareConstraints{
    
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_scrollView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [_scrollView.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    [_scrollView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [_scrollView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    [_pageControl.centerXAnchor constraintEqualToAnchor:_scrollView.centerXAnchor].active = YES;
    [_pageControl.bottomAnchor constraintEqualToAnchor:_scrollView.bottomAnchor constant:8].active = YES;
}

- (void)reloadData{
    
    
    [self stopCarouseling];
    
    self.numberOfPages = [self.datasource numberOfItemsForCarousel:self];
    if (self.numberOfPages == 0) {
        [self.tapGesture setEnabled:NO];
        return;
    }
    
    [self.placeHolder removeFromSuperview];
    self.pageControl.numberOfPages = self.numberOfPages;
    self.pageControl.currentPage = 0;
    self.tapGesture.enabled = YES;
    for (int i = 0; i < self.numberOfPages; i++) {
        
        UIView* view = [self viewForIndex:i];
        [view setFrame:CGRectMake(i * self.width, 0, self.width, self.height)];
        view.userInteractionEnabled = YES;
        [self.scrollView addSubview:view];
    }
    [self.scrollView setContentSize:CGSizeMake(self.width * self.numberOfPages, self.height)];
    [self startCarouseling];
}


- (UIView*)viewForIndex:(NSInteger)index{
    UIView* view = [self.datasource viewForIndex:index forCarousel:self];
    return view;
}

#pragma mark- Setter & Getter

- (UIPageControl*)pageControl{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.numberOfPages = 1;
        _pageControl.currentPage = 0;
        _pageControl.userInteractionEnabled = NO;
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.1922 green:0.7137 blue:0.9373 alpha:1.0];
        
    }
    return _pageControl;
}

- (UIScrollView*)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc]init];
        [_scrollView addSubview:self.placeHolder];
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        [_scrollView addGestureRecognizer:self.tapGesture];
    }
    return _scrollView;
}

- (UIImageView*)placeHolder{
    if (_placeHolder == nil) {
        UIImage* holderImage = one_placeHolder_column;
        _placeHolder = [[UIImageView alloc]initWithImage:holderImage];
        _placeHolder.frame = self.bounds;
    }
    return _placeHolder;
}


- (UITapGestureRecognizer*)tapGesture{
    if (_tapGesture == nil) {
        _tapGesture = [[UITapGestureRecognizer alloc]init];
        _tapGesture.numberOfTapsRequired = 1;
        //_tapGesture.delegate = self;
        [_tapGesture addTarget:self action:@selector(itemTapped:)];
    }
    return _tapGesture;
}


#pragma mark - scrollview delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index =  scrollView.contentOffset.x/scrollView.width;
    self.currentIndex = index;
    self.pageControl.currentPage = index;
}


#pragma mark - action

- (void)itemTapped:(UITapGestureRecognizer*)tap{
    [self.delegate carousel:self didSelectedIndex:self.currentIndex];
}

- (void)scrollToPage:(NSInteger)index{
    
    if (index == self.currentIndex) {
        return;
    }
    if (index > self.numberOfPages || index < 0) {
        return;
    }
    
    CGPoint offset = CGPointMake(self.width*index, 0);
    [self.scrollView setContentOffset: offset animated:YES];
    self.currentIndex = index;
    self.pageControl.currentPage = index;
}


- (void)startCarouseling{
    
    if (self.numberOfPages == 0) {
        return;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0f
                                              target:self
                                            selector:@selector(carouseling)
                                            userInfo:nil
                                             repeats:YES];

}

- (void)stopCarouseling{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)carouseling{
  
    NSInteger page = (self.currentIndex + 1) >= self.numberOfPages?0:(self.currentIndex+1);
    [self scrollToPage:page];
}



@end
