//
//  HITTableRevealFooter.h
//  AIN
//
//  Created by Lolo on 16/5/27.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HITTableRevealTransition.h"

@interface HITTableRevealFooter : UIControl
@property(nonatomic,weak)UIScrollView* scrollView;
@property(nonatomic,strong)HITTableRevealTransition* transition;
@end
