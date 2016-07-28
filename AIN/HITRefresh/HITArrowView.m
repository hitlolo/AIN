//
//  HITAnimationView.m
//  HITRefreshView
//
//  Created by Lolo on 15/12/6.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import "HITArrowView.h"
#import "HITArrowShapeLayer.h"

@implementation HITArrowView

+ (Class)layerClass{
    return [HITArrowShapeLayer class];
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)prepare{
    self.backgroundColor = [UIColor clearColor];
    
}

- (instancetype)init{
    self = [super init];
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

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}


- (void)setProgress:(CGFloat)progress{
    if (progress > 1.0f) {
        return;
    }
    //[shapeLayer setAffineTransform:CGAffineTransformMakeRotation(M_PI/2 * (progress))];
    
    _progress = progress;
    HITArrowShapeLayer* shapeLayer = (HITArrowShapeLayer*)self.layer;
    shapeLayer.progress = progress;
    
}

- (void)setShapeType:(ShapeType)shapeType{
    _shapeType = shapeType;
    HITArrowShapeLayer* shapeLayer = (HITArrowShapeLayer*)self.layer;
    [shapeLayer setShapeType:shapeType];
}

- (void)setArrowColor:(UIColor *)arrowColor{
    _arrowColor = arrowColor;
    HITArrowShapeLayer* shapeLayer = (HITArrowShapeLayer*)self.layer;
    shapeLayer.lineColor = arrowColor;
}

- (void)startAnimation{
    if (self.progress != 1.0f) {
        self.progress = 1.0f;
    }
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI * 2.0);
    rotationAnimation.duration = 1.0f;
    rotationAnimation.autoreverses = NO;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.layer addAnimation:rotationAnimation forKey:@"spinningAnimation"];
}

- (void)endAnimation{
    [self.layer removeAnimationForKey:@"spinningAnimation"];
}


@end
