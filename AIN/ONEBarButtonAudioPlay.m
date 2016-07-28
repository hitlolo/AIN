//
//  ONEBarButtonPlay.m
//  One
//
//  Created by Lolo on 16/4/26.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEBarButtonAudioPlay.h"


@interface ONEBarButtonAudioPlay()
@property(nonatomic,strong,readwrite)UIButton* playButton;

@end

@implementation ONEBarButtonAudioPlay


- (instancetype)init{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare{
    _paused = NO;
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame = CGRectMake(0, 0, 34, 34);
    UIImage* imagePlay = [[UIImage imageNamed:@"ic_play"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage* imagePause = [[UIImage imageNamed:@"ic_pause"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [playButton setImage:imagePlay forState:UIControlStateNormal];
    [playButton setImage:imagePause forState:UIControlStateSelected];
    playButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [playButton addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    _playButton = playButton;
    self.customView = playButton;
}

- (void)awakeFromNib{
    //[self prepare];
    
}

- (void)setEnabled:(BOOL)enabled{
    
    [super setEnabled:enabled];
    [self.playButton setEnabled:enabled];
    [self.playButton setHidden:!enabled];
}

- (void)setPaused:(BOOL)paused{
    _paused = paused;
    //yes = selected = pause
    //no = not selected = play
    [self.playButton setSelected:!_paused];
}

- (void)clicked:(UIButton*)sender{
    
    [self setPaused:sender.selected];
    [self.target performSelectorOnMainThread:self.action withObject:self waitUntilDone:NO];
}

@end
