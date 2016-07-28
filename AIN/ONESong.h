//
//  ONESong.h
//  One
//
//  Created by Lolo on 16/4/15.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioFile.h"

@interface ONESong : NSObject<DOUAudioFile>
@property(nonatomic,copy)NSString* artist;
@property(nonatomic,copy)NSString* title;
@property(nonatomic,copy)NSString* url;
@property(nonatomic,copy)NSString* picture;
@property(nonatomic,assign)NSInteger length;
@property(nonatomic,copy)NSString* like;
@property(nonatomic,copy)NSString* sid;
@property(nonatomic,copy)NSString* ssid;

- (NSURL *)audioFileURL;
@end

