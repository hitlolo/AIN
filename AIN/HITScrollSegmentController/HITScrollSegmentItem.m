//
//  HITScrollSegmentItem.m
//  HITScrollListController
//
//  Created by Lolo on 16/5/12.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITScrollSegmentItem.h"

#define minimumFontSize 13
#define maxmumFontSize 14

@implementation HITScrollSegmentItem

- (instancetype)init{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare{
    self.layoutMargins = UIEdgeInsetsMake(8, 8, 8, 8);
    self.textAlignment = NSTextAlignmentCenter;
    self.minimumScaleFactor = 0.5;
    self.font = [self defaultFont];
    //self.layer.borderColor = self.textColor.CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 2.0f;
    self.layer.masksToBounds = YES;
    
}

- (CGSize)intrinsicContentSize{
    return CGSizeMake(80, 25);
}

- (void)setTextColor:(UIColor *)textColor{
    [super setTextColor:textColor];
    self.layer.borderColor = textColor.CGColor;
}

- (void)setHighlighted:(BOOL)highlighted{
    
//    CGFloat scale = [self scaleFactor];
//    
//    if (!highlighted) {
//        self.font = [self defaultFont];
//
//        self.transform = CGAffineTransformMakeScale(scale, scale);
//        [UIView animateWithDuration:0.2f animations:^{
//            self.transform = CGAffineTransformMakeScale(1.0, 1.0);
//        }];
//    }
//    else{
//        self.font = [self highlightedFont];
//        self.transform = CGAffineTransformMakeScale(scale - 1.0, scale - 1.0);
//        [UIView animateWithDuration:0.2f animations:^{
//            self.transform = CGAffineTransformMakeScale(1.0, 1.0);
//        }];
//    }
    [super setHighlighted:highlighted];
    
    if (!highlighted) {
        self.layer.borderColor = self.textColor.CGColor;
    }
    else{
        self.layer.borderColor = self.highlightedTextColor.CGColor;
    }
    

}

- (UIFont*)defaultFont{
    return [UIFont systemFontOfSize:minimumFontSize];
}

- (UIFont*)highlightedFont{
    return [UIFont systemFontOfSize:maxmumFontSize];
}

- (void)setHighlightProgress:(CGFloat)highlightProgress{
    _highlightProgress = highlightProgress;
    CGFloat fontSize = (maxmumFontSize - minimumFontSize) * highlightProgress;
    fontSize += minimumFontSize;
    [self setFont:[UIFont systemFontOfSize:fontSize]];
    
}

- (CGPoint)scaleFactor{
    CGRect rect = [self.text boundingRectWithSize:CGSizeMake(100, 100)
                                          options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName:[self defaultFont]}
                                          context:nil];
    CGRect rectHighlighted = [self.text boundingRectWithSize:CGSizeMake(100, 100)
                                                     options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                                  attributes:@{NSFontAttributeName:[self highlightedFont]}
                                                     context:nil];
    
    CGFloat x = rectHighlighted.size.width / rect.size.width;
    CGFloat y = rectHighlighted.size.height / rect.size.height;
    return CGPointMake(x, y);
}



@end
