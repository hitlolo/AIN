//
//  AINMonthPickerController.h
//  AIN
//
//  Created by Lolo on 16/6/15.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AINBaseController.h"
@class AINMonthPickerController;
@protocol AINMonthPickerDatasource <NSObject>
//专栏首刊年
- (NSInteger)columnFirstYear;
@end

@protocol AINMonthPickerDelegate <NSObject>
- (void)monthPickerController:(AINMonthPickerController*)monthPicker didSelectedDate:(NSString*)selectedDate;
@end


@interface AINMonthPickerController : AINBaseController
@property(nonatomic,weak)id<AINMonthPickerDelegate> delegate;
@property(nonatomic,weak)id<AINMonthPickerDatasource> datasource;
@end


