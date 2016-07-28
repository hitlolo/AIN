//
//  HITReadSegmentContentProvider.m
//  HITScrollListController
//
//  Created by Lolo on 16/5/13.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITReadColumnProvider.h"
#import "HITReadColumn.h"

static NSString* const UserDefaultColumnOnKey = @"columnOn";
static NSString* const UserDefaultColumnOffKey = @"columOff";

@interface HITReadColumnProvider ()

@property(nonatomic,weak)id<HITReadSegmentColumnsDatasource> dataSource;
@property(nonatomic,strong)NSOrderedSet* columnAll;

@end

@implementation HITReadColumnProvider

- (instancetype)initWithColumnDatasource:(id<HITReadSegmentColumnsDatasource>)datasource{
    self = [super init];
    if (self) {
        self.dataSource = datasource;
        
        NSString* plist = [self.dataSource plistFile];
        if (plist) {
            [self prepareColumnAllWithPlist:plist];
        }
        else{
            [self prepareColumnAllWithContentArray:[self.dataSource contentsOfColumns]];
        }
        
        [self prepareOnstageColumns];
        [self prepareOffstageColumns];
        
        _currentIndex = 0;
    }
    
    return self;
}

//- (instancetype)initWithColumnPlistFilename:(NSString *)plist{
//    self = [super init];
//    if (self) {
//        [self prepareColumnAllWithPlist:plist];
//        [self prepareOnstageColumns];
//        [self prepareOffstageColumns];
//        
//        _currentIndex = 0;
//    }
//    return self;
//}

#pragma mark - Prepare Columns for all,on,off.

- (void)prepareColumnAllWithPlist:(NSString*)plistName{
    NSString* path = [self plistFilePath:plistName];
    NSArray* dataArray = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray* columnArray = [NSMutableArray array];
    
    for (NSDictionary* dic in dataArray) {
        HITReadColumn* column = [[HITReadColumn alloc]initWithDictionary:dic];
        [columnArray addObject:column];
        
    }
//    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
//    NSArray *sortDescriptors = @[typeDescriptor];
//    [columnArray sortUsingDescriptors:sortDescriptors];
    _columnAll = [NSOrderedSet orderedSetWithArray:columnArray];
    
}

- (void)prepareColumnAllWithContentArray:(NSArray*)array{
    _columnAll = [NSOrderedSet orderedSetWithArray:array];
}

- (void)prepareOnstageColumns{
    
    [self getOnstageColumnsFromUserDefaults];
    
    if (_columnsOn == nil || [_columnsOn count] == 0){
        _columnsOn = [NSMutableOrderedSet orderedSet];
        [_columnsOn unionOrderedSet:_columnAll];
        [self saveOnstageColumnsToUserDefaults];
    }
    
}

- (void)prepareOffstageColumns{
    if (_columnsOff == nil) {
        _columnsOff = [NSMutableOrderedSet orderedSetWithOrderedSet:_columnAll];
    }
    
    [_columnsOff minusOrderedSet:_columnsOn];
    
    
}

- (void)getOnstageColumnsFromUserDefaults{
    

    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray* dataArray = [userDefaults objectForKey:UserDefaultColumnOnKey];
    NSMutableArray* columnArray = [NSMutableArray array];
    if (dataArray == nil || [dataArray count] == 0 || [dataArray isEqual:[NSNull null]]) {
        return;
    }
    for (NSData* data in dataArray) {
        HITReadColumn* column = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [columnArray addObject:column];
    }
    _columnsOn = [NSMutableOrderedSet orderedSetWithArray:columnArray];
}

- (void)saveOnstageColumnsToUserDefaults{
    NSMutableArray* dataArray = [NSMutableArray array];
    for (HITReadColumn* column in self.columnsOn) {
         NSData *data = [NSKeyedArchiver archivedDataWithRootObject:column];
        [dataArray addObject:data];
    }
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:dataArray forKey:UserDefaultColumnOnKey];
}


- (NSString*)plistFilePath:(NSString*)plistName{
    NSString* path = [[NSBundle mainBundle]pathForResource:plistName ofType:@"plist"];
    return path;
}

- (void)save{
    [self saveOnstageColumnsToUserDefaults];
}
@end
