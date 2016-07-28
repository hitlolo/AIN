//
//  HITAnimationView.h
//  HITRefreshView
//
//  Created by Lolo on 15/12/6.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HITRefreshView.h"
#import "HITArrowShapeLayer.H"

@interface HITArrowView : UIView<HITRefreshView>

@property(nonatomic, strong)UIColor*  arrowColor;
@property(nonatomic, assign)CGFloat   progress;
@property(nonatomic, assign)ShapeType shapeType;
@end
