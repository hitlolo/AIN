//
//  HITMarqueeLabel.h
//  AIN
//
//  Created by Lolo on 16/7/9.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HITMarqueeLabel : UIScrollView
@property(nonatomic,strong)NSString* text;
@property(nonatomic,strong)UIFont* textFont;
@property(nonatomic,strong)UIColor* textColor UI_APPEARANCE_SELECTOR;
@end
