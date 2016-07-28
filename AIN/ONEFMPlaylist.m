
//
//  ONEFMPlaylist.m
//  One
//
//  Created by Lolo on 16/5/4.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEFMPlaylist.h"
#import "ONEFMPlayer.h"
#import "YYModel/YYModel.h"
static NSString* const playlist_url = @"http://douban.fm/j/mine/playlist";

@interface ONEFMPlaylist ()

@property(nonatomic,strong)AFHTTPSessionManager* httpManager;
@property(nonatomic,strong)NSMutableArray* playList;
@property(nonatomic,assign)NSInteger currentIndex;
@property(nonatomic,strong,readwrite)ONESong* currentSong;

@end


@implementation ONEFMPlaylist

- (instancetype)init{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare{
    _currentChannel = nil;
    _currentSong = nil;
    _currentIndex = 0;
    _playList = [NSMutableArray array];
    _httpManager = [AFHTTPSessionManager manager];
}


- (void)beiginPlay{
    
   

    NSInteger channelNumber = arc4random_uniform(20);
    NSString* randomChannelID = [NSString stringWithFormat:@"%d",channelNumber];
    NSDictionary *defaultChannelDic  = @{
                                         @"id":randomChannelID,
                                         @"name":@"公共兆赫",
                                         @"intro":[NSNull null],
                                         @"banner":[NSNull null],
                                         @"cover":[NSNull null]
                                         };

    self.currentChannel = [ONEChannel yy_modelWithDictionary:defaultChannelDic];
    
    
}

//set channel will trigger playing;
- (void)setCurrentChannel:(ONEChannel *)currentChannel{
    
    _currentChannel = currentChannel;

    [self getSongWithNewAction];
}

- (void)nextSong{
    
    if (self.currentIndex >= [self.playList count] - 1) {
        [self getSongWithNormalEndAction];
    }
    else{
        self.currentIndex += 1;
        self.currentSong = self.playList[_currentIndex];
    }

}

- (void)skipSong{
    if (self.currentIndex >= [self.playList count] - 1) {
        [self getSongWithSkipAction];
    }
    else{
        self.currentIndex += 1;
        self.currentSong = self.playList[_currentIndex];
    }
}

- (void)rewindSong{
    if (self.currentIndex == 0) {
        return;
    }
    else{
        self.currentIndex -= 1;
        self.currentSong = self.playList[_currentIndex];
    }
}

- (void)playSongAtIndex:(NSInteger)index{
    if (index >= [self.playList count] - 1) {
        return;
    }
    else{
        self.currentIndex = index;
        self.currentSong = self.playList[_currentIndex];
    }
}

#pragma mark - Get Song

- (void)getSongWithNewAction{
    
    NSDictionary *parameters = @{
                                 @"from":@"mainsite",
                                 @"type":@"n",
                                 @"channel":self.currentChannel.channel_id
                                 };

    [self getSongWithParameters:parameters];
    
}

- (void)getSongWithNormalEndAction{
    NSDictionary *parameters = @{
                                 @"from":@"mainsite",
                                 @"type":@"p",
                                 @"channel":self.currentChannel.channel_id,
                                 @"sid":self.currentSong.sid
                                 };
    [self getSongWithParameters:parameters];
}

- (void)getSongWithSkipAction{
    
    NSDictionary *parameters = @{
                                 @"from":@"mainsite",
                                 @"type":@"b",
                                 @"channel":self.currentChannel.channel_id,
                                 @"sid":self.currentSong.sid
                                 };
    
    [self getSongWithParameters:parameters];
    
}

- (void)getSongWithParameters:(NSDictionary*)parameters{
    
    [self.httpManager GET:playlist_url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray* songArr = [responseObject objectForKey:@"song"];
        for (id songJson in songArr) {
            ONESong* song = [ONESong yy_modelWithJSON:songJson];
            [self.playList addObject:song];
        }
        self.currentSong = [self.playList lastObject];
        self.currentIndex = [self.playList indexOfObject:self.currentSong];
        
    
        
        
    } failure:nil];
}


@end
