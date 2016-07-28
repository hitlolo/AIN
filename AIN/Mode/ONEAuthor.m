//
//  ONEAuthor.m
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEAuthor.h"
#import <objc/runtime.h>

@implementation ONEAuthor

- (instancetype)initWithDictionary:(NSDictionary*)dic{
    self = [super initWithDictionary:dic];
    if (self) {
        _desc = [dic objectForKey:@"desc"];
        _wb_name = [dic objectForKey:@"wb_name"];
    }
    return self;
}


- (NSDictionary*)modelToSQL{
    
    unsigned int selfPropertiyCount;
    unsigned int superPropertiyCount;
    
    // 获取类的所有属性
    // 如果没有属性，则count为0，properties为nil
    objc_property_t *selfProperties = class_copyPropertyList([self class], &selfPropertiyCount);
    objc_property_t *superProperties = class_copyPropertyList([self.superclass class], &superPropertiyCount);
    
    
    NSMutableArray *propertiesArray = [NSMutableArray array];
    NSMutableArray *sepratorArray = [NSMutableArray array];
    NSMutableArray *valuesArray = [NSMutableArray array];
    
    
    //  hash superclass description debugDescription
    
    for (NSUInteger i = 0; i < superPropertiyCount; i++) {
        // 获取属性名称
        objc_property_t property = superProperties[i];
        const char *propertyName = property_getName(property);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        
        // 获取属性值
        id propertyValue = [self valueForKey:name];
        
        
        [propertiesArray addObject:name];
        [sepratorArray addObject:@"?"];
        [valuesArray addObject:propertyValue];
        
    }
    
    for (NSUInteger i = 0; i < selfPropertiyCount-4; i++) {
        // 获取属性名称
        objc_property_t property = selfProperties[i];
        const char *propertyName = property_getName(property);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        
        // 获取属性值
        id propertyValue = [self valueForKey:name];
        if (propertyValue == nil) {
            propertyValue = @"";
        }
        
        [propertiesArray addObject:name];
        [sepratorArray addObject:@"?"];
        [valuesArray addObject:propertyValue];
        
    }
    
    // 注意，这里properties是一个数组指针，是C的语法，
    // 我们需要使用free函数来释放内存，否则会造成内存泄露
    free(selfProperties);
    free(superProperties);
    
    //NSLog(@"%@",[propertiesArray componentsJoinedByString:@"|"]);
    
    
    return @{@"property":propertiesArray,
             @"seprator":sepratorArray,
             @"value":valuesArray
             };
    
}


@end
