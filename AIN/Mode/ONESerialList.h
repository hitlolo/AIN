//
//  ONESerialList.h
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONESerialListItem.h"

@interface ONESerialList : NSObject
@property(nonatomic,copy)NSString* serial_id;
@property(nonatomic,copy)NSString* title;
@property(nonatomic,assign)BOOL finished;
@property(nonatomic,strong)NSArray* list;


@end
