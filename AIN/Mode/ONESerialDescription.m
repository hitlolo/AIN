//
//  ONESerialDescription.m
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONESerialDescription.h"

@implementation ONESerialDescription

+ (NSDictionary *)modelCustomPropertyMapper {
    
    
    return @{@"item_id" : @"id"};
}

- (NSString*)serialId{
    return self.serial_id;
}

- (NSString*)articleID{
    return self.item_id;
}

- (NSString*)articleTitle{
    return self.title;
}

- (NSString*)articleSubtitle{
    return self.author.user_name;
}

- (NSString*)articleExcerpt{
    return self.excerpt;
}

- (NSString*)articleAuthor{
    return self.author.user_name;
}

- (NSString*)articleAuthorImageURL{
    return self.author.web_url;
}

- (NSString*)articleAuthorWeibo{
    NSString* weibo = self.author.wb_name? self.author.wb_name:@"";
    return weibo;
}

- (NSString*)articleTime{
    NSString* time = [HITDateHelper getDayMonthYear:self.maketime];
    return time;
}

- (BOOL)articleHasAudio{
    return self.has_audio;
}

- (AINArticleType)articleType{
    return Serial;
}

@end
