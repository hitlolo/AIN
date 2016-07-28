//
//  ONEReadingComment.h
//  One
//
//  Created by Lolo on 16/4/15.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "ONEUser.h"

@interface ONEReadingComment : NSObject
@property(nonatomic,copy)NSString* comment_id;
@property(nonatomic,copy)NSString* quote;
@property(nonatomic,copy)NSString* content;
@property(nonatomic,assign)NSInteger praisenum;
@property(nonatomic,copy)NSString* input_date;
@property(nonatomic,strong)ONEUser* user;
@property(nonatomic,strong)ONEUser* touser;
@property(nonatomic,copy)NSString* type;

@end
