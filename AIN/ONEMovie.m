//
//  ONEMovie.m
//  AIN
//
//  Created by Lolo on 16/7/10.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEMovie.h"

@implementation ONEMovie

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"movieID" : @"id"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"photo" : [NSString class]};
}
@end
