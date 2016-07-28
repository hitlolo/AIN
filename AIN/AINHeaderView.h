//
//  AINHeaderView.h
//  AIN
//
//  Created by Lolo on 16/7/10.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AINHeaderView : UITableViewHeaderFooterView
@property(nonatomic,strong)UIColor* backgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic,strong)UIColor* textColor UI_APPEARANCE_SELECTOR;
- (void)setMessage:(NSString*)message;
@end
