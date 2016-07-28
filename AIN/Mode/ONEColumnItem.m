//
//  ONEColumnItem.m
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEColumnItem.h"
#import "ONEEssayDescription.h"
#import "ONESerialDescription.h"
#import "ONEQuestionDescription.h"
#import "YYModel.h"
@implementation ONEColumnItem


- (id<AINArticleDescription>)itemToArticle{
    
    if (self.type == 1) {
        return [self itemToEssay];
    }
    else if (self.type == 2){
        return [self itemToSerial];
    }
    else if (self.type == 3){
        return [self itemToQuestion];
    }
    else{
        return nil;
    }
}

- (ONEEssayDescription*)itemToEssay{
    NSDictionary* dic =  @{@"content_id":self.item_id,
                           @"hp_title":self.title,
                           @"guide_word":self.introduction
                           };
    
    ONEEssayDescription* essay = [ONEEssayDescription yy_modelWithDictionary:dic];
    return essay;
}

- (ONESerialDescription*)itemToSerial{
   
    NSDictionary* dic =  @{@"id":self.item_id,
                           @"title":self.title,
                           @"excerpt":self.introduction
                           };
    
    ONESerialDescription* serial = [ONESerialDescription yy_modelWithDictionary:dic];
    return serial;
}

- (ONEQuestionDescription*)itemToQuestion{
    
    NSDictionary* dic =  @{@"question_id":self.item_id,
                           @"question_title":self.title,
                           @"answer_content":self.introduction
                           };
    
    ONEQuestionDescription* question = [ONEQuestionDescription yy_modelWithDictionary:dic];
    return question;
}
@end
