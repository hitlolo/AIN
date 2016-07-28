//
//  HITReadingController.h
//  One
//
//  Created by Lolo on 16/5/17.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HITReadingController : UIViewController

@property(nonatomic,strong)void (^refreshBlock)(void(^)(NSString* html));
@end
