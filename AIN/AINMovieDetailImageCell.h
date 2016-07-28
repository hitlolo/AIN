//
//  AINMovieDetailImageCell.h
//  AIN
//
//  Created by Lolo on 16/7/10.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HITImageController/HITImageController.h"
@interface AINMovieDetailImageCell : UITableViewCell
<HITImageControllerDatasource,HITImageControllerDelegate>

@property(nonatomic,weak)id<HITImageTappedDelegate> delegate;
- (void)setPhotos:(NSArray*)photos;
@end
