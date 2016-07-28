//
//  ONEArticle.h
//  One
//
//  Created by Lolo on 16/4/30.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ONEAuthor;
@protocol AINModel;

typedef NS_ENUM(NSInteger,AINArticleType){
    Essay,
    Serial,
    Question,
    Gallery
};


@protocol AINArticleDescription <NSObject>

- (NSString*)articleID;
- (NSString*)articleTitle;
- (NSString*)articleExcerpt;

@optional
- (NSString*)articleSubtitle;
- (NSString*)articleAuthor;
- (NSString*)articleAuthorImageURL;
- (NSString*)articleImageURL;
- (NSString*)articleAuthorWeibo;
- (NSString*)articleTime;
- (NSString*)serialId;
- (NSString*)articleCommentNumber;
- (NSString*)articlePraiseNumber;
- (BOOL)articleHasAudio;
- (NSString*)articleAudio;
- (AINArticleType)articleType;

@end

@protocol AINArticle <AINArticleDescription,AINModel>
- (NSString*)articleToHTML;
@optional
- (ONEAuthor*)articleAuthor;
@end


