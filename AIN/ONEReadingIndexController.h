//
//  ONEReadingListController.h
//  One
//
//  Created by Lolo on 16/5/1.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AINBaseEmbededTableController.h"

@interface ONEReadingIndexController : AINBaseEmbededTableController

@property(nonatomic, assign)AINArticleType articleType;
@property(nonatomic, strong)NSString* selectedDate;
@end
