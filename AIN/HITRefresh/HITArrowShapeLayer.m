//
//  HITShapeLayer.m
//  UIViewTest
//
//  Created by Lolo on 16/4/13.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITArrowShapeLayer.h"

#define Radius       8
#define Lenght       40
#define Width        self.frame.size.width
#define Height       self.frame.size.height
#define Center_X     (Width)/2
#define Center_Y     (Height)/2
#define Arrow_Degree M_PI/6
#define Arrow_Length 4
#define Line_Color   [UIColor colorWithRed:209.0/255 green:187.0/255 blue:161.0/255 alpha:1.0f]

@implementation HITArrowShapeLayer

- (instancetype)init{
    self = [super init];
    if (self) {
        _lineColor = Line_Color;
        _shapeType = TwoArrowShape;
        
        self.strokeColor = self.lineColor.CGColor;
        self.fillColor = [UIColor clearColor].CGColor;
        self.lineWidth = 2.0f;
        self.lineJoin = kCALineJoinRound;
        self.lineCap = kCALineCapRound;

    }
    return self;
}

- (UIBezierPath*)oneArrowPath{
    CGFloat offsetAngle = (2*(M_PI*9/10) * self.progress);
    
    UIBezierPath *curve = [UIBezierPath bezierPath];
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    // draw curve
    
    CGPoint pointA = CGPointMake(Center_X - Radius, Center_Y);
    
    [curve moveToPoint:pointA];
    [curve addArcWithCenter:CGPointMake(Center_X,Center_Y) radius:Radius startAngle:M_PI endAngle:M_PI + offsetAngle clockwise:YES];
    
    CGPoint arrowPointA = curve.currentPoint;
    CGPoint arrowPointB = CGPointMake(arrowPointA.x - Arrow_Length * sinf(Arrow_Degree + offsetAngle),arrowPointA.y + Arrow_Length * cosf(Arrow_Degree + offsetAngle));
    
    CGPoint arrowPointC = CGPointMake(arrowPointA.x + Arrow_Length * cosf(Arrow_Degree + offsetAngle),arrowPointA.y + Arrow_Length * sinf(Arrow_Degree + offsetAngle));
    
    [arrowPath moveToPoint:arrowPointA];
    [arrowPath addLineToPoint:arrowPointB];
    [arrowPath moveToPoint:arrowPointA];
    [arrowPath addLineToPoint:arrowPointC];
    [curve appendPath:arrowPath];
    
    
    return curve;

}


- (UIBezierPath*)twoArrowPath{
   
    CGFloat offsetAngle = ((M_PI*8/10) * self.progress);
    UIBezierPath* curve = [UIBezierPath bezierPath];
    
    UIBezierPath *lineOne = [UIBezierPath bezierPath];
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    /**
     *  draw left line
     */
    // draw curve
    
    CGPoint pointA = CGPointMake(Center_X - Radius, Center_Y);
    
    
    [lineOne moveToPoint:pointA];
    [lineOne addArcWithCenter:CGPointMake(Center_X,Center_Y) radius:Radius startAngle:M_PI endAngle:M_PI + offsetAngle clockwise:YES];
    
    CGPoint arrowPointA = lineOne.currentPoint;
    CGPoint arrowPointB = CGPointMake(arrowPointA.x - Arrow_Length * sinf(Arrow_Degree + offsetAngle),arrowPointA.y + Arrow_Length * cosf(Arrow_Degree + offsetAngle));
    
    [arrowPath moveToPoint:arrowPointA];
    [arrowPath addLineToPoint:arrowPointB];
    [lineOne appendPath:arrowPath];
    
    
    
    /**
     *  draw right line
     */
    
    //draw curve
    UIBezierPath *lineTwo = [UIBezierPath bezierPath];
    
    CGPoint pointB = CGPointMake(Center_X + Radius, Center_Y);
    
    [lineTwo moveToPoint:pointB];
    [lineTwo addArcWithCenter:CGPointMake(Center_X, Center_Y) radius:Radius startAngle:0 endAngle:0 + offsetAngle clockwise:YES];
    
    arrowPointA = lineTwo.currentPoint;
    arrowPointB = CGPointMake(arrowPointA.x + Arrow_Length * sinf(Arrow_Degree + offsetAngle),arrowPointA.y - Arrow_Length * cosf(Arrow_Degree + offsetAngle));
    
    [arrowPath moveToPoint:arrowPointA];
    [arrowPath addLineToPoint:arrowPointB];
    [lineTwo appendPath:arrowPath];
    
    
    [curve appendPath:lineOne];
    [curve appendPath:lineTwo];

    return curve;
}

