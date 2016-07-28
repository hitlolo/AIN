//
//  HITTreeView.h
//  One
//
//  Created by Lolo on 16/4/18.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HITRefreshView.h"
@interface HITTreeView : UIImageView<HITRefreshView>

@property(nonatomic, assign)CGFloat progress;

@end
