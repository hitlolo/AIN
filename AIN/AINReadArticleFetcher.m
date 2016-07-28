//
//  AINReadArticleFetcher.m
//  AIN
//
//  Created by Lolo on 16/6/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINReadArticleFetcher.h"

#import "ONEEssayDescription.h"
#import "ONEEssay.h"

#import "ONESerial.h"
#import "ONESerialDescription.h"

#import "ONEQuestion.h"
#import "ONEQuestionDescription.h"

#import "ONEColumn.h"
#import "ONEColumnItem.h"

#import "ONEElephantArticleBrief.h"
#import "ONEElephantArticle.h"
#import "YYModel/YYModel.h"

@interface AINReadArticleFetcher ()
@property(nonatomic,strong)AFHTTPSessionManager* sessionManager;
@end

@implementation AINReadArticleFetcher


+ (instancetype)sharedFetcher{
    static AINReadArticleFetcher* _fetcher = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        _fetcher = [[AINReadArticleFetcher alloc]init];
    });
    return _fetcher;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare{
    NSURLSessionConfiguration* configure = [NSURLSessionConfiguration defaultSessionConfiguration];
    configure.timeoutIntervalForRequest = 5;
    configure.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    _sessionManager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:configure];
    
}

#pragma mark - Columns

- (void)fetchColumnWithCompletion:(completionColumns)handler{
 
    NSURL* url = [NSURL URLWithString:carousel_url];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSMutableArray* columns = [NSMutableArray array];
        if (!error) {
            
            NSArray* data = [responseObject objectForKey:@"data"];
            for (id column in data) {
                ONEColumn* columnObject = [ONEColumn yy_modelWithJSON:column];
                [columns addObject:columnObject];
            }
            
            handler(columns,error);
        }
        
        //if fails, fetch cached data from database
        if (error) {
            handler(nil,error);
        }
        
    }]resume];

}

- (void)fetchColumnIndexWithColumnID:(NSString *)columnId
                   completionHandler:(completionArray)handler{
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:carousel_item_url,columnId]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSMutableArray* columns = [NSMutableArray array];
        if (!error) {
            
            NSArray* data = [responseObject objectForKey:@"data"];
            for (id column in data) {
                ONEColumnItem* columnObject = [ONEColumnItem yy_modelWithJSON:column];
                [columns addObject:columnObject];
            }
            
            handler(columns,error);
        }
        
        //if fails, fetch cached data from database
        if (error) {
            handler(nil,error);
        }
        
    }]resume];
}


#pragma mark - Essay Index

//fecth from url first
- (void)fetchEssayIndexWithCompletion:(nonnull completionArticles)handler{
    [self fetchEssayIndexFromHTTPWithCompletion:handler];
}

//if fail fetch cached data from database
- (void)fetchEssayIndexFromDBWithCompletion:(nonnull completionArticles)handler{
    
    [[AINDBManager sharedManager]fetchArticleIndexWithType:Essay completionHandler:^(NSMutableArray * _Nullable resultArray) {
        
        [JDStatusBarNotification showWithStatus:@"现在显示缓存文章" dismissAfter:3 styleName:JDStatusBarStyleDark];
        handler(resultArray,nil);
    }];
}

- (void)fetchEssayIndexFromHTTPWithCompletion:(completionArticles)handler{
    
    NSURL* url = [NSURL URLWithString:reading_index];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSMutableArray* essays = [NSMutableArray array];
        if (!error) {
        
            NSDictionary* data = [responseObject objectForKey:@"data"];
            NSArray* essaysJson = [data objectForKey:@"essay"];
        
            for (id essay in essaysJson) {
                ONEEssayDescription* essayDescription = [ONEEssayDescription yy_modelWithJSON:essay];
                [essays addObject:essayDescription];
            }
            
            [JDStatusBarNotification showWithStatus:@"刷新成功" dismissAfter:3 styleName:JDStatusBarStyleSuccess];
            handler(essays,error);
        }
        
        //if fails, fetch data from database
        if (error) {
            [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:2 styleName:JDStatusBarStyleError];
            [self fetchEssayIndexFromDBWithCompletion:handler];
        }
        
    }]resume];

}

#pragma mark - Serial Index

- (void)fetchSerialIndexWithCompletion:(completionArticles)handler{
    [self fetchSerialIndexFromHTTPWithCompletion:handler];
}