- (UIBezierPath*)verticalLineAndArrow{
    
    CGFloat offsetAngle = ((M_PI*8/10) * Progress(self.progress));
    UIBezierPath* curve = [UIBezierPath bezierPath];
    
    UIBezierPath *lineOne = [UIBezierPath bezierPath];
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    /**
     *  draw left line
     */
    // draw curve
    
    if (self.progress <= 0.5) {
    
        //line
        CGPoint pointA = CGPointMake(Center_X - Radius, Center_Y + Progress(self.progress)*(Center_Y - Lenght));
        CGPoint pointB = CGPointMake(Center_X - Radius, Center_Y + Progress(self.progress)*(Center_Y- Lenght) + Lenght);
        
        [lineOne moveToPoint:pointA];
        [lineOne addLineToPoint:pointB];
        
        //arrow
        CGPoint arrowPointA = pointA;
        CGPoint arrowPointB = CGPointMake(arrowPointA.x - Arrow_Length * sinf(Arrow_Degree), arrowPointA.y + Arrow_Length * cosf(Arrow_Degree));
        [arrowPath moveToPoint:arrowPointA];
        [arrowPath addLineToPoint:arrowPointB];
        [lineOne appendPath:arrowPath];
        
        
        
    }
//    
    // draw curve
    else if(self.progress > 0.5){
        CGPoint pointA = CGPointMake(Center_X - Radius, Center_Y);
        CGPoint pointB = CGPointMake(Center_X - Radius, Center_Y + Lenght - Lenght * Progress(self.progress));
        
        [lineOne moveToPoint:pointA];
        [lineOne addLineToPoint:pointB];
        [lineOne addArcWithCenter:CGPointMake(Center_X,Center_Y) radius:Radius startAngle:M_PI endAngle:M_PI + offsetAngle clockwise:YES];
        
        CGPoint arrowPointA = lineOne.currentPoint;
        CGPoint arrowPointB = CGPointMake(arrowPointA.x - Arrow_Length * sinf(Arrow_Degree + offsetAngle),arrowPointA.y + Arrow_Length * cosf(Arrow_Degree + offsetAngle));
        
        [arrowPath moveToPoint:arrowPointA];
        [arrowPath addLineToPoint:arrowPointB];
        [lineOne appendPath:arrowPath];
        
    }

    /**
     *  draw right line
     */
    
    UIBezierPath *lineTwo = [UIBezierPath bezierPath];
    // draw line
    if (self.progress <= 0.5) {
        //line
        CGPoint pointA = CGPointMake(Center_X + Radius, Center_Y - Progress(self.progress)*(Center_Y - Lenght));
        CGPoint pointB = CGPointMake(Center_X + Radius, Center_Y - Progress(self.progress)*(Center_Y - Lenght) - Lenght);
        
        [lineTwo moveToPoint:pointA];
        [lineTwo addLineToPoint:pointB];
        
        //arrow
        CGPoint arrowPointA = pointA;
        CGPoint arrowPointB = CGPointMake(arrowPointA.x + Arrow_Length * sinf(Arrow_Degree) , arrowPointA.y - Arrow_Length * cosf(Arrow_Degree));
        [arrowPath moveToPoint:arrowPointA];
        [arrowPath addLineToPoint:arrowPointB];
        [lineTwo appendPath:arrowPath];
    }
    //draw curve
    else if(self.progress > 0.5){
        CGPoint pointA = CGPointMake(Center_X + Radius, Center_Y);
        CGPoint pointB = CGPointMake(Center_X + Radius, Center_Y - Lenght + Lenght * Progress(self.progress));
        
        [lineTwo moveToPoint:pointA];
        [lineTwo addLineToPoint:pointB];
        [lineTwo addArcWithCenter:CGPointMake(Center_X, Center_Y) radius:Radius startAngle:0 endAngle:0 + offsetAngle clockwise:YES];
        
        CGPoint arrowPointA = lineTwo.currentPoint;
        CGPoint arrowPointB = CGPointMake(arrowPointA.x + Arrow_Length * sinf(Arrow_Degree + ((M_PI*8/10) * Progress(self.progress))),arrowPointA.y - Arrow_Length * cosf(Arrow_Degree + offsetAngle));
        
        [arrowPath moveToPoint:arrowPointA];
        [arrowPath addLineToPoint:arrowPointB];
        [lineTwo appendPath:arrowPath];
    }
    
    //draw curve
    [curve appendPath:lineOne];
    [curve appendPath:lineTwo];
    return curve;
}


