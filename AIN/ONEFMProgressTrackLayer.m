//
//  ONEFMProgressTrackLayer.m
//  One
//
//  Created by Lolo on 16/5/5.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEFMProgressTrackLayer.h"

#define Width        self.frame.size.width
#define Height       self.frame.size.height
#define Center_X     (Width)/2
#define Center_Y     (Height)/2
@implementation ONEFMProgressTrackLayer


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self trackCircle];
    }
    return self;
}

+ (Class)layerClass{
    return [CAShapeLayer class];
}

- (void)trackCircle{
    
    CAShapeLayer* shapeLayer = (CAShapeLayer*)self.layer;
    
    shapeLayer.strokeColor = [UIColor colorWithRed:0.8196 green:0.7333 blue:0.6314 alpha:0.30].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = 6.0f;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapSquare;

    UIBezierPath *curve = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    shapeLayer.path = curve.CGPath;
}
@end
