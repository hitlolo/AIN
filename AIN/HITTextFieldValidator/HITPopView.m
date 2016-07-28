//
//  HITPopView.m
//  hitDota
//
//  Created by Lolo on 16/1/1.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITPopView.h"

#pragma mark - Arrow View

@interface ArrowView : UIView
@property(nonatomic,strong)UIColor* drawColor;
@end

@implementation ArrowView

- (instancetype)initWithColor:(UIColor*)color{
    self = [super initWithFrame:CGRectMake(0, 0, 20, 12)];
    if (self) {
        _drawColor = color;
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.8f;
    }
    return self;
}
- (void)drawRect:(CGRect)rect{

    //定义画图的path
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    //CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 7.0f, [UIColor darkGrayColor].CGColor);
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(10, 2)];
    [path addLineToPoint:CGPointMake(0, 12)];
    [path addLineToPoint:CGPointMake(20, 12)];
    [path closePath];
    
    [self.drawColor setFill];
    [path fill];
    [self.drawColor setStroke];
    [path stroke];
    
    UIGraphicsPopContext();
}

- (void)setDrawColor:(UIColor *)drawColor{
    _drawColor = drawColor;
    [self setNeedsDisplay];
}

@end

#pragma mark - Pop View

@interface HITPopView()

@property(nonatomic,assign)CGRect     showOnRect;
//subviews
@property(nonatomic,strong)ArrowView* arrowView;
@property(nonatomic,strong)UIView*    messageContainer;
@property(nonatomic,strong)UILabel*   messageLabel;
@property(nonatomic,strong)UITapGestureRecognizer* dismissTap;
//state
@property(nonatomic,assign,getter = isShowing)BOOL showing;
@property(nonatomic,strong)NSLayoutConstraint* messageWidthConstraints;
@end

@implementation HITPopView

#pragma mark init

- (instancetype)init{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}


- (void)prepare{
    
    [self setUpDefaults];
    [self setUpViews];
    [self setUpConstraints];
    
}

- (void)setUpDefaults{
    //default setting
    _showing = NO;
    _showOnRect = CGRectZero;
    _message = nil;
    _messageColor = [UIColor whiteColor];
    _messageBackgroundColor = [UIColor colorWithRed:0.8196f green:0.7333f blue:0.6314f alpha:1.0f];
    //background
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark layout

- (void)setUpViews{

    [self addSubview:self.arrowView];
    [self insertSubview:self.messageContainer belowSubview:_arrowView];
    //[_messageContainer addSubview:self.messageLabel];
    [self addSubview:self.messageLabel];
}

- (void)setUpConstraints{

    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    //
    self.arrowView.translatesAutoresizingMaskIntoConstraints = NO;
    [_arrowView.widthAnchor constraintEqualToConstant:20].active = YES;
    [_arrowView.heightAnchor constraintEqualToConstant:12].active = YES;
    [_arrowView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_arrowView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    
    //
    self.messageContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [_messageContainer.heightAnchor constraintEqualToAnchor:_messageLabel.heightAnchor multiplier:1.0f constant:5].active = YES;
    [_messageContainer.widthAnchor constraintEqualToAnchor:_messageLabel.widthAnchor multiplier:1.0f constant:10].active = YES;
    [_messageContainer.centerXAnchor constraintEqualToAnchor:_messageLabel.centerXAnchor].active = YES;
    [_messageContainer.centerYAnchor constraintEqualToAnchor:_messageLabel.centerYAnchor].active = YES;
    
    
    //
    _messageLabel.translatesAutoresizingMaskIntoConstraints=NO;
    self.messageWidthConstraints = [_messageLabel.widthAnchor constraintLessThanOrEqualToConstant:50];
    self.messageWidthConstraints.active = YES;
    [_messageLabel.trailingAnchor constraintEqualToAnchor:_arrowView.trailingAnchor].active = YES;
    [_messageLabel.topAnchor constraintEqualToAnchor:_arrowView.bottomAnchor].active = YES;

}



- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    if (self.superview) {

        [self.superview bringSubviewToFront:self];
        self.messageWidthConstraints.constant = self.superview.bounds.size.width;
        [self.topAnchor constraintEqualToAnchor:self.superview.bottomAnchor constant:-5].active = YES;
        [self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor constant:-5].active = YES;
        
        [self.window addGestureRecognizer:self.dismissTap];
    }
    
}



#pragma mark getters& setters

- (ArrowView*)arrowView{
    if (_arrowView == nil) {
        _arrowView = [[ArrowView alloc]initWithColor:_messageBackgroundColor];
    }
    return _arrowView;
}

- (UIView*)messageContainer{
    if (_messageContainer == nil) {
        _messageContainer = [[UIView alloc] initWithFrame:CGRectZero];
        _messageContainer.backgroundColor = _messageBackgroundColor;
        _messageContainer.layer.cornerRadius = 5.0;
        _messageContainer.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
        _messageContainer.layer.shadowRadius = 5.0;
        _messageContainer.layer.shadowOpacity = 1.0;
        _messageContainer.layer.shadowOffset = CGSizeMake(0, 0);
    }
    return _messageContainer;
}

- (UILabel*)messageLabel{
    if (_messageLabel == nil) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        _messageLabel.numberOfLines = 0;
        _messageLabel.text = _message;
        _messageLabel.textColor = _messageColor;
        _messageLabel.backgroundColor = [UIColor clearColor];
    }
    return _messageLabel;
}

- (UITapGestureRecognizer*)dismissTap{
    if (_dismissTap == nil) {
        _dismissTap = [[UITapGestureRecognizer alloc]init];
        _dismissTap.numberOfTapsRequired = 1;
        [_dismissTap addTarget:self  action:@selector(dismiss)];
 
    }
    return _dismissTap;
}

- (void)setMessage:(NSString *)message{
    _message = message;
    _messageLabel.text = message;
    [self setNeedsUpdateConstraints];
}

- (void)setMessageColor:(UIColor *)messageColor{
    _messageColor = messageColor;
}

- (void)setMessageBackgroundColor:(UIColor *)messageBackgroundColor{
    _messageBackgroundColor = messageBackgroundColor;
    _messageContainer.backgroundColor = messageBackgroundColor;
    self.arrowView.drawColor = messageBackgroundColor;

}

#pragma mark public methods

- (void)showOnView:(UIView *)parentView withPosition:(CGRect)showRect{
    self.showOnRect = showRect;
    self.showing = YES;
    //if (!self.superview) {
        [parentView addSubview:self];
        [parentView bringSubviewToFront:self];
   // }
    //self.hidden = NO;
   
}

- (void)dismiss{
    self.showing = NO;
    [self.window removeGestureRecognizer:self.dismissTap];
    [self removeFromSuperview];
   // self.hidden = YES;
}
@end

