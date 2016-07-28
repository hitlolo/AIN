//
//  ONEFMProgressView.m
//  One
//
//  Created by Lolo on 16/5/5.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEFMProgressView.h"
#import "ONEFMProgressFillLayer.h"
#import "ONEFMProgressTrackLayer.h"

@interface ONEFMProgressView ()

@property(nonatomic,strong)ONEFMProgressFillView* fillView;
@end

@implementation ONEFMProgressView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    frame.size.width += 6;
    frame.size.height += 6;
    frame.origin = CGPointMake(-3, -3);
    ONEFMProgressTrackLayer *track = [[ONEFMProgressTrackLayer alloc]initWithFrame:frame];
    [self addSubview:track];
    
    _fillView = [[ONEFMProgressFillView alloc]initWithFrame:frame];
    [self addSubview:_fillView];
}

- (void)setProgress:(CGFloat)progress{
    
    [_fillView setProgress:progress];
}
@end
