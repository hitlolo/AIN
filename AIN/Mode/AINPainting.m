//
//  AINPainting.m
//  AIN
//
//  Created by Lolo on 16/6/1.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINPainting.h"
#import <objc/runtime.h>

@implementation AINPainting

- (NSDictionary*)modelToSQL{
    
    unsigned int count;
    
    // 获取类的所有属性
    // 如果没有属性，则count为0，properties为nil
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *sepratorArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity:count];
    
    
    // -4 hash superclass description debugDescription
    for (NSUInteger i = 0; i < count - 4; i++) {
        // 获取属性名称
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        
        // 获取属性值
        id propertyValue = [self valueForKey:name];
       
        
        [propertiesArray addObject:name];
        [sepratorArray addObject:@"?"];
        [valuesArray addObject:propertyValue];
        
    }
    
    // 注意，这里properties是一个数组指针，是C的语法，
    // 我们需要使用free函数来释放内存，否则会造成内存泄露
    free(properties);
    
    return @{@"property":propertiesArray,
             @"seprator":sepratorArray,
             @"value":valuesArray
             };

}




@end
