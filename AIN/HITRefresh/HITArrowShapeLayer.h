//
//  HITShapeLayer.h
//  UIViewTest
//
//  Created by Lolo on 16/4/13.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ShapeType){
    OneArrowShape,
    TwoArrowShape,
    VerticalLineArrowShape,
    HorizontalLineArrowShape
};
@interface HITArrowShapeLayer : CAShapeLayer

@property(nonatomic,assign)CGFloat progress;
@property(nonatomic,strong)UIColor* lineColor;
@property(nonatomic,assign)ShapeType shapeType;

@end
