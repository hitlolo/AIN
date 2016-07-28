//
//  ONEFMPlaylist.h
//  One
//
//  Created by Lolo on 16/5/4.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONEChannel.h"
#import "ONESong.h"
@interface ONEFMPlaylist : NSObject

@property(nonatomic,strong)ONEChannel* currentChannel;
@property(nonatomic,strong,readonly)ONESong* currentSong;

- (void)beiginPlay;
- (void)nextSong;
- (void)skipSong;
- (void)rewindSong;
- (void)playSongAtIndex:(NSInteger)index;
@end
