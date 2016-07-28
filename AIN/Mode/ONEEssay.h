//
//  ONEEssay.h
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONEAuthor.h"

@interface ONEEssay : NSObject<AINArticle>

@property(nonatomic,copy)NSString* content_id;
@property(nonatomic,copy)NSString* hp_title;
@property(nonatomic,copy)NSString* sub_title;
@property(nonatomic,copy)NSString* hp_author;
@property(nonatomic,copy)NSString* auth_it;
@property(nonatomic,copy)NSString* hp_author_introduce; //责任编辑
@property(nonatomic,copy)NSString* hp_content; //正文
@property(nonatomic,copy)NSString* hp_makettime;
@property(nonatomic,copy)NSString* wb_name;
@property(nonatomic,copy)NSString* wb_img_url;
@property(nonatomic,copy)NSString* last_update_date;
@property(nonatomic,copy)NSString* web_url;
@property(nonatomic,copy)NSString* guide_word;
@property(nonatomic,copy)NSString* audio;
@property(nonatomic,strong)ONEAuthor* author;
@property(nonatomic,assign)NSInteger praisenum;
@property(nonatomic,assign)NSInteger sharenum;
@property(nonatomic,assign)NSInteger commentnum;

@end
