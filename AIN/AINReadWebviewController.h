//
//  AINReadWebviewController.h
//  AIN
//
//  Created by Lolo on 16/6/27.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AINReadWebviewController : UIViewController
@property(nonatomic,strong)void (^articleLoadBlock)(void(^)(NSString* html));
@end
