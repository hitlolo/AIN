//
//  AINCommandCenterController.h
//  AIN
//
//  Created by Lolo on 16/5/25.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AINBaseTableController.h"

#import "AINCarouselView.h"

@protocol AINCommandCenterDelegate <NSObject>
- (void)commandCenterDidSelectedIndex:(NSInteger)index;
@end

@interface AINCommandCenterController : AINBaseTableController

@property (strong, nonatomic) IBOutlet AINCarouselView *carouselHeader;
@property(nonatomic,weak)id<AINCommandCenterDelegate> commandDelegate;

@end
