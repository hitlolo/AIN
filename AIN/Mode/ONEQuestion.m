//
//  ONEQuestion.m
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEQuestion.h"
#import <objc/runtime.h>

@implementation ONEQuestion


- (NSDictionary*)modelToSQL{
    
    unsigned int count;
    
    // 获取类的所有属性
    // 如果没有属性，则count为0，properties为nil
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *sepratorArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity:count];
    
    
    // -4 hash superclass description debugDescription
    for (NSUInteger i = 0; i < count - 4; i++) {
        // 获取属性名称
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        
        id propertyValue = [self valueForKey:name];
            // 获取属性值
        
        if (propertyValue == nil) {
            propertyValue = @"";
        }
        
        [propertiesArray addObject:name];
        [sepratorArray addObject:@"?"];
        [valuesArray addObject:propertyValue];
        
    }
    
    // 注意，这里properties是一个数组指针，是C的语法，
    // 我们需要使用free函数来释放内存，否则会造成内存泄露
    free(properties);
    
    return @{@"property":propertiesArray,
             @"seprator":sepratorArray,
             @"value":valuesArray
             };
    
}

- (NSString*)articleToHTML{
    
    static NSString *const ONETimePlaceholder = @"<!-- time -->";
    static NSString *const ONEQuestionTitlePlaceholder = @"<!-- question_title -->";
    static NSString *const ONEQuestionContentPlaceholder = @"<!-- question_content -->";
    static NSString *const ONEAnswerTitlePlaceholder = @"<!-- answer_title -->";
    static NSString *const ONEAnswerContentPlaceholder = @"<!-- answer_content -->";
    static NSString *const ONEAuthorPlaceholder = @"<!-- author -->";
    
    static NSString* const ONECSSPlaceHolder = @"<!-- css -->";

    
    NSString *htmlTemplate = nil;
    
    if (!htmlTemplate) {
        NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"Question" withExtension:@"html"];
        htmlTemplate = [NSString stringWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:nil];
    }
    
    NSString *css = nil;
    
    if ([[AINSettingManager sharedManager]isNightOn]) {
        NSURL *URL = [[NSBundle mainBundle] URLForResource:@"night" withExtension:@"css"];
        css = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];
    }
    else {
        NSURL *URL = [[NSBundle mainBundle] URLForResource:@"day" withExtension:@"css"];
        css = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];
    }
    
    
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:ONECSSPlaceHolder withString:css];

    
    NSString* time = [HITDateHelper getDayMonthYear:self.question_makettime];
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:ONETimePlaceholder withString:time];

    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:ONEQuestionTitlePlaceholder withString:self.question_title];
    
    
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:ONEQuestionContentPlaceholder withString:self.question_content];
    
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:ONEAnswerTitlePlaceholder withString:self.answer_title];
    
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:ONEAnswerContentPlaceholder withString:self.answer_content];
    
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:ONEAuthorPlaceholder withString:self.charge_edt];
    
    
    return htmlTemplate;
    
    
}

- (NSString*)articlePraiseNumber{
    return [NSString stringWithFormat:@"%d",self.praisenum];
}

- (NSString*)articleCommentNumber{
    return [NSString stringWithFormat:@"%d",self.commentnum];
}

- (AINArticleType)articleType{
    return Question;
}

- (NSString*)articleID{
    return self.question_id;
}

- (NSString*)articleTitle{
    return self.question_title;
}

- (NSString*)articleExcerpt{
    return self.question_content;
}

- (NSString*)articleAudio{
    return nil;
}


@end
