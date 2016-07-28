//
//  HITReadContent.m
//  HITScrollListController
//
//  Created by Lolo on 16/5/13.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITReadColumn.h"


@implementation HITReadColumn

@synthesize title = _title;
@synthesize type = _type;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        _title = [dictionary objectForKey:@"title"];
        _type = [[dictionary objectForKey:@"type"]integerValue];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _title = [aDecoder decodeObjectForKey:@"title"];
        _type = [aDecoder decodeIntegerForKey:@"type"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeInteger:_type forKey:@"type"];
}


- (BOOL)isEqualToColumn:(HITReadColumn*)column{

    BOOL hasEqualType = self.type == column.type;
    BOOL hasEqualTitle = [self.title isEqualToString:column.title];
    if (hasEqualType && hasEqualTitle) {
        
        return YES;
    }
    
    return NO;
}

- (BOOL)isEqual:(id)object{
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:[HITReadColumn class]]) {
        return NO;
    }
    
    return [self isEqualToColumn:(HITReadColumn *)object];
}

- (NSUInteger)hash {
    return [self.title hash] ^ self.type;
}
@end
