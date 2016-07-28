//
//  HITTextValidator.h
//  hitDota
//
//  Created by Lolo on 16/1/2.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol HITTextFieldValidationDelegate<NSObject>

@optional

- (void)validateWillBegin:(UITextField*)textField;
- (void)validateDidSuccessed:(UITextField*)textField;
- (void)validateDidFailed:(UITextField*)textField;
- (void)validateDidReturnClicked:(UITextField*)textField;
@end


@interface HITTextValidator : NSObject<UITextFieldDelegate>

@property(nonatomic,weak)id<HITTextFieldValidationDelegate> delegate;


- (void)setValidateMessageBackgroundColor:(UIColor*)color;
- (void)setValidateMessageTextColor:(UIColor*)color;
- (void)addValidateRegular:(NSString*)regular withMessage:(NSString*)message;
- (void)showPopMessageOnView:(UIView*)parentView onPosition:(CGRect)onRect;
- (BOOL)isValidated;
@end
