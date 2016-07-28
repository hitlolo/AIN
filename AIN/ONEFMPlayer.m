//
//  ONEFMPlayer.m
//  One
//
//  Created by Lolo on 16/5/3.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEFMPlayer.h"
#import "DOUAudioStreamer.h"
#import <MediaPlayer/MediaPlayer.h>
static void *kSongKVOKey           = &kSongKVOKey;
static void *kStatusKVOKey         = &kStatusKVOKey;
static void *kCurrentTimeKVOKey    = &kCurrentTimeKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@interface ONEFMPlayer ()

@property (strong, nonatomic) DOUAudioStreamer *streamer;
@property (strong, nonatomic,readwrite) ONEFMPlaylist* playList;
@property (assign, nonatomic,readwrite) ONEFMStatus status;
@end

@implementation ONEFMPlayer

//+ (instancetype)sharedPlayer{
//    static ONEFMPlayer* _player = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _player = [[ONEFMPlayer alloc]init];
//    });
//    return _player;
//}

- (instancetype)init{
    self = [super init];
    if (self) {

        _status = FMIdle;
        _playList = [[ONEFMPlaylist alloc]init];
        [_playList addObserver:self forKeyPath:@"currentSong" options:NSKeyValueObservingOptionNew context:kSongKVOKey];
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


- (void)reset{
    
    if (_streamer == nil) {
        return;
    }
    

    [_streamer removeObserver:self forKeyPath:@"status"];
    
 
    [_streamer stop];
    
    _streamer = nil;
    
}


- (void)startFM{
    

    [self.playList beiginPlay];
     
}

- (void)play{
    [self reset];
    ONESong* song = self.playList.currentSong;
    _streamer = [DOUAudioStreamer streamerWithAudioFile:song];
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

- (void)next{
    if (_streamer == nil) {
        return;
    }
    [_playList nextSong];
}

- (void)skip{
    if (_streamer == nil) {
        return;
    }
    [_playList skipSong];
}

- (void)rewind{
    if (_streamer == nil) {
        return;
    }
    [_playList rewindSong];
}


- (void)seekToTime:(CGFloat)time{
    if (_streamer == nil) {
        return;
    }
    
    _streamer.currentTime = time;
}
#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([object isKindOfClass:[ONEFMPlaylist class]] && context == kSongKVOKey) {
        [self play];
    }
    
    else if (context == kStatusKVOKey) {
        [self updateStreamerStatus];
    }
   
    //    else if (context == kBufferingRatioKVOKey) {
    //        NSLog(@"buffering");
    //    }
    
}


- (void)updateStreamerStatus{
    
    switch ([_streamer status]) {
        case DOUAudioStreamerPlaying:{
            [self setStatus:FMPlaying];
            
        }
            break;
            
        case DOUAudioStreamerPaused:{
            [self setStatus:FMPaused];
        }
            break;
            
        case DOUAudioStreamerIdle:{
            [self setStatus:FMIdle];
        }
            break;
            
        case DOUAudioStreamerFinished:{
            [self setStatus:FMFinished];
          
            [self.playList nextSong];
            
        }
            
            break;
            
        case DOUAudioStreamerBuffering:{
            [self setStatus:FMBuffering];
        }
            break;
            
        case DOUAudioStreamerError:{
            [self setStatus:FMError];
        }
            break;
    }
    
}
@end
