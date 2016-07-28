//
//  HITTableRevealTransition.h
//  AIN
//
//  Created by Lolo on 16/5/27.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol HITTableRevealInteractiveDelegate <NSObject>

- (void)reavealTrasitionWillBegin;
- (void)reavealTransitionUpdateProgress:(CGFloat)progress;
- (void)reavealTrasitionDidEndAtProgress:(CGFloat)progress;

@end

//transition presentation controller
@interface HITTableRevealPresentationController:UIPresentationController
@end

@interface HITTableRevealTransitionAnimator : NSObject
<UIViewControllerAnimatedTransitioning>
@property(nonatomic,assign)BOOL isPresentation;
@end

//@interface HITTableRevealTransitionOutAnimator : NSObject
//<UIViewControllerAnimatedTransitioning>
//@end

@interface HITTableRevealTransitionInteractive : UIPercentDrivenInteractiveTransition
<HITTableRevealInteractiveDelegate>
@property(nonatomic,assign)BOOL active;
@end


//transition delegate
@interface HITTableRevealTransition : NSObject
<UIViewControllerTransitioningDelegate>
@property(nonatomic,strong)HITTableRevealTransitionInteractive* inInteractive;
@end


