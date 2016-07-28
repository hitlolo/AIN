//
//  AINArticlePlayer.m
//  AIN
//
//  Created by Lolo on 16/7/7.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINArticlePlayer.h"
#import "DOUAudioStreamer.h"
#import <MediaPlayer/MediaPlayer.h>

static void *kAudioKVOKey          = &kAudioKVOKey;
static void *kStatusKVOKey         = &kStatusKVOKey;
static void *kCurrentTimeKVOKey    = &kCurrentTimeKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@interface AINArticlePlayer ()
@property(nonatomic,strong)DOUAudioStreamer *streamer;
@property(nonatomic,strong,readwrite)id<DOUAudioFile> audioArticle;
@property(nonatomic,assign,readwrite)AINAPStatus status;

@end

@implementation AINArticlePlayer

//+ (instancetype)sharedPlayer{
//    static AINArticlePlayer* _player = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _player = [[AINArticlePlayer alloc]init];
//    });
//    return _player;
//}

- (instancetype)init{
    self = [super init];
    if (self) {        
        _status = APIdle;
    }
    return self;
}


- (BOOL)isPaused{
    if (_streamer == nil) {
        return NO;
    }
    else
        return ([_streamer status] == DOUAudioStreamerPaused);
    
}

- (BOOL)isPlaying{
    if(_streamer != nil && [ _streamer status] == DOUAudioStreamerPlaying){
        return YES;
    }
    else
        return NO;
}

- (BOOL)isFinished{
    if (_streamer != nil && [_streamer status] == DOUAudioStreamerFinished) {
        return YES;
    }
    return NO;
}


- (NSTimeInterval)duration{
    if (_streamer == nil) {
        return 0.0f;
    }
    else{
        return _streamer.duration;
    }
}


- (NSTimeInterval)playedTime{
    
    if (_streamer == nil) {
        return 0.0f;
    }
    else{
        return _streamer.currentTime;
    }
}

- (void)seekToTime:(CGFloat)time{
    if (_streamer == nil) {
        return;
    }
    
    _streamer.currentTime = time;
}

- (void)reset{
    if (_streamer == nil) {
        return;
    }
    
    [_streamer removeObserver:self forKeyPath:@"status"];
    
    
    [_streamer stop];
    _streamer = nil;
    
}

- (void)restart{
    [self playAudioArticle:self.audioArticle];
}



- (void)playAudioArticle:(id<DOUAudioFile>)audioArticle{
    [self reset];
    self.audioArticle = audioArticle;
    _streamer = [DOUAudioStreamer streamerWithAudioFile:self.audioArticle];
    [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    //    [_streamer addObserver:self forKeyPath:@"currentTime" options:NSKeyValueObservingOptionNew context:kCurrentTimeKVOKey];
    [_streamer play];
    
}

- (void)pause{
    if (_streamer == nil) {
        return;
    }
    [_streamer pause];
}

- (void)unpause{
    if (_streamer == nil) {
        return;
    }
    //继续播放
    //重新设置播放中心的播放进度时间条
    NSDictionary * dict = [[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo];
    NSMutableDictionary *mutableDict = [dict mutableCopy];
    NSTimeInterval duration = self.playedTime;
    [mutableDict setObject:[NSNumber numberWithDouble:duration] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mutableDict];
    [_streamer play];
}

- (void)stop{
    if (_streamer == nil) {
        return;
    }
    [_streamer stop];
}


#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (context == kStatusKVOKey) {
        [self updateStreamerStatus];
    }
    
    //    else if (context == kBufferingRatioKVOKey) {
    //        NSLog(@"buffering");
    //    }
    
}


- (void)updateStreamerStatus{
    
    switch ([_streamer status]) {
        case DOUAudioStreamerPlaying:{
            [self setStatus:APPlaying];
        }
            break;
            
        case DOUAudioStreamerPaused:{
            [self setStatus:APPaused];
        }
            break;
            
        case DOUAudioStreamerIdle:{
            [self setStatus:APIdle];
        }
            break;
            
        case DOUAudioStreamerFinished:{
            [self setStatus:APFinished];
            
        }
            
            break;
            
        case DOUAudioStreamerBuffering:{
            [self setStatus:APBuffering];
        }
            break;
            
        case DOUAudioStreamerError:{
            [self setStatus:APError];
        }
            break;
    }
    
}
@end

