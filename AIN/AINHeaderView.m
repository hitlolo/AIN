//
//  AINHeaderView.m
//  AIN
//
//  Created by Lolo on 16/7/10.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINHeaderView.h"


@interface AINHeaderView ()
@property(strong,nonatomic)NSString* message;
@property(strong,nonatomic)UIView* decorationView;
@property(strong,nonatomic,readwrite)UILabel* messageLabel;
@end

@implementation AINHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self prepare];
        [self prepareConstriants];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self prepare];
        [self prepareConstriants];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
        [self prepareConstriants];
    }
    return self;
}

- (void)prepare{
    
    self.backgroundView.alpha = 0.8;
    [self.contentView addSubview:self.decorationView];
    [self.contentView addSubview:self.messageLabel];
}

- (void)prepareConstriants{
    
    self.decorationView.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.decorationView.widthAnchor constraintEqualToConstant:2.0f].active = YES;
    [self.decorationView.heightAnchor constraintEqualToAnchor:self.contentView.heightAnchor].active = YES;
    [self.decorationView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
    [self.decorationView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
    
    [self.messageLabel.heightAnchor constraintEqualToAnchor:self.contentView.heightAnchor multiplier:1.0f].active = YES;
    [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.decorationView.trailingAnchor constant:8].active = YES;
    [self.messageLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
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

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    self.backgroundView.backgroundColor = backgroundColor;
    [self.contentView setBackgroundColor:backgroundColor];
}


@end
