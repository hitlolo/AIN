//
//  UITableView+EmptyData.m
//  hitDota
//
//  Created by Lolo on 16/1/26.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "UITableView+EmptyData.h"

@implementation UITableView (EmptyData)

- (void)tableViewDisplayMessage:(NSString*)message forRow:(NSUInteger)row{
    
    if (row == 0) {
        // Display a message when the table is empty
        // 没有数据的时候，UILabel的显示样式
        UILabel *messageLabel = [UILabel new];
        
        messageLabel.text = message;
        //messageLabel.backgroundColor = [UIColor colorWithRed:0.9255 green:0.9216 blue:0.9529 alpha:1.0];
        messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        messageLabel.textColor = [UIColor colorWithRed:0.7556 green:0.7556 blue:0.7556 alpha:1.0];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        
        self.backgroundView = messageLabel;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else {
        self.backgroundView = nil;
        self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
}

- (void)tableViewDisplayMessage:(NSString*)message forRow:(NSUInteger)row separator:(UITableViewCellSeparatorStyle)style{
    
    if (row == 0) {
        // Display a message when the table is empty
        // 没有数据的时候，UILabel的显示样式
        UILabel *messageLabel = [UILabel new];
        
        messageLabel.text = message;
        //messageLabel.backgroundColor = [UIColor colorWithRed:0.9255 green:0.9216 blue:0.9529 alpha:1.0];
        messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        messageLabel.textColor = [UIColor colorWithRed:0.7556 green:0.7556 blue:0.7556 alpha:1.0];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        
        self.backgroundView = messageLabel;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else {
        self.backgroundView = nil;
        self.separatorStyle = style;
    }
}

@end
