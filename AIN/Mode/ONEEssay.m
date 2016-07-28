//
//  ONEEssay.m
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEEssay.h"
#import <objc/runtime.h>

@implementation ONEEssay

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSArray* authorArray = dic[@"author"];
    _author = [[ONEAuthor alloc]initWithDictionary:authorArray.firstObject];
    return YES;
}


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
        
        id propertyValue;
        
        if ([name isEqualToString:@"author"]) {
            propertyValue = self.author.user_id;
        }
        else{
            // 获取属性值
            propertyValue = [self valueForKey:name];
        }
        
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
    
    static NSString *const ONETitlePlaceholder = @"<!-- title -->";
    static NSString *const ONETimePlaceholder = @"<!-- time -->";
    static NSString *const ONEContentPlaceholder = @"<!-- content -->";
    static NSString *const ONEAuthorImagePlaceholder = @"<!-- head_img -->";
    static NSString *const ONEAuthorNamePlaceholder = @"<!-- author_name -->";
    static NSString *const ONEAuthorIntroPlaceholder = @"<!-- author_intro -->";
    static NSString *const ONEAuthorWeiboPlaceholder = @"<!-- author_weibo -->";
    
    static NSString* const ONECSSPlaceHolder = @"<!-- css -->";
    
    NSString *htmlTemplate = nil;
    
    if (!htmlTemplate) {
        NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"Article" withExtension:@"html"];
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

    
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:ONETitlePlaceholder withString:self.hp_title];
    
    NSString* time = [HITDateHelper getDayMonthYear:self.hp_makettime];
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:ONETimePlaceholder withString:time];
    
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:ONEContentPlaceholder withString:self.hp_content];
    
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:ONEAuthorImagePlaceholder withString:self.author.web_url];
    
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:ONEAuthorNamePlaceholder withString:self.author.user_name?self.author.user_name:@""];
    
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:ONEAuthorIntroPlaceholder withString:self.auth_it?self.auth_it:@""];
    
    htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:ONEAuthorWeiboPlaceholder withString:self.author.wb_name?self.wb_name:@""];
    
    return htmlTemplate;

}

- (NSString*)articlePraiseNumber{
    return [NSString stringWithFormat:@"%d",self.praisenum];
}

- (NSString*)articleCommentNumber{
    return [NSString stringWithFormat:@"%d",self.commentnum];
}

- (AINArticleType)articleType{
    return Essay;
}

- (NSString*)articleID{
    return self.content_id;
}

- (NSString*)articleTitle{
    return self.hp_title;
}

- (NSString*)articleExcerpt{
    return self.guide_word;
}

- (ONEAuthor*)articleAuthor{
    return self.author;
}

- (NSString*)articleAudio{
    return self.audio;
}

@end
