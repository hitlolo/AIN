//
//  ONESerialList.m
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONESerialList.h"


@implementation ONESerialList

+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"list" : [ONESerialListItem class]};
}
@end