- (void)fetchSerialIndexFromHTTPWithCompletion:(completionArticles)handler{
    
    NSURL* url = [NSURL URLWithString:reading_index];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSMutableArray* serials = [NSMutableArray array];
        if (!error) {
            
            NSDictionary* data = [responseObject objectForKey:@"data"];
            NSArray* serialsJson = [data objectForKey:@"serial"];
            
            for (id serail in serialsJson) {
                ONESerialDescription* serialDescription = [ONESerialDescription yy_modelWithJSON:serail];
                [serials addObject:serialDescription];
            }
            
            [JDStatusBarNotification showWithStatus:@"刷新成功" dismissAfter:3 styleName:JDStatusBarStyleSuccess];
            handler(serials,error);
        }
        
        //if fails, fetch cached data from database
        if (error) {
            [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:2 styleName:JDStatusBarStyleError];
            [self fetchSerialIndexFromDBWithCompletion:handler];
        }
        
    }]resume];

    
}

- (void)fetchSerialIndexFromDBWithCompletion:(nonnull completionArticles)handler{
    
    [[AINDBManager sharedManager]fetchArticleIndexWithType:Serial completionHandler:^(NSMutableArray * _Nullable resultArray) {
        
        [JDStatusBarNotification showWithStatus:@"现在显示缓存文章" dismissAfter:3 styleName:JDStatusBarStyleDark];
        handler(resultArray,nil);
    }];
}


#pragma mark - Question Index

- (void)fetchQuestionIndexWithCompletion:(completionArticles)handler{
    [self fetchQuestionIndexFromHTTPWithCompletion:handler];
}


- (void)fetchQuestionIndexFromHTTPWithCompletion:(completionArticles)handler{
    
    NSURL* url = [NSURL URLWithString:reading_index];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSMutableArray* questions = [NSMutableArray array];
        if (!error) {
            
            NSDictionary* data = [responseObject objectForKey:@"data"];
            NSArray* questionsJson = [data objectForKey:@"question"];
            
            for (id question in questionsJson) {
                ONEQuestionDescription* questionDescription = [ONEQuestionDescription yy_modelWithJSON:question];
                [questions addObject:questionDescription];
            }
            
            [JDStatusBarNotification showWithStatus:@"刷新成功" dismissAfter:3 styleName:JDStatusBarStyleSuccess];
            handler(questions,error);
        }
        
        //if fails, fetch cached data from database
        if (error) {
            [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:2 styleName:JDStatusBarStyleError];
            [self fetchQuestionIndexFromDBWithCompletion:handler];
        }
        
    }]resume];
    
    
}

- (void)fetchQuestionIndexFromDBWithCompletion:(nonnull completionArticles)handler{
    
    [[AINDBManager sharedManager]fetchArticleIndexWithType:Question completionHandler:^(NSMutableArray * _Nullable resultArray) {
        
        [JDStatusBarNotification showWithStatus:@"现在显示缓存问答" dismissAfter:3 styleName:JDStatusBarStyleDark];
        handler(resultArray,nil);
    }];
}



#pragma mark - Article

- (void)fetchOneArticleWithType:(AINArticleType)type
                      articleID:(nonnull NSString*)articleID
              completionHandler:(nullable completionArticle)handler{
    
    if (type == Essay) {
        [self fetchReadingEssayWithID:articleID completionHandler:handler];
    }
    else if (type == Serial){
        [self fetchReadingSerialWithID:articleID completionHandler:handler];
    }
    else if (type == Question){
        [self fetchReadingQuestionWithID:articleID completionHandler:handler];
    }

}


- (void)fetchReadingEssayWithID:(NSString *)essayID
              completionHandler:(completionArticle)handler{
    
    
    [[AINDBManager sharedManager]fetchArticleWithType:Essay articleID:essayID completionHandler:^(id<AINArticle>  _Nullable article) {
        
        //cached data
        if (article) {
            [JDStatusBarNotification showWithStatus:@"缓存文章" dismissAfter:3 styleName:JDStatusBarStyleDark];
            handler(article,nil);
        }
        //fetch from http 
        else{
            
            NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:reading_essay,essayID]];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            [[self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                
                if (error) {
                    [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:2 styleName:JDStatusBarStyleError];
                    handler(nil,error);
                    return ;
                }
                
                [JDStatusBarNotification showWithStatus:@"加载成功" dismissAfter:3 styleName:JDStatusBarStyleSuccess];
                NSDictionary* dataJson = [responseObject objectForKey:@"data"];
                id<AINArticle> article = [ONEEssay yy_modelWithJSON:dataJson];
                [[AINDBManager sharedManager]storeArticle:article];
                handler(article,nil);
                
            }]resume];

        }
    }];
    
    
}

