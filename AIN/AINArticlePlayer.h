//
//  AINArticlePlayer.h
//  AIN
//
//  Created by Lolo on 16/7/7.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger,AINAPStatus) {
    APIdle,
    APPlaying,
    APPaused,
    APFinished,
    APBuffering,
    APError
};

@protocol DOUAudioFile;
@interface AINArticlePlayer : NSObject

@property(nonatomic,strong,readonly)id<DOUAudioFile> audioArticle;
@property(nonatomic,assign,readonly)AINAPStatus status;

//+ (instancetype)sharedPlayer;

- (void)playAudioArticle:(id<DOUAudioFile>)audioArticle;

- (void)restart;
- (void)pause;
- (void)unpause;
- (void)stop;


- (NSTimeInterval)duration;
- (NSTimeInterval)playedTime;
- (BOOL)isPlaying;
- (BOOL)isPaused;
- (BOOL)isFinished;
- (void)seekToTime:(CGFloat)time;
@end
