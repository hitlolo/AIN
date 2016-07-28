//
//  HITTextValidationFiled.h
//  hitDota
//
//  Created by Lolo on 16/1/2.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HITTextValidator.h"

@interface HITTextValidationFiled : UITextField

@property(nonatomic,strong)IBInspectable UIColor* messageBackgroundColor;
@property(nonatomic,strong)IBInspectable UIColor* messageTextColor;

@property(nonatomic,weak)id<HITTextFieldValidationDelegate> validateDelegate;

- (void)addValidateRegular:(NSString*)regular withMessage:(NSString*)message;
- (BOOL)validity;

@end


