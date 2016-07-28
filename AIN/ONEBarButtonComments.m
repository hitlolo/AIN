//
//  ONEBarButtonComments.m
//  One
//
//  Created by Lolo on 16/4/26.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEBarButtonComments.h"

@interface ONEBarButtonComments()
@property(nonatomic,strong)UIButton* commentButton;

@end

@implementation ONEBarButtonComments

- (instancetype)init{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare{
    
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 74, 44)];
    
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    commentButton.frame = CGRectMake(0, 0, 74, 44);
    UIImage* image = [[UIImage imageNamed:@"article_comment_p"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [commentButton setImage:image forState:UIControlStateNormal];
    [commentButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [commentButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [commentButton.titleLabel setMinimumScaleFactor:0.5];
    commentButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    commentButton.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    [commentButton addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:commentButton];
    _commentButton = commentButton;
    self.customView = commentView;

}

- (void)awakeFromNib{
    
}

- (void)setTitle:(NSString *)title{
    [self.commentButton setTitle:title forState:UIControlStateNormal];
}

- (void)clicked:(id)sender{
    [self.target performSelectorOnMainThread:self.action withObject:self waitUntilDone:NO];
}
@end
