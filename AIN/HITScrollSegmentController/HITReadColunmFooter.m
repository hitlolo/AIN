//
//  HITReadColunmFooter.m
//  One
//
//  Created by Lolo on 16/5/15.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITReadColunmFooter.h"

@interface HITReadColunmFooter ()
@property(nonatomic,strong)UILabel* promptLabel;
@end

@implementation HITReadColunmFooter

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare{
    _promptLabel = [UILabel new];
    _promptLabel.text = @"拖动至此区域以闲置";
    _promptLabel.font = [UIFont systemFontOfSize:13];
    _promptLabel.textColor = [UIColor lightGrayColor];
    _promptLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_promptLabel];
    
    _promptLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_promptLabel.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor].active = YES;
    [_promptLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [_promptLabel.widthAnchor constraintLessThanOrEqualToAnchor:self.widthAnchor multiplier:1].active = YES;
    
}
@end
