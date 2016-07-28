//
//  ONEEssayDescription.h
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONEAuthor.h"

//essay
@interface ONEEssayDescription : NSObject<AINArticleDescription>

@property(nonatomic,copy)NSString* content_id;
@property(nonatomic,copy)NSString* hp_title;
@property(nonatomic,copy)NSString* hp_makettime;
@property(nonatomic,copy)NSString* guide_word;
@property(nonatomic,strong)ONEAuthor* author;
@property(nonatomic,assign)BOOL has_audio;

@end
