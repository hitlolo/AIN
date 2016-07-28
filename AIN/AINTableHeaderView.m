//
//  AINCommentHeader.m
//  AIN
//
//  Created by Lolo on 16/6/21.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINTableHeaderView.h"


@interface AINTableHeaderView ()
@property(strong,nonatomic)NSString* message;
@property(strong,nonatomic)UIView* decorationView;
@property(strong,nonatomic,readwrite)UILabel* messageLabel;
@end

@implementation AINTableHeaderView


- (instancetype)initWithMessage:(NSString*)message{
    
    self = [super initWithFrame:CGRectMake(0, 0, 180, 24)];
    if (self) {
        _message = message;
        [self prepare];
        [self prepareConstriants];
    }
    return self;
    
}

- (instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, 180, 24)];
    if (self) {
        [self prepare];
        [self prepareConstriants];

    }
    return self;
}

- (void)prepare{
    
    self.alpha = 0.8;
    [self addSubview:self.decorationView];
    [self addSubview:self.messageLabel];
}

- (void)prepareConstriants{
    
    self.decorationView.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.decorationView.widthAnchor constraintEqualToConstant:2.0f].active = YES;
    [self.decorationView.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    [self.decorationView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.decorationView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    [self.messageLabel.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:1.0f].active = YES;
    [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.decorationView.trailingAnchor constant:8].active = YES;
    [self.messageLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
}


- (UIView*)decorationView{
    if (_decorationView == nil) {
        _decorationView = [[UIView alloc]init];
        _decorationView.backgroundColor = [UIColor colorWithRed:0.1922 green:0.7137 blue:0.9373 alpha:1.0];
    }
    return _decorationView;
}

- (UILabel*)messageLabel{
    if (_messageLabel == nil) {
        _messageLabel = [[UILabel alloc]init];
        _messageLabel.text = self.message;
        _messageLabel.font = [UIFont systemFontOfSize:15];
        _messageLabel.minimumScaleFactor = 0.5f;
    }
    
    return _messageLabel;
}

- (void)setMessage:(NSString*)message{
    _message = message;
    self.messageLabel.text = _message;
}

- (void)setTextColor:(UIColor *)textColor{
    self.messageLabel.textColor = textColor;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
