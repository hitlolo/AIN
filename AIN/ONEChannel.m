//
//  ONEChannel.m
//  One
//
//  Created by Lolo on 16/4/15.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEChannel.h"

@implementation ONEChannel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"channel_id" : @"id"};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    static NSString* const cover_url = @"http://img3.douban.com/img/fmadmin/icon/%@";
    //http://img3.douban.com\/img\/fmadmin\/large\/26384.jpg
    NSString* originCover = dic[@"cover"];
    if (originCover == nil || [originCover isEqual:[NSNull null]]) {
        _cover = nil;
        return YES;
    }
    NSString* lastComponent = [originCover lastPathComponent];
    _cover = [NSString stringWithFormat:cover_url,lastComponent];
    return YES;
}
@end
