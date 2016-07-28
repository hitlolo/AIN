//
//  AINRootToolbarController.m
//  AIN
//
//  Created by Lolo on 16/6/18.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINRootToolbarController.h"

#import "ONEArticleAudio.h"
#import "AINPlayer.h"
#import "RTSpinKitView.h"
#import "HITMarqueeLabel.h"
#import "AINRootController.h"
#import <MediaPlayer/MediaPlayer.h>

static void *fmStatusKVOKey = &fmStatusKVOKey;
static void *fmSongKVOKey = &fmSongKVOKey;

static void *articleStatusKVOKey = &articleStatusKVOKey;
static void *articleAudioKVOKey = &articleAudioKVOKey;

@interface AINRootToolbarController ()

//toolbar
@property (strong, nonatomic) IBOutlet UIImageView *albumImage;

@property (strong, nonatomic) IBOutlet UIStackView *infoStack;
@property (strong, nonatomic) IBOutlet UIProgressView *playProgress;
@property (strong, nonatomic) IBOutlet HITMarqueeLabel *singerLabel;
@property (strong, nonatomic) IBOutlet HITMarqueeLabel *songLabel;
@property (strong, nonatomic) IBOutlet UIButton *windowButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) RTSpinKitView* spinView;
@property (strong, nonatomic) NSTimer*  progressTimer;
@property (strong, nonatomic) UIPanGestureRecognizer* seekGesture;
@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;
@property (assign, nonatomic) BOOL playing;

@end

@implementation AINRootToolbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.albumImage addGestureRecognizer:self.tapGesture];
    [self.albumImage setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:self.seekGesture];
    self.singerLabel.textFont = [UIFont systemFontOfSize:12];
    self.songLabel.textFont = [UIFont systemFontOfSize:15];
    [self registerKVO];
}


- (void)dealloc{
    
    [self removeKVO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1 
                                                          target:self
                                                        selector:@selector(updateProgress)
                                                        userInfo:nil
                                                         repeats:YES];
    if (!self.playing) {
        [self.progressTimer setFireDate:[NSDate distantFuture]];
    }
    else{
        [self.progressTimer setFireDate:[NSDate date]];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    
    [super viewDidDisappear:animated];
}


#pragma mark - Actions


- (IBAction)windowButtonClicked:(id)sender {
    
    [self.rootToolbarDelegate toolbar:self windowButtonDidClicked:sender];
    
}


- (IBAction)nextButtonClicked:(id)sender {
     [[AINPlayer sharedPlayer].fmPlayer next];
}

- (IBAction)playButtonClicked:(id)sender {
    
    UIButton* button = (UIButton*)sender;
    [button setSelected:!button.selected];
    
    if ([[AINPlayer sharedPlayer].articlePlayer isPlaying]) {
        [[AINPlayer sharedPlayer].articlePlayer pause];
    }
    else if ([[AINPlayer sharedPlayer].articlePlayer isPaused]){
        [[AINPlayer sharedPlayer].articlePlayer unpause];
    }
    else if ([[AINPlayer sharedPlayer].fmPlayer isPlaying]){
        [[AINPlayer sharedPlayer].fmPlayer pause];
    }
    else if ([[AINPlayer sharedPlayer].fmPlayer isPaused]){
        [[AINPlayer sharedPlayer].fmPlayer unpause];
    }
    else{
        [[AINPlayer sharedPlayer]startFM];
    }
}

- (void)registerKVO{
    [[AINPlayer sharedPlayer].fmPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:fmStatusKVOKey];

    [[AINPlayer sharedPlayer].fmPlayer.playList addObserver:self forKeyPath:@"currentSong" options:NSKeyValueObservingOptionNew context:fmSongKVOKey];
    
    [[AINPlayer sharedPlayer].articlePlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:articleStatusKVOKey];
    
    [[AINPlayer sharedPlayer].articlePlayer addObserver:self forKeyPath:@"audioArticle" options:NSKeyValueObservingOptionNew context:articleAudioKVOKey];
}

- (void)removeKVO{
    [[AINPlayer sharedPlayer].fmPlayer removeObserver:self forKeyPath:@"status" context:fmStatusKVOKey];

    [[AINPlayer sharedPlayer].fmPlayer.playList removeObserver:self forKeyPath:@"currentSong" context:fmSongKVOKey];
    
    [[AINPlayer sharedPlayer].articlePlayer removeObserver:self forKeyPath:@"status" context:articleStatusKVOKey];
    
    [[AINPlayer sharedPlayer].articlePlayer removeObserver:self forKeyPath:@"audioArticle" context:articleAudioKVOKey];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if (context == fmStatusKVOKey) {
        ONEFMStatus status = [[change objectForKey:NSKeyValueChangeNewKey]intValue];
        [self updateFMPlayerStatus:status];
    }
    else if ([object isKindOfClass:[ONEFMPlaylist class]] && context == fmSongKVOKey) {
        ONESong* song = [change objectForKey:NSKeyValueChangeNewKey];
        [self updateSongInfo:song];
    }
    else if (context == articleStatusKVOKey){
        AINAPStatus status = [[change objectForKey:NSKeyValueChangeNewKey]intValue];
        [self updateArticlePlayerStatus:status];
    }
    else if (context == articleAudioKVOKey){
        ONEArticleAudio* audio = [change objectForKey:NSKeyValueChangeNewKey];
        [self updateAudioInfo:audio];
    }

    //    else if (context == panelDurationKVOKey){
    //        NSTimeInterval duration = [[change objectForKey:NSKeyValueChangeNewKey]doubleValue];
    //        [self updateProgress:duration];
    //    }
}

- (void)updateFMPlayerStatus:(ONEFMStatus)status{
    
    switch (status) {
            
        case FMPlaying:{
            
            self.playing = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playButton setSelected:YES];
                [self.nextButton setEnabled:YES];
                
                
                
                if ([self.spinView isAnimating]) {
                    [self.playButton setEnabled:YES];
                    [self.spinView stopAnimating];
                }
            });

           
            [self.progressTimer setFireDate:[NSDate date]];
           
            
        }
            break;
        case FMPaused:{
            //[self.playButton setHidden:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playButton setSelected:NO];
            });

            self.playing = NO;
            [self.progressTimer setFireDate:[NSDate distantFuture]];
            
            
        }
            break;
        case FMIdle:{
            self.playing = NO;
           
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.nextButton setEnabled:NO];
                [self resetInfo];
            });

            [self.progressTimer setFireDate:[NSDate distantFuture]];
                        //[self.playButton setHidden:NO];
            
        }
            break;
        case FMFinished:{
            self.playing = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.nextButton setEnabled:NO];
            });
            [self.progressTimer setFireDate:[NSDate distantFuture]];
            
        }
            break;
        case FMError:{
            self.playing = NO;
            [self.progressTimer setFireDate:[NSDate distantFuture]];
            
            
        }
            break;
            
        case FMBuffering:{
            self.playing = NO;
            [self.progressTimer setFireDate:[NSDate distantFuture]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playButton setEnabled:NO];
                [self.spinView setHidden:NO];
                [self.spinView startAnimating];
                
            });
        }
            break;
        default:
            
            break;
    }
}

