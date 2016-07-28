//
//  UIScreen+Helper.m
//  HITLibrary
//
//  Created by Lolo on 16/5/21.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "UIScreen+FrameHelper.h"

@implementation UIScreen (FrameHelper)

// frame height
- (CGFloat) height
{
    return self.bounds.size.height;
}

//frame width
- (CGFloat) width
{
    return self.bounds.size.width;
}


@end
