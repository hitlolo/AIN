//
//  ONEUser.h
//  One
//
//  Created by Lolo on 16/4/15.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONEUser : NSObject
@property(nonatomic,copy)NSString* user_id;
@property(nonatomic,copy)NSString* user_name;
@property(nonatomic,copy)NSString* web_url;

- (instancetype)initWithDictionary:(NSDictionary*)dic;
@end