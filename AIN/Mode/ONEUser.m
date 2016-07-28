//
//  ONEUser.m
//  One
//
//  Created by Lolo on 16/4/15.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEUser.h"

@implementation ONEUser

- (instancetype)initWithDictionary:(NSDictionary*)dic{
    self = [super init];
    if (self) {
        _user_name = [dic objectForKey:@"user_name"];
        _user_id = [dic objectForKey:@"user_id"];
        _web_url = [dic objectForKey:@"web_url"];

    }
    return self;
}
@end