- (UIBezierPath*)horizontalLineAndArrow{
    CGFloat offsetAngle = ((M_PI*8/10) * Progress(self.progress));
    UIBezierPath* curve = [UIBezierPath bezierPath];
    
    UIBezierPath *lineOne = [UIBezierPath bezierPath];
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    /**
     *  draw left line
     */
    // draw curve
    
    if (self.progress <= 0.5) {
        
        //line
        CGPoint pointA = CGPointMake(Center_X - Radius - Progress(self.progress)*(Lenght), Center_Y);
        CGPoint pointB = CGPointMake(Center_X - Radius - Progress(self.progress)*(Lenght) - Lenght, Center_Y);
        
        [lineOne moveToPoint:pointA];
        [lineOne addLineToPoint:pointB];
        
        //arrow
        CGPoint arrowPointA = pointA;
        CGPoint arrowPointB = CGPointMake(arrowPointA.x - Arrow_Length * sinf(Arrow_Degree), arrowPointA.y + Arrow_Length * cosf(Arrow_Degree));
        [arrowPath moveToPoint:arrowPointA];
        [arrowPath addLineToPoint:arrowPointB];
        [lineOne appendPath:arrowPath];
        
        
        
    }
    //
    // draw curve
    else if(self.progress > 0.5){
        CGPoint pointA = CGPointMake(Center_X - Radius, Center_Y);
        CGPoint pointB = CGPointMake(Center_X - Radius + Progress(self.progress)*(Lenght) - Lenght, Center_Y);
        
        [lineOne moveToPoint:pointA];
        [lineOne addLineToPoint:pointB];
        [lineOne addArcWithCenter:CGPointMake(Center_X,Center_Y) radius:Radius startAngle:M_PI endAngle:M_PI + offsetAngle clockwise:YES];
        
        CGPoint arrowPointA = lineOne.currentPoint;
        CGPoint arrowPointB = CGPointMake(arrowPointA.x - Arrow_Length * sinf(Arrow_Degree + offsetAngle),arrowPointA.y + Arrow_Length * cosf(Arrow_Degree + offsetAngle));
        
        [arrowPath moveToPoint:arrowPointA];
        [arrowPath addLineToPoint:arrowPointB];
        [lineOne appendPath:arrowPath];
        
    }
    
    /**
     *  draw right line
     */
    
    UIBezierPath *lineTwo = [UIBezierPath bezierPath];
    // draw line
    if (self.progress <= 0.5) {
        //line
        CGPoint pointA = CGPointMake(Center_X + Radius + Progress(self.progress)*(Lenght), Center_Y);
        CGPoint pointB = CGPointMake(Center_X + Radius + Progress(self.progress)*(Lenght) + Lenght, Center_Y);
        
        [lineTwo moveToPoint:pointA];
        [lineTwo addLineToPoint:pointB];
        
        //arrow
        CGPoint arrowPointA = pointA;
        CGPoint arrowPointB = CGPointMake(arrowPointA.x + Arrow_Length * sinf(Arrow_Degree) , arrowPointA.y - Arrow_Length * cosf(Arrow_Degree));
        [arrowPath moveToPoint:arrowPointA];
        [arrowPath addLineToPoint:arrowPointB];
        [lineTwo appendPath:arrowPath];
    }
    //draw curve
    else if(self.progress > 0.5){
        CGPoint pointA = CGPointMake(Center_X + Radius, Center_Y);
        CGPoint pointB = CGPointMake(Center_X + Radius - Progress(self.progress)*(Lenght) + Lenght, Center_Y);
        
        [lineTwo moveToPoint:pointA];
        [lineTwo addLineToPoint:pointB];
        [lineTwo addArcWithCenter:CGPointMake(Center_X, Center_Y) radius:Radius startAngle:0 endAngle:0 + offsetAngle clockwise:YES];
        
        CGPoint arrowPointA = lineTwo.currentPoint;
        CGPoint arrowPointB = CGPointMake(arrowPointA.x + Arrow_Length * sinf(Arrow_Degree + ((M_PI*8/10) * Progress(self.progress))),arrowPointA.y - Arrow_Length * cosf(Arrow_Degree + offsetAngle));
        
        [arrowPath moveToPoint:arrowPointA];
        [arrowPath addLineToPoint:arrowPointB];
        [lineTwo appendPath:arrowPath];
    }
    
    //draw curve
    [curve appendPath:lineOne];
    [curve appendPath:lineTwo];
    return curve;
}

//progress convert function
CGFloat Progress(CGFloat progress){
    
    if (progress <= 0.5)
        return (1 - progress*2);
    if (progress > 0.5)
        return (progress - 0.5)*2;
    else
        return 0.0f;
}


- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    UIBezierPath* path = [self getShapePath];
    self.path = path.CGPath;
//    self.strokeEnd = _progress;
    
    [self setNeedsDisplay];

}

- (UIBezierPath*)getShapePath{
    if (self.shapeType == OneArrowShape) {
        return [self oneArrowPath];
    }
    else if(self.shapeType == TwoArrowShape){
        return [self twoArrowPath];
    }
    else if(self.shapeType == VerticalLineArrowShape){
        return [self verticalLineAndArrow];
    }
    else
        return [self horizontalLineAndArrow];
}

- (void)setLineColor:(UIColor *)lineColor{
    _lineColor = lineColor;
    self.strokeColor = _lineColor.CGColor;
}

@end
