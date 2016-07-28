//
//  ONEArticleAudio.m
//  AIN
//
//  Created by Lolo on 16/7/7.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEArticleAudio.h"

@implementation ONEArticleAudio
- (NSURL*)audioFileURL{
    NSURL* url = [NSURL URLWithString:self.audioURL];
    return url;
}
@end
