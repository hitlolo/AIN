//
//  AINMovieFetcher.m
//  AIN
//
//  Created by Lolo on 16/7/8.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINMovieFetcher.h"
#import "ONEMovieBrief.h"
#import "YYModel/YYModel.h"

@interface AINMovieFetcher ()
@property(nonatomic,strong)AFHTTPSessionManager* sessionManager;
@end

@implementation AINMovieFetcher

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

- (void)fetchMovieIndexWithCompletion:(completionMovie)completion{
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:movie_index,@"0"]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        
        
        
        NSMutableArray* movies = [NSMutableArray array];
        if (!error) {
            
            NSArray* objects = [responseObject objectForKey:@"data"];
            for (id item in objects) {
                ONEMovieBrief* movieItem = [ONEMovieBrief yy_modelWithJSON:item];
                [movies addObject:movieItem];
                
            }
        }
        completion(movies,error);
        
    }]resume];

}

- (void)fetchMovieIndexWithOffset:(NSString *)offset completion:(completionMovie)completion{
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:movie_index,offset]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        
        NSMutableArray* movies = [NSMutableArray array];
        if (!error) {
            NSArray* objects = [responseObject objectForKey:@"data"];
            for (id item in objects) {
                ONEMovieBrief* movieItem = [ONEMovieBrief yy_modelWithJSON:item];
                [movies addObject:movieItem];
                
            }
        }
        completion(movies,error);
        
    }]resume];

}


- (void)fetchMovieWithID:(NSString *)movieID completion:(completionHttp)completion{
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:movie_detail,movieID]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.sessionManager dataTaskWithRequest:request completionHandler:completion]resume];
}
@end
