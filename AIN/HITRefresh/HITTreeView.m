//
//  HITTreeView.m
//  One
//
//  Created by Lolo on 16/4/18.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITTreeView.h"

@implementation HITTreeView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare{
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSInteger animationImageCount = 12;
    for (int i = 1; i < animationImageCount; i++) {
        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"loading_%d", i]]];
    }
    
    for (int i = 12; i > 1; i--) {
        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"loading_%d", i]]];
    }
    
    self.animationImages = images;
    self.animationDuration = 2.0f;
    self.animationRepeatCount = CGFLOAT_MAX;
    
    self.image = self.animationImages[0];
}


- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    NSInteger index = ceilf(progress*10);
    if (index >=0 && index <= [self.animationImages count]) {
         self.image = self.animationImages[index+1];
    }
}

- (void)startAnimation{
    [self startAnimating];
}

- (void)endAnimation{
    [self stopAnimating];
}

@end
