//
//  AINColumnStrategyProvider.m
//  AIN
//
//  Created by Lolo on 16/6/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINColumnStrategyProvider.h"
#import "AINReadingEssayStrategy.h"
#import "AINReadingSerialStrategy.h"
#import "AINReadingQuestionStrategy.h"
#import "AINReadingElephantStrategy.h"

@implementation AINColumnStrategyProvider

- (id<HITReadSegmentColumnStrategy>)strategyForColumn:(id<HITReadColumn>)column{
    
    HITReadColumnType type = column.type;
    
    if (type == HITReadColumnEssay) {
        return [[AINReadingEssayStrategy alloc]init];
    }
    
    if (type == HITReadColumnSerial) {
        return [[AINReadingSerialStrategy alloc]init];
    }
    
    if (type == HITReadColumnQuestion) {
       return [[AINReadingQuestionStrategy alloc]init];
    }
    
    if (type == HITReadColumnElephant){
        return [[AINReadingElephantStrategy alloc]init];
    }
    return nil;
}

@end
