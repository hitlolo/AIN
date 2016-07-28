//
//  ONEFMPanelController.m
//  One
//
//  Created by Lolo on 16/5/3.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEFMPanelController.h"
#import "ONEFMProgressView.h"
#import "AINPlayer.h"
#import "RTSpinKitView.h"

#import <MediaPlayer/MediaPlayer.h>

static void *panelStatusKVOKey = &panelStatusKVOKey;
static void *panelSongKVOKey = &panelSongKVOKey;
static void *panelChannelKVOKey = &panelChannelKVOKey;
static void *panelDurationKVOKey = &panelDurationKVOKey;

@interface ONEFMPanelController ()
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *channelTitleTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *channelCoverHeightConstraint;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIImageView *albumCoverImage;
@property (strong, nonatomic) IBOutlet UILabel *channelTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *singerNameLabel;
@property (strong, nonatomic) IBOutlet ONEFMProgressView *albumProgressImage;
@property (strong, nonatomic) RTSpinKitView* spinView;

@property (strong, nonatomic) CADisplayLink*  progressTimer;
//@property (strong, nonatomic) NSTimer*  progressTimer;
@property (assign, nonatomic) NSInteger currentSongLength;
@property (assign, nonatomic) ONEFMStatus playerStatus;
@end

@implementation ONEFMPanelController

- (void)awakeFromNib{
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepare];
}


- (void)prepare{
    
    _currentSongLength = 0;
    [self setPlayerStatus:FMIdle];
    
    [self.albumCoverImage setUserInteractionEnabled:YES];
    UITapGestureRecognizer* oneTap = [[UITapGestureRecognizer alloc]init];
    oneTap.numberOfTapsRequired = 1;
    [oneTap addTarget:self action:@selector(albumCoverTaped:)];
    [self.albumCoverImage addGestureRecognizer:oneTap];
    
  
    
    
    [self registerKVO];
}

