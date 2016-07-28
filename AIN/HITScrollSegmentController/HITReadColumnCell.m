//
//  HITReadColumnTagCell.m
//  One
//
//  Created by Lolo on 16/5/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITReadColumnCell.h"
#import "HITReadColumn.h"
@interface HITReadColumnCell (){
    BOOL constraintsReady;
}

@property(nonatomic,strong)UILabel* titleLabel;

@end
@implementation HITReadColumnCell

//- (instancetype)init{
//    self = [super init];
//    if (self) {
//        [self prepare];
//    }
//    return self;
//}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare{

    constraintsReady = NO;
    _titleLabel = [UILabel new];
    _titleLabel.textColor = [UIColor lightGrayColor];
    _titleLabel.font = [UIFont systemFontOfSize:13];
    _titleLabel.minimumScaleFactor = 0.5;
    [self.contentView addSubview:_titleLabel];
    
    self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.contentView.layer.borderWidth = 1.0f;
    self.contentView.layer.cornerRadius = 2.0f;
    self.contentView.layer.masksToBounds = YES;
    
    [self setNeedsUpdateConstraints];
    
}


- (void)updateConstraints{
    if (!constraintsReady) {
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_titleLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
        [_titleLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;

        constraintsReady = YES;
    }
    
    [super updateConstraints];
}

- (void)setColumn:(HITReadColumn *)column{
    _titleLabel.text = column.title;
    [_titleLabel sizeToFit];
}
@end
