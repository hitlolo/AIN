//
//  AINPlayer.m
//  AIN
//
//  Created by Lolo on 16/7/7.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINPlayer.h"

@interface AINPlayer ()
@property(nonatomic,strong,readwrite)ONEFMPlayer* fmPlayer;
@property(nonatomic,strong,readwrite)AINArticlePlayer* articlePlayer;
@property(nonatomic,strong)NSTimer*  shutdownTimer;
@end

@implementation AINPlayer


+ (instancetype)sharedPlayer{
    static AINPlayer* _player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _player = [[AINPlayer alloc]init];
    });
    return _player;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)next{
    
    if (self.fmPlayer.isPlaying || self.fmPlayer.isPaused) {
        [self.fmPlayer next];
    }
    
    else return;
}


- (void)pause{
    if (self.fmPlayer.isPlaying) {
        [self.fmPlayer pause];
    }
    else{
        [self.articlePlayer pause];
    }
}

- (void)unpause{
    
    if (self.fmPlayer.isPaused) {
        [self.fmPlayer unpause];
    }
    else{
        [self.articlePlayer unpause];
    }
}

- (void)stop{
    if (self.fmPlayer.isPlaying) {
        [self.fmPlayer stop];
    }
    else{
        [self.articlePlayer stop];
    }
    
}


- (BOOL)playing{
    if (self.fmPlayer.isPlaying || self.articlePlayer.isPlaying) {
        return YES;
    }
    return NO;
}

- (void)startFM{
    if ([self.articlePlayer isPlaying] || [self.articlePlayer isPaused]) {
        [self.articlePlayer stop];
    }
    [self.fmPlayer startFM];
}

- (void)playAudioArticle:(id<DOUAudioFile>)audioArticle{
    
    if ([self.fmPlayer isPlaying] || [self.fmPlayer isPaused]) {
        [self.fmPlayer stop];
    }
    [self.articlePlayer playAudioArticle:audioArticle];
}

- (void)stopAfterMinute:(NSInteger)minute{
    if (minute == 0) {
        [self.shutdownTimer invalidate];
        self.shutdownTimer = nil;
    }
    else{
        self.shutdownTimer = [NSTimer scheduledTimerWithTimeInterval:minute * 60
                                                              target:self
                                                            selector:@selector(stopPlay)
                                                            userInfo:nil
                                                             repeats:NO];
    }
}

- (void)stopPlay{
    [_fmPlayer stop];
    [_articlePlayer stop];
}

- (void)seekToTime:(CGFloat)time{
    if ([self.articlePlayer isPlaying]) {
        [self.articlePlayer seekToTime:time];
    }
    else if ([self.fmPlayer isPlaying]){
        [self.fmPlayer seekToTime:time];
    }
}

#pragma mark - Getter

- (ONEFMPlayer*)fmPlayer{
    if (_fmPlayer == nil) {
        _fmPlayer = [[ONEFMPlayer alloc]init];
    }
    return _fmPlayer;
}

- (AINArticlePlayer*)articlePlayer{
    if (_articlePlayer == nil) {
        _articlePlayer = [[AINArticlePlayer alloc]init];
        
    }
    return _articlePlayer;
}

@end
