//
//  ONEAuthor.h
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONEUser.h"

@interface ONEAuthor : ONEUser<AINModel>

@property(nonatomic,copy)NSString* desc;
@property(nonatomic,copy)NSString* wb_name;

- (instancetype)initWithDictionary:(NSDictionary*)dic;
@end
