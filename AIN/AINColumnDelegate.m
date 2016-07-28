//
//  AINColumnDelegate.m
//  AIN
//
//  Created by Lolo on 16/6/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINColumnDelegate.h"
#import "AINColumnProvider.h"
#import "AINColumnStrategyProvider.h"

@implementation AINColumnDelegate

- (id<HITReadSegmentColumnsDatasource>)columnsDataSource{
    return [[AINColumnProvider alloc]init];
}
- (id<HITReadColumnStrategyDatasource>)columnsStrategyDataSource{
    return [[AINColumnStrategyProvider alloc]init];
}
@end
