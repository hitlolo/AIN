//
//  AINReadArticleFetcher.h
//  AIN
//
//  Created by Lolo on 16/6/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ONEColumn;
@protocol AINArticleDescription;
typedef NSMutableArray <__kindof id<AINArticleDescription>> ArticleArray;
typedef NSMutableArray <__kindof ONEColumn*> ColumnArray;
typedef void(^completionHttp)(NSURLResponse * _Nonnull response,
                              id  _Nullable responseObject,
                              NSError * _Nullable error);
typedef void(^completionArray)(NSMutableArray* _Nullable objectArray, NSError* _Nullable error);
typedef void(^completionColumns)(ColumnArray* _Nullable columnArray, NSError* _Nullable error);
typedef void(^completionArticles)(ArticleArray* _Nullable articleArray, NSError* _Nullable error);
typedef void(^completionArticle)(id<AINArticle> _Nullable article,NSError* _Nullable error);

@interface AINReadArticleFetcher : NSObject

+ (nonnull instancetype)sharedFetcher;

- (void)fetchColumnWithCompletion:(nonnull completionColumns)handler;
- (void)fetchColumnIndexWithColumnID:(nonnull NSString*)columnId
                   completionHandler:(nonnull completionArray)handler;

- (void)fetchEssayIndexWithCompletion:(nonnull completionArticles)handler;
- (void)fetchSerialIndexWithCompletion:(nonnull completionArticles)handler;
- (void)fetchQuestionIndexWithCompletion:(nonnull completionArticles)handler;


- (void)fetchElephantIndexWithCompletion:(nonnull completionArray)handler;
- (void)fetchElephantIndexWithCreateTime:(nonnull NSString*)createTime
                         updateTime:(nonnull NSString*)updateTime
                  completionHandler:(nonnull completionArray)handler;
- (void)fetchElephantArticleWithArticleID:(nonnull NSString*)articleID
                        completionHandler:(nullable completionArticle)handler;


- (void)fetchOneArticleWithType:(AINArticleType)type
                      articleID:(nonnull NSString*)articleID
              completionHandler:(nullable completionArticle)handler;


- (void)fetchCommentWithReadingType:(AINArticleType)type
                          articleID:(nonnull NSString *)articleID
                          commentID:(nonnull NSString *)commentID
                  completionHandler:(nullable completionHttp)handler;

- (void)fetchRelatedArticleWithReadingType:(AINArticleType)type
                                 articleID:(nonnull NSString *)articleID
                         completionHandler:(nonnull completionHttp)handler;

- (void)fetchArticleByMonthWithType:(AINArticleType)type
                      selectedMonth:(nonnull NSString*)selectedMonth
                  completionHadnler:(nullable completionHttp)handler;

- (void)fetchSerialContentListWithSerialID:(nonnull NSString*)serialID
                         completionHandler:(nullable completionHttp)handler;
@end
