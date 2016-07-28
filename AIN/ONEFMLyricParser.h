//
//  FMLyricParser.h
//  hitFM
//
//  Created by Lolo on 15/9/29.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LyricType) {    
    LyricError = 0,
    LyricEmpty,
    LyricNormal,
    LyricNoTimeline
};

@class ONESong;
@interface ONEFMLyricParser : NSObject

@property(strong, nonatomic)NSArray* timeArray;
@property(strong, nonatomic)NSArray* lyricArray;
@property(strong, nonatomic)NSDictionary* timeLyricDic;
@property(assign, nonatomic)NSInteger startIndex;
@property(assign, nonatomic)NSInteger highlightIndex;
@property(assign, nonatomic)LyricType lyricType;

- (void)fetchLyric:(ONESong*)song completion:(void(^)())completionHandler;

@end
