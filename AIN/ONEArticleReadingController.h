//
//  ONEArticleReadingController.h
//  One
//
//  Created by Lolo on 16/5/1.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "AINBaseController.h"

@protocol AINArticleDescription;
@interface ONEArticleReadingController : UIViewController

@property(nonatomic,strong)id<AINArticleDescription> articleDescription;

@end


