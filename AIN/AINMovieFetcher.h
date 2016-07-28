//
//  AINMovieFetcher.h
//  AIN
//
//  Created by Lolo on 16/7/8.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ONEMovieBrief;
typedef NSMutableArray <__kindof ONEMovieBrief *> MovieArray;

typedef void(^completionHttp)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error);
typedef void(^completionMovie)(MovieArray* _Nullable movieArray, NSError* _Nullable error);

@interface AINMovieFetcher : NSObject

- (void)fetchMovieIndexWithCompletion:(nonnull completionMovie)completion;
- (void)fetchMovieIndexWithOffset:(nonnull NSString*)offset completion:(nonnull completionMovie)completion;

- (void)fetchMovieWithID:(nonnull NSString*)movieID completion:(nonnull completionHttp)completion;
@end
