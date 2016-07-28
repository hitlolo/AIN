//
//  ONEQuestionDescription.m
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEQuestionDescription.h"

@implementation ONEQuestionDescription

- (NSString*)articleID{
    return self.question_id;
}

- (NSString*)articleTitle{
    return self.question_title;
}

- (NSString*)articleSubtitle{
     return self.answer_title;
}

- (NSString*)articleExcerpt{
    
    if ([self.answer_content length] >= 50) {
        return [NSString stringWithFormat:@"%@...", [self.answer_content substringToIndex:50]];
       
    }
    return  self.answer_content;
}

- (NSString*)articleTime{
    NSString* time = [HITDateHelper getDayMonthYear:self.question_makettime];
    return time;
}

- (AINArticleType)articleType{
    return Question;
}

@end