- (void)fetchReadingSerialWithID:(nonnull NSString*)serialID
               completionHandler:(nullable completionArticle)handler{
    
    
    [[AINDBManager sharedManager]fetchArticleWithType:Serial articleID:serialID completionHandler:^(id<AINArticle>  _Nullable article) {
        
        //cached data
        if (article) {
            [JDStatusBarNotification showWithStatus:@"缓存文章" dismissAfter:3 styleName:JDStatusBarStyleDark];
            handler(article,nil);
        }
        //fetch from http
        else{
            
            NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:reading_serial,serialID]];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            [[self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                
                if (error) {
                    [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:2 styleName:JDStatusBarStyleError];
                    handler(nil,error);
                    return ;
                }
                
                [JDStatusBarNotification showWithStatus:@"加载成功" dismissAfter:3 styleName:JDStatusBarStyleSuccess];
                NSDictionary* dataJson = [responseObject objectForKey:@"data"];
                id<AINArticle> article = [ONESerial yy_modelWithJSON:dataJson];
                [[AINDBManager sharedManager]storeArticle:article];
                handler(article,nil);
                
            }]resume];
            
        }
    }];


}


- (void)fetchReadingQuestionWithID:(NSString *)questionID
                 completionHandler:(completionArticle)handler{
    
    
    
    [[AINDBManager sharedManager]fetchArticleWithType:Question articleID:questionID completionHandler:^(id<AINArticle>  _Nullable article) {
        
        //cached data
        if (article) {
            [JDStatusBarNotification showWithStatus:@"缓存文章" dismissAfter:3 styleName:JDStatusBarStyleDark];
            handler(article,nil);
        }
        //fetch from http
        else{
            
            NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:reading_question,questionID]];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            [[self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                
                if (error) {
                    [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:2 styleName:JDStatusBarStyleError];
                    handler(nil,error);
                    return ;
                }
                
                [JDStatusBarNotification showWithStatus:@"加载成功" dismissAfter:3 styleName:JDStatusBarStyleSuccess];
                NSDictionary* dataJson = [responseObject objectForKey:@"data"];
                id<AINArticle> article = [ONEQuestion yy_modelWithJSON:dataJson];
                [[AINDBManager sharedManager]storeArticle:article];
                handler(article,nil);
                
            }]resume];
            
        }
    }];
    

}

- (void)fetchCommentWithReadingType:(AINArticleType)type
                          articleID:(NSString *)articleID
                          commentID:(NSString *)commentID
                  completionHandler:(nullable completionHttp)handler{
    
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:reading_comment,[self readingType:type],articleID,commentID]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.sessionManager dataTaskWithRequest:request completionHandler:handler]resume];
}

- (void)fetchRelatedArticleWithReadingType:(AINArticleType)type
                                 articleID:(NSString *)articleID
                         completionHandler:(completionHttp)handler{
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:reading_related,[self readingType:type],articleID]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.sessionManager dataTaskWithRequest:request completionHandler:handler]resume];
}


- (void)fetchArticleByMonthWithType:(AINArticleType)type
                      selectedMonth:(nonnull NSString*)selectedMonth
                  completionHadnler:(nullable completionHttp)handler{
    
    NSString* typeString = [self readingTypeForByMonth:type];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:reading_article_bymonth,typeString,selectedMonth]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.sessionManager dataTaskWithRequest:request completionHandler:handler]resume];
}

- (void)fetchSerialContentListWithSerialID:(nonnull NSString*)serialID
                         completionHandler:(nullable completionHttp)handler{
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:reading_serial_contents,serialID]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.sessionManager dataTaskWithRequest:request completionHandler:handler]resume];
    
}


