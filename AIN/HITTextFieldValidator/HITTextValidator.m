//
//  HITTextValidator.m
//  hitDota
//
//  Created by Lolo on 16/1/2.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITTextValidator.h"
#import "HITPopView.h"

typedef NSString* Regular;
typedef NSString* Message;
typedef NSDictionary<Regular,Message> RMDictionary;

NSString* const ValidatorKeyForRegular = @"regular";
NSString* const ValidatorKeyForMessage = @"message";

@interface HITTextValidator()

@property(nonatomic, strong)HITPopView *popMessageView;
@property(nullable,nonatomic,strong)NSMutableArray<RMDictionary*> *regulars;
@property(nonatomic,assign,getter=isValidated)BOOL validity;

@end

@implementation HITTextValidator

- (instancetype)init{
    self = [super init];
    if (self) {
        _validity = NO;
    }
    return self;
}

#pragma mark - setter & getter

- (HITPopView*)popMessageView{
    if (_popMessageView == nil) {
        _popMessageView = [[HITPopView alloc]init];
    }
    return _popMessageView;
}

- (NSMutableArray*)regulars{
    if (_regulars == nil) {
        _regulars = [NSMutableArray new];
    }
    return _regulars;
}

#pragma mark - regular matching

- (void)addValidateRegular:(NSString *)regular withMessage:(NSString *)message{
    RMDictionary* temDic = @{
                             ValidatorKeyForRegular:regular,
                             ValidatorKeyForMessage:message
                             };
    [self.regulars addObject:temDic];

}

- (BOOL)validating:(NSString*)string{
    for (RMDictionary* regularMessageDic in self.regulars) {
        
        NSString* regular = [regularMessageDic objectForKey:ValidatorKeyForRegular];
        NSString* message = [regularMessageDic objectForKey:ValidatorKeyForMessage];
        BOOL isEmpty = (string.length == 0 || [string isEqualToString:@""]);
        BOOL isValidity = [self validateString:string toRegular:regular];
        if (isEmpty) {
            return NO;
        }
        if (!isValidity) {
            self.popMessageView.message = message;
            return NO;
        }
    }
    return YES;
}

- (BOOL)validateString:(NSString*)string toRegular:(NSString*)regular{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    return [predicate evaluateWithObject:string];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSString* stringToValidate = textField.text;
    BOOL valididy = [self validating:stringToValidate];
    if ([stringToValidate isEqualToString:@""]) {
        textField.rightViewMode = UITextFieldViewModeNever;
        return YES;
    }
    else if (valididy) {
        textField.rightViewMode = UITextFieldViewModeNever;
    }
    else{
        textField.rightViewMode = UITextFieldViewModeWhileEditing;
    }

    return YES;
}
//
//- (void)textFieldDidBeginEditing:(UITextField *)textField{
//    NSLog(@"textFieldDidBeginEditing");
//}
//

//
//- (void)textFieldDidEndEditing:(UITextField *)textField{
//   NSLog(@"textFieldDidEndEditing");
//}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    self.validity = NO;
    if ([self.delegate respondsToSelector:@selector(validateDidFailed:)]) {
        [self.delegate validateDidFailed:textField];
    }
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([self.delegate respondsToSelector:@selector(validateWillBegin:)]) {
        [self.delegate validateWillBegin:textField];
    }
    
    if ([self.popMessageView isShowing]) {
        [self.popMessageView dismiss];
    }
    //regular matching
    NSMutableString* stringToValidate = [textField.text mutableCopy];
    //remove characters
    if ([string isEqualToString:@""]) {
        [stringToValidate deleteCharactersInRange:range];
    }
    //append characters
    else{
        [stringToValidate insertString:string atIndex:range.location];
    }
    
    _validity = [self validating:stringToValidate];
    if (_validity) {
        if ([self.delegate respondsToSelector:@selector(validateDidSuccessed:)]) {
            [self.delegate validateDidSuccessed:textField];
        }
        textField.rightViewMode = UITextFieldViewModeNever;
    }
    else{
        if ([self.delegate respondsToSelector:@selector(validateDidFailed:)]) {
            [self.delegate validateDidFailed:textField];
        }
        textField.rightViewMode = UITextFieldViewModeWhileEditing;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{

    textField.rightViewMode = UITextFieldViewModeNever;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([self.delegate respondsToSelector:@selector(validateDidReturnClicked:)]) {
        [self.delegate validateDidReturnClicked:textField];
    }
    
    textField.rightViewMode = UITextFieldViewModeNever;
    [textField resignFirstResponder];
    if ([self.popMessageView isShowing]) {
        [self.popMessageView dismiss];
    }
    return YES;
}

#pragma mark - Show pop message
- (void)showPopMessageOnView:(UIView *)parentView onPosition:(CGRect)onRect{
        [self.popMessageView showOnView:parentView withPosition:onRect];
}

#pragma mark - public methods

- (void)setValidateMessageBackgroundColor:(UIColor*)color{
    [self.popMessageView setMessageBackgroundColor:color];
}
- (void)setValidateMessageTextColor:(UIColor*)color{
    [self.popMessageView setMessageColor:color];
}

@end
