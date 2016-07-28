//
//  AINCommentHeader.h
//  AIN
//
//  Created by Lolo on 16/6/21.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AINTableHeaderView : UIView

@property(nonatomic,strong)UIColor* textColor UI_APPEARANCE_SELECTOR;

@property(strong,nonatomic,readonly)UILabel* messageLabel;
- (instancetype)initWithMessage:(NSString*)message;
- (void)setMessage:(NSString*)message;

@end
