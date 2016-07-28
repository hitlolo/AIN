//
//  AINDBManager.m
//  AIN
//
//  Created by Lolo on 16/5/30.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINDBManager.h"

#import "AINPainting.h"

#import "ONEAuthor.h"

#import "ONEEssay.h"
#import "ONEEssayDescription.h"

#import "ONESerial.h"
#import "ONESerialDescription.h"

#import "ONEQuestion.h"
#import "ONEQuestionDescription.h"

#import "ONEElephantArticleBrief.h"
#import "ONEElephantArticle.h"

#import "YYModel/YYModel.h"

@interface AINDBManager ()
@property(nonatomic,strong)FMDatabase* database;
@property(nonatomic,strong)FMDatabaseQueue* databaseQueue;
@end

@implementation AINDBManager

+ (instancetype)sharedManager{
    static AINDBManager* _manager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        _manager = [[AINDBManager alloc]init];
    });
    return _manager;
}


- (instancetype)init{
    self = [super init];
    if (self) {
        [self prepareDatabase];
    }
    return self;
}


- (FMDatabaseQueue*)databaseQueue{
    if (_databaseQueue == nil) {
        _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:[self databaseFilePath]];
    }
    return _databaseQueue;
}


- (void)prepareDatabase{
    
    _database = [FMDatabase databaseWithPath: [self databaseFilePath]];
    NSAssert(_database, @"Database initialize failed");
    NSString* sqlStatements = [self getTableCreatingSQLStatements];
    if (![_database open]) {
        NSLog(@"open database failed;");
        return;
    }
    if (![_database executeStatements:sqlStatements]) {
        NSLog(@"database => failed to create table.");
    };
    
    [_database close];
}

- (NSString*)databaseFilePath{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingString:@"/ain.db"];
}

- (NSString*)getTableCreatingSQLStatements{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"init" ofType:@"sql"];
    NSError *error;
    NSString *sql = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSAssert(!error, @"Failed to get init.sql file, message=%@",error);
    return sql;
}


- (CGFloat)databaseSize{
    NSError* attributesError;
    NSString* path = [self databaseFilePath];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&attributesError];
    
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    long long fileSize = [fileSizeNumber longLongValue];
    
    return fileSize/1024.0f/1024.0f;
}

- (NSString*)databaseFileSize{
    NSInteger page;
    NSInteger pageSize;
    NSInteger ocupiedSize;
    if ([_database open]) {
        page = [_database intForQuery:@"PRAGMA schema.page_count;"];
        pageSize = [_database intForQuery:@"PRAGMA schema.page_size;"];
        ocupiedSize = page * pageSize;
    }
    return [NSString stringWithFormat:@"%ldbytes",(long)ocupiedSize];

}

- (void)cleanDatabase{
    
    //cache
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
        BOOL result;
        result = [db executeUpdate:@"DELETE FROM gallery;"];
        result = [db executeUpdate:@"DELETE FROM author;"];
        result = [db executeUpdate:@"DELETE FROM essay;"];
        result = [db executeUpdate:@"DELETE FROM serial;"];
        result = [db executeUpdate:@"DELETE FROM question;"];
        result = [db executeUpdate:@"DELETE FROM elephant;"];
        
        if (!result) {
            NSLog(@"%d : %@", [db lastErrorCode], [db lastErrorMessage]);
        }

    }];


}

#pragma mark - fetch data

- (void)fetchPaitingWithOffset:(NSString *)offset
             completionHandler:(nullable void (^)(FMResultSet* _Nullable resultSet))handler{
    
    if (![_database open]) {
        return;
    }
    NSString* sql = nil;
    if ([offset isEqualToString:@"0"]) {
        sql = @"SELECT * FROM gallery ORDER BY hp_makettime DESC LIMIT 10";
    }
    else{
        sql = [NSString stringWithFormat:@"SELECT * FROM gallery WHERE hpcontent_id < %@ ORDER BY hp_makettime DESC LIMIT 10",offset];
    }
    
    
    FMResultSet *resultSet = [_database executeQuery:sql];
    
    handler(resultSet);
    
    [_database close];
}



