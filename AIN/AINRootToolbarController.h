//
//  AINRootToolbarController.h
//  AIN
//
//  Created by Lolo on 16/6/18.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AINRootToolbarController;

@protocol AINRootToolbarDelegate <NSObject>
- (void)toolbar:(AINRootToolbarController*) toolbar windowButtonDidClicked:(id)sender;
@end

@interface AINRootToolbarController : UIViewController
@property(nonatomic,weak)id<AINRootToolbarDelegate> rootToolbarDelegate;
@end
