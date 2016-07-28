//
//  ONEFMPlayer.h
//  One
//
//  Created by Lolo on 16/5/3.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONEFMPlaylist.h"


typedef NS_ENUM(NSInteger,ONEFMStatus) {
    FMIdle,
    FMPlaying,
    FMPaused,
    FMFinished,
    FMBuffering,
    FMError
};


@protocol DOUAudioFile;
@interface ONEFMPlayer : NSObject

@property(nonatomic,assign,readonly)ONEFMStatus status;
@property(nonatomic,strong,readonly)ONEFMPlaylist* playList;

//+ (instancetype)sharedPlayer;

- (void)startFM;
- (void)pause;
- (void)unpause;
- (void)next;
- (void)skip;
- (void)rewind;
- (void)stop;

- (NSTimeInterval)playedTime;
- (NSTimeInterval)duration;
- (BOOL)isPlaying;
- (BOOL)isPaused;
- (void)seekToTime:(CGFloat)time;
@end
