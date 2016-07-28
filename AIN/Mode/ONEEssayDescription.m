//
//  ONEEssayDescription.m
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEEssayDescription.h"

@implementation ONEEssayDescription

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSArray* authorArray = dic[@"author"];
    _author = [[ONEAuthor alloc]initWithDictionary:authorArray.firstObject];
    return YES;
}


- (NSString*)articleID{
    return self.content_id;
}

- (NSString*)articleTitle{
    return self.hp_title;
}

- (NSString*)articleSubtitle{
    return self.author.user_name;
}

- (NSString*)articleExcerpt{
    return self.guide_word;
}

- (NSString*)articleAuthor{
    return self.author.user_name;
}

- (NSString*)articleAuthorImageURL{
    return self.author.web_url;
}

- (NSString*)articleAuthorWeibo{
    return self.author.wb_name;
}

- (NSString*)articleTime{
    NSString* time = [HITDateHelper getDayMonthYear:self.hp_makettime];
    return time;
}

- (BOOL)articleHasAudio{
    return self.has_audio;
}

- (AINArticleType)articleType{
    return Essay;
}

@end
