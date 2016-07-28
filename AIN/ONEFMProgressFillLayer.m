//
//  ONEFMProgressLayer.m
//  One
//
//  Created by Lolo on 16/5/5.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEFMProgressFillLayer.h"
#import "ONEFMProgressTrackLayer.h"

#define Width        self.frame.size.width
#define Height       self.frame.size.height
#define Center_X     (Width)/2
#define Center_Y     (Height)/2

@interface ONEFMProgressFillLayer : CAShapeLayer
@property(nonatomic,assign)CGFloat progress;
@end

@implementation ONEFMProgressFillLayer

- (instancetype)init{
    self = [super init];
    if (self) {
        //default line color
        
        self.strokeColor = globalControlTintColor.CGColor;
        self.fillColor = [UIColor clearColor].CGColor;
        self.lineWidth = 6.0f;
        self.lineJoin = kCALineJoinRound;
        self.lineCap = kCALineCapRound;
        
    }
    return self;
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    
    [self drawCircle];
}


- (void)drawCircle{
    
    CGFloat offsetAngle = 2 * M_PI * self.progress;
    UIBezierPath* backgroundPath = [UIBezierPath bezierPath];
    CGFloat radius = Width/2;
    [backgroundPath addArcWithCenter:CGPointMake(Center_X,Center_Y) radius:radius startAngle:-M_PI/2 endAngle:-M_PI/2+offsetAngle clockwise:YES];
    
    self.path = backgroundPath.CGPath;
    [self setNeedsDisplay];
}


@end

@implementation ONEFMProgressFillView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
 
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+ (Class)layerClass{
    return [ONEFMProgressFillLayer class];
}

- (void)setProgress:(CGFloat)progress{
    ONEFMProgressFillLayer* fillLayer = (ONEFMProgressFillLayer*)self.layer;
    [fillLayer setProgress:progress];
}

@end
