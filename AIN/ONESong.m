//
//  ONESong.m
//  One
//
//  Created by Lolo on 16/4/15.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONESong.h"

@implementation ONESong

- (NSURL*)audioFileURL{
    NSURL* url = [NSURL URLWithString:self.url];
    return url;
}
@end
