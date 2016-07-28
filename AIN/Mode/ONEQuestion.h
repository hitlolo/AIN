//
//  ONEQuestion.h
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONEQuestion : NSObject<AINArticle>

@property(nonatomic,copy)NSString* question_id;
@property(nonatomic,copy)NSString* question_title;
@property(nonatomic,copy)NSString* question_content;
@property(nonatomic,copy)NSString* answer_title;
@property(nonatomic,copy)NSString* answer_content;
@property(nonatomic,copy)NSString* question_makettime;
@property(nonatomic,copy)NSString* recommend_flag;
@property(nonatomic,copy)NSString* charge_edt;
@property(nonatomic,copy)NSString* last_update_date;
@property(nonatomic,copy)NSString* web_url;
@property(nonatomic,copy)NSString* read_num;
@property(nonatomic,assign)NSInteger praisenum;
@property(nonatomic,assign)NSInteger sharenum;
@property(nonatomic,assign)NSInteger commentnum;

@end