- (void)updateArticlePlayerStatus:(AINAPStatus)status{
    
    switch (status) {
            
        case APPlaying:{
            
            self.playing = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.infoStack setHidden:NO];
                [self.albumImage setHidden:NO];
                [self.playButton setSelected:YES];
                [self.nextButton setEnabled:NO];
                
                
              
                if ([self.spinView isAnimating]) {
                    [self.playButton setEnabled:YES];
                    [self.spinView stopAnimating];
                }
               
            
            });
            
            
            [self.progressTimer setFireDate:[NSDate date]];
            
            
        }
            break;
        case APPaused:{
            //[self.playButton setHidden:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playButton setSelected:NO];
            });
            
            self.playing = NO;
            [self.progressTimer setFireDate:[NSDate distantFuture]];
            
            
        }
            break;
        case APIdle:{
            self.playing = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.nextButton setEnabled:NO];
                [self resetInfo];
            });
            
            [self.progressTimer setFireDate:[NSDate distantFuture]];
            //[self.playButton setHidden:NO];
            
        }
            break;
        case APFinished:{
            self.playing = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self resetInfo];
                [self.nextButton setEnabled:NO];
            });
            [self.progressTimer setFireDate:[NSDate distantFuture]];
            
        }
            break;
        case APError:{
            self.playing = NO;
            [self.progressTimer setFireDate:[NSDate distantFuture]];
            
            
        }
            break;
        case APBuffering:{
            self.playing = NO;
            [self.progressTimer setFireDate:[NSDate distantFuture]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playButton setEnabled:NO];
                [self.spinView setHidden:NO];
                [self.spinView startAnimating];
              
            });
        }
            break;
            
        
        default:
            
            break;
    }

}


- (void)resetInfo{
    [self.infoStack setHidden:YES];
    [self.albumImage setImage:nil];
    [self.playButton setSelected:NO];
    [self.playProgress setProgress:0.0f];
}

- (void)updateAudioInfo:(ONEArticleAudio*)audio{
    [self.infoStack setHidden:NO];
    [self.albumImage setHidden:NO];
    self.songLabel.text = audio.title;
    self.singerLabel.text = audio.author;
    
    NSURL* url = [NSURL URLWithString:audio.authorAvatar];
    [self.albumImage sd_setImageWithURL:url];
}



- (void)updateSongInfo:(ONESong*)song{
    [self.infoStack setHidden:NO];
    [self.albumImage setHidden:NO];
    self.songLabel.text = song.title;
    self.singerLabel.text = song.artist;

    NSURL* url = [NSURL URLWithString:song.picture];
    [self.albumImage sd_setImageWithURL:url];
    
    [self updateLockScreenWithNewSong:song];
    __weak typeof(self) weakerSelf = self;
    [self.albumImage sd_setImageWithURL:url  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (NSClassFromString(@"MPNowPlayingInfoCenter")){
            
            if (song != nil && image != nil)
            {
                NSDictionary * dict = [[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo];
                NSMutableDictionary *mutableDict = [dict mutableCopy];
                [mutableDict setObject:[[MPMediaItemArtwork alloc]initWithImage:image] forKey:MPMediaItemPropertyArtwork];
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mutableDict];
            }
        }
        weakerSelf.albumImage.image = image;
        
    }];

    
}


