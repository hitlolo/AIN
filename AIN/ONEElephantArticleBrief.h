//
//  ONEArticleBrief.h
//  One
//
//  Created by Lolo on 16/4/15.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONEElephantArticleBrief : NSObject

@property(nonatomic,copy)NSString* article_id;
@property(nonatomic,copy)NSString* title;
@property(nonatomic,copy)NSString* headpic;
@property(nonatomic,copy)NSString* raw_headpic;
@property(nonatomic,copy)NSString* author;
@property(nonatomic,copy)NSString* brief;
@property(nonatomic,copy)NSString* read_num;
@property(nonatomic,copy)NSString* wechat_url;
@property(nonatomic,copy)NSString* create_time;
@property(nonatomic,copy)NSString* update_time;


@end

