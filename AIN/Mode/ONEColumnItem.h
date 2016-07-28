//
//  ONEColumnItem.h
//  One
//
//  Created by Lolo on 16/4/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ONEColumnItem : NSObject

@property(nonatomic,copy)NSString* item_id;
@property(nonatomic,copy)NSString* title;
@property(nonatomic,copy)NSString* introduction;
@property(nonatomic,copy)NSString* author;
@property(nonatomic,copy)NSString* web_url;
@property(nonatomic,assign)NSInteger number;
@property(nonatomic,assign)NSInteger type; //0 essay //1 serial //3. question


- (id<AINArticleDescription>)itemToArticle;

@end