- (void)updateProgress{
    
    if ([[AINPlayer sharedPlayer].fmPlayer isPlaying]) {
        NSTimeInterval currentTime = [[AINPlayer sharedPlayer].fmPlayer playedTime];
        NSTimeInterval duration = [[AINPlayer sharedPlayer].fmPlayer duration];
        CGFloat progress = currentTime/duration;
        [self.playProgress setProgress:progress];
    }
    else if ([[AINPlayer sharedPlayer].articlePlayer isPlaying]){
        NSTimeInterval currentTime = [[AINPlayer sharedPlayer].articlePlayer playedTime];
        NSTimeInterval duration = [[AINPlayer sharedPlayer].articlePlayer duration];
        CGFloat progress = currentTime/duration;
        [self.playProgress setProgress:progress];
    }
 }

- (void)seek:(UIPanGestureRecognizer*)pan{
    
    CGPoint translation = [pan translationInView:self.view];
    CGFloat percent = (translation.x) / self.view.width;
    CGFloat time = 0.0;
    CGFloat progress = 0.0f;
    
    if ([[AINPlayer sharedPlayer].fmPlayer isPlaying]) {
        NSTimeInterval currentTime = [[AINPlayer sharedPlayer].fmPlayer playedTime];
        NSTimeInterval duration = [[AINPlayer sharedPlayer].fmPlayer duration];
        time = percent * duration;
        time += currentTime;
        if (time <= 0) {
            time = 0;
        }
        if (time >= duration) {
            time = duration;
        }
        
        progress = time/duration;
        
    }
    else if ([[AINPlayer sharedPlayer].articlePlayer isPlaying]){
        NSTimeInterval currentTime = [[AINPlayer sharedPlayer].articlePlayer playedTime];
        NSTimeInterval duration = [[AINPlayer sharedPlayer].articlePlayer duration];
        time = percent * duration;
        time += currentTime;
        if (time <= 0) {
            time = 0;
        }
        if (time >= duration) {
            time = duration;
        }
         progress = time/duration;
    }
        
    [self.playProgress setProgress:progress];
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        [[AINPlayer sharedPlayer]seekToTime:time];
        [self.playProgress setProgress:progress];
        
        
        //remote control center
        NSDictionary * dict = [[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo];
        NSMutableDictionary *mutableDict = [dict mutableCopy];
        
        [mutableDict setObject:[NSNumber numberWithFloat:time] forKey:MPMediaItemPropertyPlaybackDuration]; //音乐当前已经播放时间
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];

    }

}


- (void)gotoFM:(UITapGestureRecognizer*)tap{
    
    [self.rootController switchToTap:TapFM];
}

#pragma mark - Getter

- (RTSpinKitView*)spinView{
    if (_spinView == nil) {
        _spinView = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave color:globalControlTintColor spinnerSize:20];
        //_spinView.color = globalControlTintColor;
        [_spinView stopAnimating];
        [_spinView setHidesWhenStopped:YES];
        _spinView.center = self.view.center;
        [self.view addSubview:_spinView];
        
    }
    return _spinView;
}

- (UIPanGestureRecognizer*)seekGesture{
    if (_seekGesture == nil) {
        _seekGesture = [[UIPanGestureRecognizer alloc]init];
        [_seekGesture addTarget:self action:@selector(seek:)];
       
    }
    return _seekGesture;
}

- (UITapGestureRecognizer*)tapGesture{
    if (_tapGesture == nil) {
        _tapGesture = [[UITapGestureRecognizer alloc]init];
        _tapGesture.numberOfTapsRequired = 1;
        [_tapGesture addTarget:self action:@selector(gotoFM:)];
    }
    return _tapGesture;
}

#pragma mark - remote controll & info center
//
- (void)updateLockScreenWithNewSong:(ONESong*)song{
    if (NSClassFromString(@"MPNowPlayingInfoCenter")){
        
        if (song != nil){
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            
            [dict setObject:song.title forKey:MPMediaItemPropertyTitle];
            [dict setObject:song.artist forKey:MPMediaItemPropertyArtist];
            NSTimeInterval duration = [[AINPlayer sharedPlayer].fmPlayer playedTime];
            [dict setObject:[NSNumber numberWithFloat:duration] forKey:MPMediaItemPropertyPlaybackDuration]; //音乐当前已经播放时间
            [dict setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];//进度光标的速度 （这个随 自己的播放速率调整，我默认是原速播放）
            [dict setObject:[NSNumber numberWithInteger:song.length]forKey:MPMediaItemPropertyPlaybackDuration];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
        }
    }
}

@end
