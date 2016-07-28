//
//  AINGalleryPaintingFetcher.m
//  AIN
//
//  Created by Lolo on 16/6/2.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINGalleryPaintingFetcher.h"
#import "AINPainting.h"
#import "YYModel/YYModel.h"

@interface AINGalleryPaintingFetcher ()
@property(nonatomic,strong)AFHTTPSessionManager* sessionManager;
@end

@implementation AINGalleryPaintingFetcher

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


- (void)fetchPaintingsFromDatabaseWithOffset:(NSString *)paintingID completionHandler:(completionGallery)handler{
    
    [[AINDBManager sharedManager]fetchPaitingWithOffset:paintingID completionHandler:^(FMResultSet * _Nullable resultSet) {
        
        NSMutableArray* paitings = [NSMutableArray array];
        while ([resultSet next]) {
            //retrieve values for each record
            NSDictionary* paintingDic = [resultSet resultDictionary];
            AINPainting * paitingModel = [AINPainting yy_modelWithDictionary:paintingDic];
            [paitings addObject:paitingModel];
        }
        
        handler(paitings,nil);
    }];

}



- (void)fetchPaintingsFromHTTPWithOffset:(NSString *)paintingID completionHandler:(completionGallery)handler{
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:gallery_url,paintingID]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSMutableArray* paintings = [NSMutableArray array];
        if (!error) {
            
            NSArray* objects = [responseObject objectForKey:@"data"];
            for (id item in objects) {
                AINPainting* painting = [AINPainting yy_modelWithJSON:item];
                [paintings addObject:painting];
                
                //cache data
                [[AINDBManager sharedManager]storePainting:painting];
            }
            
            
        }
        handler(paintings,error);
        
    }]resume];

}

- (void)fetchPaintingsByKeywords:(NSString *)keywords completionHandler:(completionGallery)handler{
    
    NSString* stringURL = [NSString stringWithFormat:gallery_url_search,keywords];
    //处理中文关键字
    NSString *escapedPath = [stringURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL* url = [NSURL URLWithString:escapedPath];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    [[self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSMutableArray* paintings = [NSMutableArray array];
        if (!error) {
            
            NSArray* objects = [responseObject objectForKey:@"data"];
            for (id item in objects) {
                AINPainting* painting = [AINPainting yy_modelWithJSON:item];
                [paintings addObject:painting];
                
                //cache data
                [[AINDBManager sharedManager]storePainting:painting];
            }
            
            
        }
        handler(paintings,error);
        
    }]resume];
}


- (void)fetchPaintingsByMonth:(NSString *)selectedMonth completionHandler:(completionGallery)handler{
    
    //NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:gallery_url_bymonth,selectedMonth]];
    //NSURLRequest* request = [NSURLRequest requestWithURL:url];
    //[[self.sessionManager dataTaskWithRequest:request completionHandler:handler]resume];
    
}

@end
