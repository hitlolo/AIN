//
//  ONEBarButtonPlay.h
//  One
//
//  Created by Lolo on 16/4/26.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ONEBarButtonAudioPlay : UIBarButtonItem
@property(nonatomic,assign)BOOL paused;
@property(nonatomic,strong,readonly)UIButton* playButton;

@end
