//
//  HITMarqueeLabel.m
//  AIN
//
//  Created by Lolo on 16/7/9.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITMarqueeLabel.h"

@interface HITMarqueeLabel (){
    NSInteger marqueeInterval;
}
@property(strong,nonatomic)UILabel* initialLabel;
//@property(strong,nonatomic)UILabel* followedLabel;
@property(strong,nonatomic)NSTimer* marqueeTimer;
@end

@implementation HITMarqueeLabel

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)dealloc{
    [self.marqueeTimer invalidate];
    self.marqueeTimer = nil;
}

- (void)prepare{
    
    marqueeInterval = 20.0f;
    [self.marqueeTimer setFireDate:[NSDate distantFuture]];
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    [self prepareSubviews];
    [self prepareConstraints];
    
}

- (void)prepareSubviews{
    [self addSubview:self.initialLabel];
    //[self addSubview:self.followedLabel];
}

- (void)prepareConstraints{
    
    self.initialLabel.translatesAutoresizingMaskIntoConstraints = NO;
   // self.followedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.initialLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.initialLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    //[self.followedLabel.leadingAnchor constraintEqualToAnchor:self.initialLabel.trailingAnchor constant:8].active = YES;
    //[self.followedLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
}


#pragma mark - Getter& Setter

- (NSTimer*)marqueeTimer{
    if (_marqueeTimer == nil) {
        _marqueeTimer = [NSTimer scheduledTimerWithTimeInterval:marqueeInterval
                                                             target:self
                                                           selector:@selector(marquee)
                                                           userInfo:nil
                                                            repeats:YES];
    }
    return _marqueeTimer;
}

- (UILabel*)initialLabel{
    if (_initialLabel == nil) {
        _initialLabel = [UILabel new];
        _initialLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _initialLabel;
}

//- (UILabel*)followedLabel{
//    if (_followedLabel == nil) {
//        _followedLabel = [UILabel new];
//        _followedLabel.textAlignment = NSTextAlignmentCenter;
//    }
//    return _followedLabel;
//}


- (void)setText:(NSString *)text{
    _text = text;
    self.initialLabel.text = text;
   // self.followedLabel.text = text;
    
    [self.initialLabel sizeToFit];
    //[self.followedLabel sizeToFit];
    
    if (self.initialLabel.width < self.width) {
        [self stopAnimation];
        //[self.followedLabel setHidden:YES];
    }
    else{
        //[self.followedLabel setHidden:NO];

        [self setContentSize:CGSizeMake(self.initialLabel.width, self.height)];
        [self startAnimation];
    }
    

}

- (void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    self.initialLabel.textColor = textColor;
    //self.followedLabel.textColor = textColor;
}

- (void)setTextFont:(UIFont *)textFont{
    _textFont = textFont;
    self.initialLabel.font = textFont;
    //self.followedLabel.font = textFont;
}


#pragma mark - Marqueel

- (BOOL)isAnimation{
    return [self.marqueeTimer isValid];
}

- (void)startAnimation{
    [self.marqueeTimer setFireDate:[NSDate date]];
}

- (void)stopAnimation{
    [self setContentOffset:CGPointMake(0, 0)];
    [self.marqueeTimer setFireDate:[NSDate distantFuture]];
}

- (void)marquee{
    
    
    CGPoint offset = CGPointMake(self.contentSize.width - self.width, 0);
    [UIView animateWithDuration:4.0f animations:^{
        [self setContentOffset:offset];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:4.0f animations:^{
            [self setContentOffset:CGPointZero];
        }];
    }];
}
@end

