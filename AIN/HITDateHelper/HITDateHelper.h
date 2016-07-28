//
//  ONEHelper.h
//  hitOne
//
//  Created by Lolo on 15/10/10.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

//提供一些处理函数
@interface HITDateHelper : NSObject

+ (NSString*)getCurrentYear;
+ (NSString*)getCurrentMonth;

+ (NSString*)getDay:(NSString*)dateString;
+ (NSString*)getMonth:(NSString*)dateString;
+ (NSString*)getYear:(NSString*)dateString;

+ (NSString*)getMonthYear:(NSString*)dateString;
+ (NSString*)getDayMonthYear:(NSString*)dateString;

+ (NSString*)getCurrentDate;
+ (NSString*)getDateBeforeSeveralDays:(NSInteger)index;

+ (NSString*)getDateByTimeInterval:(NSString*)intervalString;
@end
