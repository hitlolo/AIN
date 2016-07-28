//
//  ONEQuestionDescription.h
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

//question
@interface ONEQuestionDescription : NSObject<AINArticleDescription>

@property(nonatomic,copy)NSString* question_id;
@property(nonatomic,copy)NSString* question_title;
@property(nonatomic,copy)NSString* answer_title;
@property(nonatomic,copy)NSString* answer_content;
@property(nonatomic,copy)NSString* question_makettime;
@end
