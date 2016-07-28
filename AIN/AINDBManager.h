//
//  AINDBManager.h
//  AIN
//
//  Created by Lolo on 16/5/30.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AINPainting;
@interface AINDBManager : NSObject

+ (nonnull instancetype)sharedManager;
- (void)cleanDatabase;
- (CGFloat)databaseSize;
- (nonnull NSString*)databaseFileSize;


//painting
- (void)fetchPaitingWithOffset:(nonnull NSString*)offset
             completionHandler:(nullable void (^)(FMResultSet* _Nullable resultSet))handler;
- (void)storePainting:(nonnull AINPainting*)painting;


//article
- (void)fetchArticleIndexWithType:(AINArticleType)type
            completionHandler:(nullable void (^)(NSMutableArray* _Nullable resultArray))handler;

- (void)fetchArticleWithType:(AINArticleType)type
                   articleID:(nonnull NSString*)articleID
           completionHandler:(nullable void (^)(id<AINArticle> _Nullable article))handler;

- (void)storeArticle:(nonnull id<AINArticle>)article;



//elephant

- (void)fetchElephantIndexWithCompletion:(nullable void (^)(NSMutableArray* _Nullable resultArray))handler;
- (void)fetchElehantArticleWithID:(nonnull NSString*)articleID
                completionHandler:(nullable void (^)(id<AINArticle> _Nullable article))handler;
- (void)storeElephantArticle:(nonnull id<AINArticle>)article;

@end
