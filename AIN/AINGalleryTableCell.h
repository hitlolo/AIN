//
//  AINGalleryTableCell.h
//  AIN
//
//  Created by Lolo on 16/6/2.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HITImageController/HITImageController.h"

@class AINPainting;
@interface AINGalleryTableCell : UITableViewCell
<HITImageControllerDatasource>

@property(nonatomic,weak)id<HITImageTappedDelegate> delegate;
@property(nonatomic,strong)UIImage* backgroundImage UI_APPEARANCE_SELECTOR;
@property(nonatomic,strong)UIColor* mottoTextColor  UI_APPEARANCE_SELECTOR;

- (void)setPainting:(AINPainting*)painting;

@end
