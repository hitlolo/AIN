//
//  ONESerialDescription.h
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONEAuthor.h"

//serial
@interface ONESerialDescription : NSObject<AINArticleDescription>

@property(nonatomic,copy)NSString* item_id;
@property(nonatomic,copy)NSString* serial_id;
@property(nonatomic,copy)NSString* number;
@property(nonatomic,copy)NSString* title;
@property(nonatomic,copy)NSString* excerpt;
@property(nonatomic,copy)NSString* read_num;
@property(nonatomic,copy)NSString* maketime;
@property(nonatomic,strong)ONEAuthor* author;
@property(nonatomic,assign)BOOL has_audio;

@end
