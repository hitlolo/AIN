//
//  HITScrollSegmentColumns.h
//  AIN
//
//  Created by Lolo on 16/6/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//column
@protocol HITReadColumn <NSObject>
@property(nonatomic,strong)NSString* title;
@property(nonatomic,assign)NSInteger type;
@end


//columns
@protocol HITReadSegmentColumnsDatasource <NSObject>

@optional
- (NSString*)plistFile;
- (NSArray<id<HITReadColumn>>*)contentsOfColumns;
@end

//column strategy
@protocol HITReadSegmentColumnStrategy <NSObject,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,weak)UIViewController* hosterController;
@property(nonatomic,weak)UITableView*      tableView;
@property(nonatomic,strong)NSMutableArray* columnContents;

- (void)columnViewControllerDidLoad:(UIViewController*)hostController withTableView:(UITableView*)tableview;;
- (void)columnViewDidAppear:(BOOL)animated;
- (void)columnTableViewCellNeedRegisteredBeforeReuse:(UITableView*)tableview;

@end

//strategy datasource
@protocol HITReadColumnStrategyDatasource <NSObject>
- (id<HITReadSegmentColumnStrategy>)strategyForColumn:(id<HITReadColumn>)column;
@end


//delegate
@protocol HITReadSegmentControllerDelegate <NSObject>

- (id<HITReadSegmentColumnsDatasource>)columnsDataSource;
- (id<HITReadColumnStrategyDatasource>)columnsStrategyDataSource;

@end