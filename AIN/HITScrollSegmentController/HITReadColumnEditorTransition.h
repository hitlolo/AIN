//
//  HITReadColumnEditorTransition.h
//  One
//
//  Created by Lolo on 16/5/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HITReadColumnEditorTransition : NSObject
<UIViewControllerTransitioningDelegate>
@end


@interface HITReadColumnEditorTransitionAnimator : NSObject
<UIViewControllerAnimatedTransitioning>
@property (nonatomic) BOOL isPresentation;
@end


@interface HITReadColumnEditorPresntationController : UIPresentationController
@property(nonatomic,strong)UIView* fromView;
@end