- (void)storePainting:(AINPainting *)painting{
    
    if (painting.hpcontent_id == nil || [painting.hpcontent_id isEqualToString:@""]) {
        return;
    }
    
    NSDictionary* sqlDictionary = [painting modelToSQL];
    NSArray* sepatators = [sqlDictionary objectForKey:@"seprator"];
    NSArray* arguments = [sqlDictionary objectForKey:@"value"];
    
    NSString* sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO gallery VALUES (%@);",[sepatators componentsJoinedByString:@","] ];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql withArgumentsInArray:arguments];
        if (!result) {
            NSLog(@"%d : %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}


#pragma mark - Index

- (void)fetchArticleIndexWithType:(AINArticleType)type
            completionHandler:(nullable void (^)(NSMutableArray* _Nullable resultArray))handler{
    
    
    if (![_database open]) {
        return;
    }
    
    if (type == Essay) {
        [self fetchEssayIndexWithCompletionHandler:handler];
    }
    else if (type == Serial){
        [self fetchSerialIndexWithCompletionHandler:handler];
    }
    else if (type == Question){
        [self fetchQuestionIndexWithCompletionHandler:handler];
    }
    
    [_database close];

}


- (void)fetchEssayIndexWithCompletionHandler:(nullable void (^)(NSMutableArray* _Nullable resultArray))handler{

    
    NSMutableArray* articles = [NSMutableArray array];
    
    NSString* sql = @"SELECT * FROM essay ORDER BY hp_makettime DESC;";
    FMResultSet *resultSet = [_database executeQuery:sql];
    while ([resultSet next]) {
        //retrieve values for each record
        NSMutableDictionary* articleDic = [[resultSet resultDictionary]mutableCopy];
        NSString* author = [articleDic objectForKey:@"author"];
        [self fetchAuthor:author completionHandler:^(FMResultSet * _Nullable resultSet) {
            while ([resultSet next]) {
                NSDictionary* authorDic = [resultSet resultDictionary];
                //ONEAuthor* author = [ONEAuthor yy_modelWithDictionary:authorDic];
                [articleDic setValue:@[authorDic] forKey:@"author"];
                
                ONEEssayDescription * essayDescription = [ONEEssayDescription yy_modelWithDictionary:articleDic];
                [articles addObject:essayDescription];
            }
        }];
       
    }
    
    handler(articles);

}


- (void)fetchSerialIndexWithCompletionHandler:(nullable void (^)(NSMutableArray* _Nullable resultArray))handler{
    
    NSMutableArray* articles = [NSMutableArray array];
    
    NSString* sql = @"SELECT * FROM serial ORDER BY maketime DESC;";
    FMResultSet *resultSet = [_database executeQuery:sql];
    while ([resultSet next]) {
        //retrieve values for each record
        NSMutableDictionary* articleDic = [[resultSet resultDictionary]mutableCopy];
        NSString* author = [articleDic objectForKey:@"author"];
        [self fetchAuthor:author completionHandler:^(FMResultSet * _Nullable resultSet) {
            while ([resultSet next]) {
                NSDictionary* authorDic = [resultSet resultDictionary];
                NSString* item_id = [articleDic valueForKey:@"item_id"];
                [articleDic setValue:authorDic forKey:@"author"];
                [articleDic setValue:item_id forKey:@"id"];
                ONESerialDescription * serialDescription = [ONESerialDescription yy_modelWithDictionary:articleDic];
                [articles addObject:serialDescription];

            }
        }];
        
    }
    
    handler(articles);
}



- (void)fetchQuestionIndexWithCompletionHandler:(nullable void (^)(NSMutableArray* _Nullable resultArray))handler{
    
    NSMutableArray* articles = [NSMutableArray array];
    
    NSString* sql = @"SELECT * FROM question ORDER BY question_makettime DESC;";
    FMResultSet *resultSet = [_database executeQuery:sql];
    while ([resultSet next]) {
        //retrieve values for each record
        NSMutableDictionary* articleDic = [[resultSet resultDictionary]mutableCopy];
        NSString* content = [articleDic objectForKey:@"question_content"];
        [articleDic setObject:content forKey:@"answer_content"];
        ONEQuestionDescription * questionDescription = [ONEQuestionDescription yy_modelWithDictionary:articleDic];
        [articles addObject:questionDescription];
    }
    
    handler(articles);
}


#pragma mark - Article



- (void)fetchArticleWithType:(AINArticleType)type
                   articleID:(nonnull NSString*)articleID
           completionHandler:(nullable void (^)(id<AINArticle> _Nullable article))handler{

    if (![_database open]) {
        return;
    }
    if (type == Essay) {
        [self fetchEssayWithID:articleID completionHandler:handler];
    }
    else if (type == Serial){
        [self fetchSerialWithID:articleID completionHandler:handler];
    }
    else if (type == Question){
        [self fetchQuestionWithID:articleID completionHandler:handler];
    }

    [_database close];
}


- (void)fetchEssayWithID:(NSString*)articleID completionHandler:(nullable void (^)(id<AINArticle> _Nullable article))handler{
    
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM essay WHERE content_id = %@;",articleID];

    __block id<AINArticle> article;
    
   
    FMResultSet* resultSet = [_database executeQuery:sql];
    while ([resultSet next]) {
        //retrieve values for each record
        NSMutableDictionary* articleDic = [[resultSet resultDictionary]mutableCopy];
        NSString* author = [articleDic objectForKey:@"author"];
        [self fetchAuthor:author completionHandler:^(FMResultSet * _Nullable resultSet) {
            while ([resultSet next]) {
                NSDictionary* authorDic = [resultSet resultDictionary];
                //ONEAuthor* author = [ONEAuthor yy_modelWithDictionary:authorDic];
                [articleDic setValue:@[authorDic] forKey:@"author"];
                
                article = [ONEEssay yy_modelWithDictionary:articleDic];
            }
        }];
        
    }
    
    handler(article);

}

- (void)fetchSerialWithID:(NSString*)articleID completionHandler:(nullable void (^)(id<AINArticle> _Nullable article))handler{
    
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM serial WHERE item_id = %@;",articleID];
    
    __block id<AINArticle> article;
    
    
    FMResultSet* resultSet = [_database executeQuery:sql];
    
    while ([resultSet next]) {
        
        //retrieve values for each record
        NSMutableDictionary* articleDic = [[resultSet resultDictionary]mutableCopy];
        NSString* author = [articleDic objectForKey:@"author"];
        [self fetchAuthor:author completionHandler:^(FMResultSet * _Nullable resultSet) {
            while ([resultSet next]) {
                NSDictionary* authorDic = [resultSet resultDictionary];
                //ONEAuthor* author = [ONEAuthor yy_modelWithDictionary:authorDic];
                NSString* item_id = [articleDic valueForKey:@"item_id"];
                [articleDic setValue:authorDic forKey:@"author"];
                [articleDic setValue:item_id forKey:@"id"];
                article = [ONESerial yy_modelWithDictionary:articleDic];
            }
        }];
        
    }
    
    handler(article);

    
}


- (void)fetchQuestionWithID:(NSString*)articleID completionHandler:(nullable void (^)(id<AINArticle> _Nullable article))handler{
    
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM question WHERE question_id = %@;",articleID];
    
    id<AINArticle> article;
    
    
    FMResultSet* resultSet = [_database executeQuery:sql];
    
    
    while ([resultSet next]) {
        
        //retrieve values for each record
        NSDictionary* articleDic = [resultSet resultDictionary];
        article = [ONEQuestion yy_modelWithDictionary:articleDic];
        
    }
    
    handler(article);
}


#pragma mark - Author

- (void)fetchAuthor:(NSString*)authorID completionHandler:(nullable void (^)(FMResultSet* _Nullable resultSet))handler{
    
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM author WHERE user_id = %@;",authorID];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet* resultSet = [db executeQuery:sql];
        handler(resultSet);
    }];
    
}



#pragma mark - Store

- (void)storeAuthor:(nonnull ONEAuthor*)author{
    
    NSDictionary* sqlDictionary = [author modelToSQL];
    NSArray* sepatators = [sqlDictionary objectForKey:@"seprator"];
    NSArray* arguments = [sqlDictionary objectForKey:@"value"];
    
    NSString* sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO author VALUES (%@);",[sepatators componentsJoinedByString:@","] ];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql withArgumentsInArray:arguments];
        if (!result) {
            NSLog(@"%d : %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];

}

- (void)storeArticle:(nonnull id<AINArticle>)article{
    
    if ([article respondsToSelector:@selector(articleAuthor)]) {
        ONEAuthor* author = [article articleAuthor];
        [self storeAuthor:author];
    }
    
    if ([article respondsToSelector:@selector(articleType)]) {
        AINArticleType type = [article articleType];
        if (type == Essay) {
            [self storeEssay:article];
        }
        else if (type == Serial){
            [self storeSerial:article];
        }
        else if (type == Question){
            [self storeQuestion:article];
        }
        
    }
   
}

- (void)storeEssay:(nonnull id<AINArticle>)article{
    
    NSDictionary* sqlDictionary = [article modelToSQL];
    NSArray* properties = [sqlDictionary objectForKey:@"property"];
    NSArray* sepatators = [sqlDictionary objectForKey:@"seprator"];
    NSArray* arguments = [sqlDictionary objectForKey:@"value"];
    
    NSString* sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO essay (%@) VALUES (%@);",[properties componentsJoinedByString:@","], [sepatators componentsJoinedByString:@","] ];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql withArgumentsInArray:arguments];
        if (!result) {
            NSLog(@"%d : %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];

}

- (void)storeSerial:(nonnull id<AINArticle>)article{
    
    NSDictionary* sqlDictionary = [article modelToSQL];
    NSArray* properties = [sqlDictionary objectForKey:@"property"];
    NSArray* sepatators = [sqlDictionary objectForKey:@"seprator"];
    NSArray* arguments = [sqlDictionary objectForKey:@"value"];
    
    NSString* sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO serial (%@) VALUES (%@);",[properties componentsJoinedByString:@","], [sepatators componentsJoinedByString:@","] ];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql withArgumentsInArray:arguments];
        if (!result) {
            NSLog(@"%d : %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];

}
    
- (void)storeQuestion:(nonnull id<AINArticle>)article{
    
    NSDictionary* sqlDictionary = [article modelToSQL];
    NSArray* properties = [sqlDictionary objectForKey:@"property"];
    NSArray* sepatators = [sqlDictionary objectForKey:@"seprator"];
    NSArray* arguments = [sqlDictionary objectForKey:@"value"];
    
    NSString* sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO question (%@) VALUES (%@);",[properties componentsJoinedByString:@","], [sepatators componentsJoinedByString:@","] ];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql withArgumentsInArray:arguments];
        if (!result) {
            NSLog(@"%d : %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];

}



#pragma mark - Elephant

- (void)fetchElephantIndexWithCompletion:(nullable void (^)(NSMutableArray* _Nullable resultArray))handler{
    
    
    if (![_database open]) {
        return;
    }

    
   
    
    NSMutableArray* articles = [NSMutableArray array];
    
    NSString* sql = @"SELECT * FROM elephant ORDER BY create_time DESC;";
    FMResultSet *resultSet = [_database executeQuery:sql];
    while ([resultSet next]) {
        //retrieve values for each record
        NSMutableDictionary* articleDic = [[resultSet resultDictionary]mutableCopy];
        
        NSString* item_id = [articleDic valueForKey:@"article_id"];
        [articleDic setValue:item_id forKey:@"id"];
        ONEElephantArticleBrief * article = [ONEElephantArticleBrief yy_modelWithDictionary:articleDic];
        [articles addObject:article];
        
    }
    
    handler(articles);

    
    
    [_database close];

}

- (void)fetchElehantArticleWithID:(nonnull NSString*)articleID
                completionHandler:(nullable void (^)(id<AINArticle> _Nullable article))handler{
    
    
    if (![_database open]) {
        return;
    }
    
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM elephant WHERE article_id = %@;",articleID];
    

    id<AINArticle> article;

    
    FMResultSet* resultSet = [_database executeQuery:sql];
    while ([resultSet next]) {
        //retrieve values for each record
        NSMutableDictionary* articleDic = [[resultSet resultDictionary]mutableCopy];
        
        NSString* item_id = [articleDic valueForKey:@"article_id"];
        [articleDic setValue:item_id forKey:@"id"];
        article = [ONEElephantArticle yy_modelWithDictionary:articleDic];
    }
    
    handler(article);

    
    
    [_database close];

}

- (void)storeElephantArticle:(nonnull id<AINArticle>)article{
    NSDictionary* sqlDictionary = [article modelToSQL];
    NSArray* properties = [sqlDictionary objectForKey:@"property"];
    NSArray* sepatators = [sqlDictionary objectForKey:@"seprator"];
    NSArray* arguments = [sqlDictionary objectForKey:@"value"];
    
    NSString* sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO elephant (%@) VALUES (%@);",[properties componentsJoinedByString:@","], [sepatators componentsJoinedByString:@","] ];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql withArgumentsInArray:arguments];
        if (!result) {
            NSLog(@"%d : %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];

}


@end
