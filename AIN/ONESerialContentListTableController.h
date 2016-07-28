//
//  ONESerialContentListTable.h
//  One
//
//  Created by Lolo on 16/5/2.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ONESerialList;
@class ONESerialListItem;
@protocol ONESerialContentListDelegate;

@interface ONESerialContentListTableController : UITableViewController

@property(nonatomic, weak)ONESerialList* serialContentList;
@property(nonatomic, weak)id<ONESerialContentListDelegate> delegate;
@end

@protocol ONESerialContentListDelegate <NSObject>

- (void)serialContentListTable:(ONESerialContentListTableController*) contentTable didSelectedItem:(ONESerialListItem*)item;

@end



