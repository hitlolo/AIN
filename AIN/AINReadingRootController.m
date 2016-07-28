//
//  AINReadingViewController.m
//  AIN
//
//  Created by Lolo on 16/6/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINReadingRootController.h"
#import "AINReadingController.h"
#import "AINColumnDelegate.h"


@interface AINReadingRootController ()
@property(nonatomic,strong)AINColumnDelegate* columnDelegate;
@end

@implementation AINReadingRootController

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self =[super initWithCoder:aDecoder];
    if (self) {
        
        AINReadingController* readController = [[AINReadingController alloc]init];
        readController.delegate = self.columnDelegate;
        readController.title = @"Reading";
        [readController setHidesBottomBarWhenPushed:YES];
        [self setViewControllers:@[readController]];
        [self setHidesBottomBarWhenPushed:YES];
    }
    return self;
}

- (AINColumnDelegate*)columnDelegate{
    if (_columnDelegate == nil) {
        _columnDelegate = [[AINColumnDelegate alloc]init];
    }
    return _columnDelegate;
}


@end