- (NSString*)readingType:(AINArticleType)type{
    switch (type) {
        case Essay:
            return @"essay";
            break;
        case Serial:
            return @"serial";
            break;
        case Question:
            return @"question";
            break;
        default:
            return nil;
            break;
    }
}

- (NSString*)readingTypeForByMonth:(AINArticleType)type{
    switch (type) {
        case Essay:
            return @"essay";
            break;
        case Serial:
            return @"serialcontent";
            break;
        case Question:
            return @"question";
            break;
        default:
            return nil;
            break;
    }
}


#pragma mark - Elephant


- (void)fetchElephantIndexWithCompletion:(nonnull completionArray)handler{
    
    [self fetchElephantIndexFromHTTPWithCompletion:handler];
}

- (void)fetchElephantIndexWithCreateTime:(nonnull NSString*)createTime
                              updateTime:(nonnull NSString*)updateTime
                       completionHandler:(nonnull completionArray)handler{
    
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:elephant_more_url,createTime,updateTime]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            
           
            
            NSMutableArray* contentArray = [NSMutableArray array];
            NSDictionary* body = [responseObject objectForKey:@"body"];
            
            NSArray* articleArray = [body objectForKey:@"article"];
            for (NSDictionary* articleJson in articleArray) {
                ONEElephantArticleBrief* articleBrief = [ONEElephantArticleBrief yy_modelWithJSON:articleJson];
                [contentArray addObject:articleBrief];
            }
            [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"成功加载%d篇文章",[contentArray count]] dismissAfter:3 styleName:JDStatusBarStyleSuccess];
            handler(contentArray,nil);
        }
        
        //if fails, fetch cached data from database
        if (error) {
            [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:2 styleName:JDStatusBarStyleError];
            handler(nil,error);
        }
        
    }]resume];

    
}

- (void)fetchElephantArticleWithArticleID:(nonnull NSString*)articleID
                        completionHandler:(nullable completionArticle)handler{
    
    
    
    [[AINDBManager sharedManager]fetchElehantArticleWithID:articleID completionHandler:^(id<AINArticle>  _Nullable article) {
        
        //cached data
        if (article) {
            [JDStatusBarNotification showWithStatus:@"缓存文章" dismissAfter:3 styleName:JDStatusBarStyleDark];
            handler(article,nil);
        }
        //fetch from http
        else{
            
            NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:elephant_url,articleID]];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            [[self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                
                if (error) {
                    [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:2 styleName:JDStatusBarStyleError];
                    handler(nil,error);
                    return ;
                }
                
                [JDStatusBarNotification showWithStatus:@"加载成功" dismissAfter:3 styleName:JDStatusBarStyleSuccess];
                NSDictionary* body = [responseObject objectForKey:@"body"];
                NSDictionary* articleJson = [body objectForKey:@"article"];
                ONEElephantArticle* article = [ONEElephantArticle yy_modelWithJSON:articleJson];
        
                [[AINDBManager sharedManager]storeElephantArticle:article];
                handler(article,nil);
                
            }]resume];
            
        }
    }];
    

    
}


- (void)fetchElephantIndexFromHTTPWithCompletion:(nonnull completionArray)handler{
    
    [self.sessionManager GET:elephant_index_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
            [JDStatusBarNotification showWithStatus:@"加载成功" dismissAfter:3 styleName:JDStatusBarStyleSuccess];

            NSMutableArray* contentArray = [NSMutableArray array];
            NSDictionary* body = [responseObject objectForKey:@"body"];

            NSArray* articleArray = [body objectForKey:@"article"];
            for (NSDictionary* articleJson in articleArray) {
                ONEElephantArticleBrief* articleBrief = [ONEElephantArticleBrief yy_modelWithJSON:articleJson];
                [contentArray addObject:articleBrief];
            }
        
        handler(contentArray,nil);
        
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:2 styleName:JDStatusBarStyleError];
            [self fetchElephantIndexFromDBWithCompletion:handler];
    }];
    

}

- (void)fetchElephantIndexFromDBWithCompletion:(nonnull completionArticles)handler{
    
    [[AINDBManager sharedManager]fetchElephantIndexWithCompletion:^(NSMutableArray * _Nullable resultArray) {
        [JDStatusBarNotification showWithStatus:@"现在显示缓存文章" dismissAfter:3 styleName:JDStatusBarStyleDark];
        handler(resultArray,nil);
    }];
}


@end
