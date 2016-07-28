//
//  ONESerialContentListTransitionDelegate.h
//  One
//
//  Created by Lolo on 16/5/2.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONESerialContentListTransitionDelegate : NSObject
<UIViewControllerTransitioningDelegate>
@end


@interface ONESerialContentListAnimatedTransitionning : NSObject
<UIViewControllerAnimatedTransitioning>
@property (nonatomic) BOOL isPresentation;
@end


@interface ONESerialContentListPresntationController : UIPresentationController

@end