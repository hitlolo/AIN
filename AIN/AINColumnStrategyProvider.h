//
//  AINColumnStrategyProvider.h
//  AIN
//
//  Created by Lolo on 16/6/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HITReadSegmentControllerDelegate.h"

typedef NS_ENUM(NSInteger,HITReadColumnType){
    HITReadColumnEssay,
    HITReadColumnSerial,
    HITReadColumnQuestion,
    HITReadColumnElephant,
    HITReadColumnDota2,
    HITReadColumnZhihu
};


@interface AINColumnStrategyProvider : NSObject
<HITReadColumnStrategyDatasource>

@end
