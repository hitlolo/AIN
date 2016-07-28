//
//  AINPainting.h
//  AIN
//
//  Created by Lolo on 16/6/1.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AINPainting : NSObject<AINModel>

@property(nonatomic,copy)NSString* hpcontent_id;
@property(nonatomic,copy)NSString* hp_title;
@property(nonatomic,copy)NSString* author_id;
@property(nonatomic,copy)NSString* hp_img_url;
@property(nonatomic,copy)NSString* hp_img_original_url;
@property(nonatomic,copy)NSString* hp_author;
@property(nonatomic,copy)NSString* hp_content;
@property(nonatomic,copy)NSString* ipad_url;
@property(nonatomic,copy)NSString* hp_makettime;
@property(nonatomic,copy)NSString* last_update_date;
@property(nonatomic,copy)NSString* web_url;
@property(nonatomic,assign)NSInteger praisenum;
@property(nonatomic,assign)NSInteger sharenum;
@property(nonatomic,assign)NSInteger commentnum;

@end
