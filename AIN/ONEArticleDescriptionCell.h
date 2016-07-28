//
//  ONEArticleDescriptionCell.h
//  AIN
//
//  Created by Lolo on 16/6/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AINArticleDescription;
@interface ONEArticleDescriptionCell : UITableViewCell
- (void)setArticle:(id<AINArticleDescription>)article;

@end
