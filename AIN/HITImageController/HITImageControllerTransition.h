//
//  HITImageControllerTransition.h
//  AIN
//
//  Created by Lolo on 16/6/3.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HITImageControllerTransition : NSObject
<UIViewControllerTransitioningDelegate>
@end


@interface HITImageControllerPresentation : UIPresentationController
@end

@interface HITImageControllerAnimatorIn : NSObject
<UIViewControllerAnimatedTransitioning>
@end

@interface HITImageControllerAnimatorOut : NSObject
<UIViewControllerAnimatedTransitioning>
@end

