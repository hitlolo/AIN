//
//  ONEArticleAudio.h
//  AIN
//
//  Created by Lolo on 16/7/7.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioFile.h"

@interface ONEArticleAudio : NSObject<DOUAudioFile>

@property(nonatomic,strong)NSString* articleID;
@property(nonatomic,strong)NSString* title;
@property(nonatomic,strong)NSString* author;
@property(nonatomic,strong)NSString* authorAvatar;
@property(nonatomic,strong)NSString* audioURL;

- (NSURL *)audioFileURL;

@end
