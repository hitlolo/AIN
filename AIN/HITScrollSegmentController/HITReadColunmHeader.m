//
//  HITReadColunmHeader.m
//  One
//
//  Created by Lolo on 16/5/15.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITReadColunmHeader.h"

@interface HITReadColunmHeader ()
@property(nonatomic,strong)UILabel* promptLabel;
@end

@implementation HITReadColunmHeader

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare{
    _promptLabel = [UILabel new];
    _promptLabel.font = [UIFont systemFontOfSize:13];
    _promptLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_promptLabel];
    
    _promptLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_promptLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8].active = YES;
    [_promptLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [_promptLabel.widthAnchor constraintLessThanOrEqualToAnchor:self.widthAnchor multiplier:1].active = YES;
    
}

- (void)setPrompt:(NSString *)prompt{
    _promptLabel.text = prompt;
}
@end
