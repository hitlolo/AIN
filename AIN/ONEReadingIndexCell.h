//
//  ONEReadingIndexCell.h
//  One
//
//  Created by Lolo on 16/4/29.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ONEReadingIndexCell : UITableViewCell

- (void)setArticle:(id<AINArticleDescription>)article;

+ (CGFloat)cellHeightForTableView:(UITableView *)tableView data:(NSString*)data;


@end
