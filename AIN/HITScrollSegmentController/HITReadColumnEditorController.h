//
//  HITReadColumnEditorController.h
//  One
//
//  Created by Lolo on 16/5/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HITReadColumnEditorTransition.h"

@class HITReadColumn;
@protocol HITReadColumnEditorDatasource <NSObject>
- (NSInteger)numberOfColumnsForSection:(NSInteger)section;
- (NSString*)promptTitleOfHeaderForSection:(NSInteger)section;
- (HITReadColumn*)columnForColumnEditorAtIndexPath:(NSIndexPath*)indexPath;

@end
@protocol HITReadColumnEditorDelegate <NSObject>
- (void)columnEditorDidFinishEditing:(BOOL)changed;
- (void)columnEditorDidMoveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath;
- (void)columnEditorDidDeleteColumnFromOnstageAtIndexPath:(NSIndexPath*)indexPath inCollectionView:(UICollectionView*)columnCollection;
@end

@interface HITReadColumnEditorController : UIViewController
@property(nonatomic,weak)id<HITReadColumnEditorDatasource> datasource;
@property(nonatomic,weak)id<HITReadColumnEditorDelegate> delegate;
@end
