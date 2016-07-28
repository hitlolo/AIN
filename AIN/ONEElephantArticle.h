//
//  ONEArticle.h
//  One
//
//  Created by Lolo on 16/4/15.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONEElephantArticleBrief.h"
@interface ONEElephantArticle : ONEElephantArticleBrief<AINArticle>

@property(nonatomic,copy)NSString* content;

@end