- (void)dealloc{
    [self removeKVO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
//                                                          target:self
//                                                        selector:@selector(updateProgress)
//                                                        userInfo:nil
//                                                         repeats:YES];
//    if (self.playerStatus != FMPlaying) {
//        [self.progressTimer setFireDate:[NSDate distantFuture]];
//    }
//    else{
//        [self.progressTimer setFireDate:[NSDate date]];
//    }
    
    
    // CADisplayLink有点耗CPU
    
    self.progressTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [self.progressTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    if (self.playerStatus != FMPlaying) {
        [self.progressTimer setPaused:YES];
    }
    else{
        [self.progressTimer setPaused:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

//    self.progressTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];


    
}

- (void)viewWillDisappear:(BOOL)animated{
 
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    
    if ([[UIScreen mainScreen]scale] == 3.0) {
        self.channelTitleTopConstraint.constant = 100;
    }
   // self.channelCoverHeightConstraint.constant = [[UIScreen mainScreen]bounds].size.height/2.5;
    self.albumCoverImage.layer.cornerRadius = self.albumCoverImage.bounds.size.width/2;
    self.albumCoverImage.layer.masksToBounds = YES;
    //self.albumCoverImage.layer.borderColor = [UIColor blackColor].CGColor;
    //self.albumCoverImage.layer.borderWidth = 8.0f;
    
}


- (void)registerKVO{
    [[AINPlayer sharedPlayer].fmPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:panelStatusKVOKey];
    
    [[AINPlayer sharedPlayer].fmPlayer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:panelDurationKVOKey];
    
    [[AINPlayer sharedPlayer].fmPlayer.playList addObserver:self forKeyPath:@"currentChannel" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:panelChannelKVOKey];
    
    [[AINPlayer sharedPlayer].fmPlayer.playList addObserver:self forKeyPath:@"currentSong" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:panelSongKVOKey];
}

- (void)removeKVO{
    [[AINPlayer sharedPlayer].fmPlayer removeObserver:self forKeyPath:@"status" context:panelStatusKVOKey];
    [[AINPlayer sharedPlayer].fmPlayer removeObserver:self forKeyPath:@"duration" context:panelDurationKVOKey];
    [[AINPlayer sharedPlayer].fmPlayer.playList removeObserver:self forKeyPath:@"currentChannel" context:panelChannelKVOKey];
    [[AINPlayer sharedPlayer].fmPlayer.playList removeObserver:self forKeyPath:@"currentSong" context:panelSongKVOKey];
}

#pragma mark - Actions



- (IBAction)playButtonClicked:(id)sender {

    if (self.playerStatus == FMPaused){
   
        [[AINPlayer sharedPlayer]unpause];
    }
   // else    if (self.playerStatus == FMIdle) {
    else{
        [[AINPlayer sharedPlayer] startFM];
        //[self.playButton setHidden:YES];
    }
}

- (void)albumCoverTaped:(UITapGestureRecognizer*)tap{
    if (self.playerStatus == FMPaused) {
        return;
    }
    else if (self.playerStatus == FMPlaying){
        [[AINPlayer sharedPlayer]pause];
    }
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if (context == panelStatusKVOKey) {
        ONEFMStatus status = [[change objectForKey:NSKeyValueChangeNewKey]intValue];
        [self updateByPlayerStatus:status];
    }
    else if ([object isKindOfClass:[ONEFMPlaylist class]] && context == panelSongKVOKey) {
        ONESong* song = [change objectForKey:NSKeyValueChangeNewKey];
        [self updateSongInfo:song];
    }
    else if (context == panelChannelKVOKey) {
        
        ONEChannel* channel = [change objectForKey:NSKeyValueChangeNewKey];
        [self updateChannelInfo:channel];
    }
//    else if (context == panelDurationKVOKey){
//        NSTimeInterval duration = [[change objectForKey:NSKeyValueChangeNewKey]doubleValue];
//        [self updateProgress:duration];
//    }
}


#pragma mark - update interface

- (void)updateByPlayerStatus:(ONEFMStatus)status{
    switch (status) {
            
        case FMPlaying:{
            
            self.playerStatus = FMPlaying;
            //[self.progressTimer setFireDate:[NSDate date]];
            [self.progressTimer setPaused:NO];
           
        }
            break;
        case FMPaused:{
            //[self.playButton setHidden:NO];
            self.playerStatus = FMPaused;
            //[self.progressTimer setFireDate:[NSDate distantFuture]];
            [self.progressTimer setPaused:YES];
            
        }
            break;
        case FMIdle:{
            self.playerStatus = FMIdle;
            //[self.progressTimer setFireDate:[NSDate distantFuture]];
            [self.progressTimer setPaused:YES];
            [self resetSongInfo];
            //[self.playButton setHidden:NO];
            
            
        }
            break;
        case FMFinished:{
            self.playerStatus = FMFinished;
            //[self.progressTimer setFireDate:[NSDate distantFuture]];
            [self.progressTimer setPaused:YES];
            

        }
            break;
        case FMError:{
            self.playerStatus = FMError;
            //[self.progressTimer setFireDate:[NSDate distantFuture]];
            [self.progressTimer setPaused:YES];
            

        }
            break;
        case FMBuffering:{
            self.playerStatus = FMBuffering;
            //[self.progressTimer setFireDate:[NSDate distantFuture]];
            [self.progressTimer setPaused:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.playButton.hidden = YES;
                [self.spinView setHidden:NO];
                [self.spinView startAnimating];
            });
            
            
        }
            break;
        default:
           
            break;
    }
}

- (void)resetSongInfo{

    self.songTitleLabel.text = @"";
    self.singerNameLabel.text = @"";
    self.channelTitleLabel.text = @"与喜欢的音乐不期而遇";
    self.albumCoverImage.image = one_placeHolder_album;
    self.albumCoverImage.layer.affineTransform = CGAffineTransformIdentity;
    [self.albumProgressImage setProgress:0];
}

- (void)updateSongInfo:(ONESong*)song{
    
    if ([song isEqual:[NSNull null]]) {
        return;
    }
    self.songTitleLabel.text = song.title;
    self.singerNameLabel.text = song.artist;
    self.currentSongLength = song.length;
    NSURL* url = [NSURL URLWithString:song.picture];
    
    [self.albumCoverImage sd_setImageWithURL:url placeholderImage:one_placeHolder_album];


//    [self updateLockScreenWithNewSong:song];
//    __weak typeof(self) weakerSelf = self;
//    [self.albumCoverImage sd_setImageWithURL:url placeholderImage:one_placeHolder_album completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        
//        if (NSClassFromString(@"MPNowPlayingInfoCenter")){
//            
//            if (song != nil && image != nil)
//            {
//                NSDictionary * dict = [[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo];
//                NSMutableDictionary *mutableDict = [dict mutableCopy];
//                [mutableDict setObject:[[MPMediaItemArtwork alloc]initWithImage:image] forKey:MPMediaItemPropertyArtwork];
//                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mutableDict];
//            }
//        }
//        weakerSelf.albumCoverImage.image = image;
//
//    }];


}

- (void)updateChannelInfo:(ONEChannel*)channel{
    if ([channel isEqual:[NSNull null]]) {
        return;
    }
    self.channelTitleLabel.text = [NSString stringWithFormat:@"%@Mhz",channel.name];
    //self.title = [NSString stringWithFormat:@"%@Mhz",channel.name];

}

- (void)updateProgress{
    NSTimeInterval duration = [[AINPlayer sharedPlayer].fmPlayer playedTime];
    CGFloat progress = duration/self.currentSongLength;
    [self.albumProgressImage setProgress:progress];
    CGAffineTransform transform = self.albumCoverImage.layer.affineTransform;
    [self.albumCoverImage setTransform:CGAffineTransformRotate(transform, 0.5*M_PI/180)];
}

- (void)setPlayerStatus:(ONEFMStatus)playerStatus{
    if (playerStatus == FMPlaying) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.playButton.hidden = YES;
           // [self.spinView startAnimating];
            if ([self.spinView isAnimating]) {
                [self.spinView stopAnimating];
            }
        });
        
    }
    else if(playerStatus == FMPaused || playerStatus == FMError || playerStatus == FMIdle){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.playButton.hidden = NO;
        });
        
    }
    
    _playerStatus = playerStatus;
}




#pragma mark - Getter

- (RTSpinKitView*)spinView{
    if (_spinView == nil) {
        _spinView = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave];
        _spinView.color = globalControlTintColor;
        [_spinView stopAnimating];
        [_spinView setHidesWhenStopped:YES];
        _spinView.center = self.albumCoverImage.center;
        [self.view addSubview:_spinView];
        
    }
    return _spinView;
}

@end
