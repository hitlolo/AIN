//
//  AINPlayer.h
//  AIN
//
//  Created by Lolo on 16/7/7.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONEFMPlayer.h"
#import "AINArticlePlayer.h"

@interface AINPlayer : NSObject
@property(nonatomic,strong,readonly)ONEFMPlayer* fmPlayer;
@property(nonatomic,strong,readonly)AINArticlePlayer* articlePlayer;

+ (instancetype)sharedPlayer;

- (void)stopAfterMinute:(NSInteger)minute;
- (void)playAudioArticle:(id<DOUAudioFile>)audioArticle;
- (void)startFM;


- (void)next;
- (void)pause;
- (void)unpause;
- (void)stop;

- (BOOL)playing;
- (void)seekToTime:(CGFloat)time;
@end
