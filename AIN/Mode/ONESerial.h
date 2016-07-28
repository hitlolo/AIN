//
//  ONESerial.h
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONEAuthor.h"
//http://v3.wufazhuce.com:8000/api/serialcontent/85
@interface ONESerial : NSObject<AINArticle>

@property(nonatomic,copy)NSString* item_id;
@property(nonatomic,copy)NSString* serial_id;
@property(nonatomic,copy)NSString* number;//连载中的第几篇
@property(nonatomic,copy)NSString* title;
@property(nonatomic,copy)NSString* excerpt;
@property(nonatomic,copy)NSString* content;
@property(nonatomic,copy)NSString* charge_edt;//责任编辑
@property(nonatomic,copy)NSString* read_num;
@property(nonatomic,copy)NSString* maketime;
@property(nonatomic,copy)NSString* last_update_date;
@property(nonatomic,copy)NSString* audio;
@property(nonatomic,copy)NSString* web_url;
@property(nonatomic,copy)NSString* input_name;
@property(nonatomic,copy)NSString* last_update_name;
@property(nonatomic,strong)ONEAuthor* author;
@property(nonatomic,assign)NSInteger praisenum;
@property(nonatomic,assign)NSInteger sharenum;
@property(nonatomic,assign)NSInteger commentnum;

@end
