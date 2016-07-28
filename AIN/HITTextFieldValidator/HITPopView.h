//
//  HITPopView.h
//  hitDota
//
//  Created by Lolo on 16/1/1.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HITPopView : UIView

@property(nonatomic,strong)UIColor*  messageColor;
@property(nonatomic,strong)UIColor*  messageBackgroundColor;
@property(nonatomic,strong)NSString* message;

- (BOOL)isShowing;
- (void)showOnView:(UIView*)parentView withPosition:(CGRect)showRect;
- (void)dismiss;
@end
