//
//  HITScrollSegmentView.m
//  HITScrollListController
//
//  Created by Lolo on 16/5/12.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITScrollSegmentView.h"
#import "HITScrollSegmentItem.h"
#import "HITReadColumnProvider.h"

@interface HITScrollSegmentView ()

@property(nonatomic,strong)UIScrollView* segmentScroll;
@property(nonatomic,strong)UIStackView* segmentStack;
@property(nonatomic,strong)UIButton* expandButton;
@property(nonatomic,strong)UIView* boundaryLine;

@property(nonatomic,assign)NSInteger highLightedIndex;
@end

@implementation HITScrollSegmentView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self prepare];
        [self prepareConstraints];
    }
    return self;
}


- (void)prepare{
    
    _titleDefaultColor = [UIColor lightGrayColor];
    _titleHighlightedColor = [UIColor colorWithRed:0.1802 green:0.687 blue:0.9073 alpha:1.0];

    _highLightedIndex = -1;
    
    [self addSubview:self.segmentScroll];
    //[self.segmentScroll addSubview:self.segmentStack];
    [self addSubview:self.expandButton];
    [self addSubview:self.boundaryLine];
    
}

- (void)prepareConstraints{
    //self.translatesAutoresizingMaskIntoConstraints = NO;
    
    _segmentScroll.translatesAutoresizingMaskIntoConstraints = NO;
    //        [_segmentScroll.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    //        [_segmentScroll.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [_segmentScroll.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:1.0].active = YES;
    [_segmentScroll.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_segmentScroll.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-50].active = YES;
    [_segmentScroll.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    _segmentStack.translatesAutoresizingMaskIntoConstraints = NO;
    [_segmentStack.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
//    [_segmentStack.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
//    [_segmentStack.widthAnchor constraintEqualToAnchor:_segmentScroll.widthAnchor multiplier:1.0f].active = YES;
//    [_segmentStack.heightAnchor constraintEqualToAnchor:_segmentScroll.heightAnchor multiplier:1.0].active = YES;
    [_segmentStack.leadingAnchor constraintEqualToAnchor:_segmentScroll.leadingAnchor constant:8].active = YES;
    [_segmentStack.trailingAnchor constraintLessThanOrEqualToAnchor:_segmentScroll.trailingAnchor constant:-8].active = YES;
//    [_segmentStack.centerXAnchor constraintEqualToAnchor:_segmentScroll.centerXAnchor].active = YES;
//    [_segmentStack.centerYAnchor constraintEqualToAnchor:_segmentScroll.centerYAnchor].active = YES;
    //[_segmentStack.widthAnchor constraintGreaterThanOrEqualToAnchor:self.widthAnchor multiplier:1.0].active = YES;
    
    _expandButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_expandButton.widthAnchor constraintEqualToConstant:50.0].active = YES;
    [_expandButton.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    [_expandButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [_expandButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    
    _boundaryLine.translatesAutoresizingMaskIntoConstraints = NO;
    [_boundaryLine.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:1.0].active = YES;
    [_boundaryLine.heightAnchor constraintEqualToConstant:0.5f].active = YES;
    [_boundaryLine.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
}

#pragma mark - Getter & Setter

- (UIScrollView*)segmentScroll{
    if (_segmentScroll == nil) {
        
        _segmentScroll = [UIScrollView new];
        _segmentScroll.showsHorizontalScrollIndicator = NO;
        _segmentScroll.showsVerticalScrollIndicator = NO;
        _segmentScroll.scrollsToTop = NO;
        [_segmentScroll addSubview:self.segmentStack];
    }
    return _segmentScroll;
}

- (UIStackView*)segmentStack{
    if (_segmentStack == nil) {
        _segmentStack = [UIStackView new];
        _segmentStack.axis = UILayoutConstraintAxisHorizontal;
        _segmentStack.alignment = UIStackViewAlignmentCenter;
        _segmentStack.distribution = UIStackViewDistributionFillEqually;
        _segmentStack.spacing = 20.0f;
        _segmentStack.layoutMarginsRelativeArrangement = YES;
        _segmentStack.layoutMargins = UIEdgeInsetsMake(8 , 8, 8, 8);
    }
    return _segmentStack;
}

- (UIButton*)expandButton{
    if (_expandButton == nil) {
        _expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_expandButton addTarget:self action:@selector(expandButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_expandButton setImage:[UIImage imageNamed:@"nav_share_btn_normal"] forState:UIControlStateNormal];
    }
    return _expandButton;
}

- (UIView*)boundaryLine{
    if (_boundaryLine == nil) {
        _boundaryLine = [[UIView alloc]init];
        _boundaryLine.backgroundColor = [UIColor colorWithRed:0.6667 green:0.6667 blue:0.6667 alpha:0.5];
    }
    return _boundaryLine;
}



- (void)setHighLightedIndex:(NSInteger)index{
    
    NSArray* segmentItems = [_segmentStack arrangedSubviews];
    
    HITScrollSegmentItem* newItem = [segmentItems objectAtIndex:index];
    HITScrollSegmentItem* oldItem = nil;
    
    CGPoint scale = [newItem scaleFactor];

    if (_highLightedIndex != -1 && _highLightedIndex <= [segmentItems count] - 1) {
        oldItem = [segmentItems objectAtIndex:_highLightedIndex];
    }
    
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        oldItem.textColor = _titleDefaultColor;
        newItem.textColor = _titleHighlightedColor;
        [oldItem setHighlighted:NO];
        [newItem setHighlighted:YES];
        oldItem.transform = CGAffineTransformMakeScale(1.0, 1.0);
        newItem.transform = CGAffineTransformMakeScale(scale.x, scale.y);
    } completion:^(BOOL finished) {
//        newItem.font = [newItem highlightedFont];
//        oldItem.font = [oldItem defaultFont];
//        [oldItem setHighlighted:NO];
//        [newItem setHighlighted:YES];
//        oldItem.transform = CGAffineTransformMakeScale(1.0, 1.0);
//        newItem.transform = CGAffineTransformMakeScale(1.0, 1.0);
        if (finished) {
            CGPoint center = [_segmentScroll convertPoint:newItem.center toView:_segmentScroll];
            CGPoint offset = [_segmentScroll contentOffset];
            CGSize size = [_segmentScroll contentSize];
            if (center.x > _segmentScroll.center.x && (size.width - center.x > _segmentScroll.center.x)) {
                offset.x = center.x - _segmentScroll.center.x;
                [_segmentScroll setContentOffset:offset animated:YES];
            }
            else if (center.x < _segmentScroll.center.x){
                offset.x = 0;
                [_segmentScroll setContentOffset:offset animated:YES];
            }
            else if ((size.width - center.x < _segmentScroll.center.x) && _segmentStack.bounds.size.width > _segmentScroll.bounds.size.width){
                offset.x = size.width - _segmentScroll.bounds.size.width;
                [_segmentScroll setContentOffset:offset animated:YES];
            }
        }
        
    }];
    
    
    _highLightedIndex = index;
 
}

- (void)highLightSegmentAtIndex:(NSInteger)index{
    
    NSArray* segmentItems = [_segmentStack arrangedSubviews];
    if (index > [segmentItems count] - 1 || index < 0 ) {
        return;
    }
    [self setHighLightedIndex:index];
    
}


- (void)reloadData{

    NSArray* oldSegmentItem = [self.segmentStack arrangedSubviews];
    [oldSegmentItem enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.segmentStack removeArrangedSubview:obj];
        [obj removeFromSuperview];
        obj = nil;
    }];
    
    [self loadSegments];
}

- (void)loadSegments{

    if (self.segmentDatasource) {
        NSArray* segmentTitles = [self.segmentDatasource segmentTitlesForScrollSegmentView];
        [segmentTitles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id<HITReadColumn> column = obj;
            NSString* title = [column title];
            HITScrollSegmentItem* segmentItem = [self createSegmentItem:title atIndex:idx];
            [self.segmentStack addArrangedSubview:segmentItem];
        }];
    }
    
}

- (HITScrollSegmentItem*)createSegmentItem:(NSString*)title atIndex:(NSInteger)index{
    HITScrollSegmentItem* item = [HITScrollSegmentItem new];
    item.text = title;
    item.textColor = _titleDefaultColor;
    item.highlightedTextColor = _titleHighlightedColor;
    item.index = index;
    [item sizeToFit];
    
    UITapGestureRecognizer* tap = [UITapGestureRecognizer new];
    tap.numberOfTapsRequired = 1;
    [tap addTarget:self action:@selector(segmentSelected:)];
    
    [item addGestureRecognizer:tap];
    [item setUserInteractionEnabled:YES];
    return item;
}

- (void)segmentSelected:(UITapGestureRecognizer*)tap{
    
    HITScrollSegmentItem* item = (HITScrollSegmentItem*)tap.view;
    if (self.segmentDelegate) {
        [self.segmentDelegate segmentItemDidSelected:item.index];
    }
}

- (void)expandButtonClicked:(UIButton*)sender{
    if (self.segmentDelegate) {
        [self.segmentDelegate segmentEditDidSelected:sender];
    }
}

@end
