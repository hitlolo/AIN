//
//  HITTextValidationFiled.m
//  hitDota
//
//  Created by Lolo on 16/1/2.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITTextValidationFiled.h"
#import "HITTextValidator.h"
@interface HITTextValidationFiled()

@property(nonatomic,strong)HITTextValidator* validator;

@end

@implementation HITTextValidationFiled

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self prepare];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare{
    
    self.clipsToBounds = NO;
    self.borderStyle = UITextBorderStyleRoundedRect;
    
    UIButton *alertButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [alertButton addTarget:self action:@selector(alertButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ic_alert_background"
                                                     ofType:@"png"];
    [alertButton setBackgroundImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
    [alertButton setTitle:@"!" forState:UIControlStateNormal];
    alertButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    self.rightView = alertButton;
    self.rightViewMode = UITextFieldViewModeNever;
}


#pragma mark - override methods
- (CGRect)rightViewRectForBounds:(CGRect)bounds{
    CGRect textRect = [super rightViewRectForBounds:bounds];
    textRect.origin.x -= 5;
    return textRect;
}

#pragma mark - button event

- (void)alertButtonClicked:(UIButton*)sender{
    CGRect onRect = [self convertRect:self.rightView.frame toView:self];
    [self.validator showPopMessageOnView:self onPosition:onRect];
}

#pragma mark - private method

- (void)addValidateRegular:(NSString *)regular withMessage:(NSString *)message{
    [self.validator addValidateRegular:regular withMessage:message];
}


#pragma mark - Setter & Getter


- (void)setText:(NSString *)text{
    [super setText:text];
    if (text == nil || [text isEqualToString:@""]) {
        [self.delegate textFieldShouldClear:self];
    }
}

- (HITTextValidator*)validator{
    if (_validator == nil) {
        _validator = [[HITTextValidator alloc]init];
        self.delegate = _validator;
    }
    return _validator;
}

- (BOOL)validity{
    return [self.validator isValidated];
}

- (void)setMessageTextColor:(UIColor *)messageTextColor{
    _messageTextColor = messageTextColor;
    [self.validator setValidateMessageTextColor:messageTextColor];
}

- (void)setMessageBackgroundColor:(UIColor *)messageBackgroundColor{
    _messageBackgroundColor = messageBackgroundColor;
    [self.validator setValidateMessageBackgroundColor:messageBackgroundColor];
}

- (void)setValidateDelegate:(id<HITTextFieldValidationDelegate>)validateDelegate{
    _validateDelegate = validateDelegate;
    self.validator.delegate = validateDelegate;
}



@end
