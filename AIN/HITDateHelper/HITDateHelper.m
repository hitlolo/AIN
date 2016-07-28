//
//  ONEHelper.m
//  hitOne
//
//  Created by Lolo on 15/10/10.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import "HITDateHelper.h"


@implementation HITDateHelper


+ (NSString*)getCurrentYear{
    NSString* date =  [self getCurrentDate];
    return [self getYear:date];
}

+ (NSString*)getCurrentMonth{
    NSString* date = [self getCurrentDate];
    return [self getMonth:date];
}


/**
 *  获取当前日期的字符串表达
 *
 *  @return date String
 */
+ (NSString*)getCurrentDate{
    NSDate* currentDate = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:currentDate];
}



/**
 *  根据索引值和当前日期 获取几天前的日期表达
 *  API 的参数 包括 strDate 和 strRow
 *  strDate 是 yyyy-MM-dd的日期格式
 *  strRow 是 整数索引 表达 strDate的几天前 最大=10（即不超过10天前）
 *
 *  @param index 表示今天的几天前
 *               0,1   无效 （仍然表示今天）
 *               >=1   有效  如2，即表示 昨天
 
 *  @return <#return value description#>
 */
+ (NSString*)getDateBeforeSeveralDays:(NSInteger)index{
    
    NSDate* currentDate = [NSDate date];
    NSDate* toDate = nil;
    
    //获取距今的时间间隔
    // 24 * 60 * 60 即 24小时 * 60分 * 60秒 （即一天）
    // - （负号）表示（之前）
    // +  (正号）即 （之后）
    toDate = [currentDate initWithTimeIntervalSinceNow:-(24 * 60 * 60 * index)];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:toDate];
    
}


/**
 *  日
 *
 *  @param dateString yyyy-MM-dd格式的日期字符串
 *
 *  @return dd字符串
 */
+ (NSString*)getDay:(NSString *)dateString{
    
    NSString* day;
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [inputFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    // 标准时间
   
    NSDate *date =  [inputFormatter dateFromString:dateString];
    
    //NSCalendar对象 获取日期 组件
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitDay|NSCalendarUnitMinute |NSCalendarUnitYear fromDate:date]; // Get necessary date components
    //日
    day = [NSString stringWithFormat:@"%ld",(long)[components day]];
    return day ;
}



/**
 *  月
 *
 *  @param dateString yyyy-MM-dd日期字符串
 *
 *  @return MM
 */
+ (NSString*)getMonth:(NSString *)dateString{
    
    NSString* month;
    
    //字符串转日期
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    [inputFormatter setTimeZone:[NSTimeZone defaultTimeZone]];// 标准时间
    
    NSDate *date =  [inputFormatter dateFromString:dateString];
    //NSCalendar通过日期获取 各单位组件
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth |NSCalendarUnitYear fromDate:date]; // Get necessary date components
    //月
    month = [NSString stringWithFormat:@"%ld",(long)[components month]];
    return month ;
}


/**
 *  年
 *
 *  @param dateString yyyy-MM-dd
 *
 *  @return yyyy
 */
+ (NSString*)getYear:(NSString *)dateString{
    
    NSString* year;
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    [inputFormatter setTimeZone:[NSTimeZone defaultTimeZone]]; // 标准时间
   
    
    NSDate *date =  [inputFormatter dateFromString:dateString];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitDay|NSCalendarUnitMinute |NSCalendarUnitYear fromDate:date]; // Get necessary date components
    
    year = [NSString stringWithFormat:@"%ld",(long)[components year]];
    return year ;

}

/**
 *  获取MMMM格式的年和月
 *  MMMM格式：中文：（十月）
 *           英文：（October）
 *
 *  @param dateString yyyy-MM-dd
 *
 *  @return MMMM，yyyy 如：十月，2014
 */
+ (NSString*)getMonthYear:(NSString *)dateString{
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date = [inputFormatter dateFromString:dateString];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc]init];
    [outputFormatter setDateFormat:@"MMMM,yyyy"];
    
    return [outputFormatter stringFromDate:date];
}


/**
 *  获取MMMM dd,yyyy格式
 *
 *  @param dateString yyyy-MM-dd
 *
 *  @return MMMM dd，yyyy 如 十月 20，2014
 */
+ (NSString*)getDayMonthYear:(NSString *)dateString{
    
    NSDateFormatter *inputFormater = [[NSDateFormatter alloc]init];
    [inputFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date = [inputFormater dateFromString:dateString];
    NSDateFormatter *outputFormater = [[NSDateFormatter alloc]init];
    [outputFormater setDateFormat:@"MMMM dd,yyyy"];
    return [outputFormater stringFromDate:date];
}


+ (NSString*)getDateByTimeInterval:(NSString *)intervalString{
    NSTimeInterval interval = [intervalString doubleValue];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter* outputFormater = [[NSDateFormatter alloc]init];
    [outputFormater setDateFormat:@"MMMM dd,yyyy"];
    return [outputFormater stringFromDate:date];
}

@end
