//
//  HITZoomImageView.m
//  AIN
//
//  Created by Lolo on 16/6/11.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITZoomImageView.h"

@interface HITZoomImageView()
<UIScrollViewDelegate>
@property(nonatomic,strong,readwrite)UIImageView* imageView;
@end

@implementation HITZoomImageView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        self.maximumZoomScale = 3.0f;
        self.minimumZoomScale = 1.0f;
        [self addSubview:self.imageView];
    }
    return self;
}

- (UIImageView*)imageView{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UITapGestureRecognizer* twoTap = [[UITapGestureRecognizer alloc]init];
        twoTap.numberOfTapsRequired = 2;
        [twoTap addTarget:self action:@selector(zoom:)];
        [_imageView addGestureRecognizer:twoTap];
        [_imageView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer* oneTap = [[UITapGestureRecognizer alloc]init];
        oneTap.numberOfTapsRequired = 1;
        [oneTap requireGestureRecognizerToFail:twoTap];
        [oneTap addTarget:self action:@selector(dismiss:)];
        [_imageView addGestureRecognizer:oneTap];

    }
    return _imageView;
}

- (void)zoom:(UITapGestureRecognizer*)tap{

    CGFloat scale = self.zoomScale;
    if (scale == 1.0f) {
        [self setZoomScale:self.maximumZoomScale animated:YES];
    }
    
    else if (scale != 1.0) {
        [self setZoomScale:1.0f animated:YES];
    }
}


- (void)dismiss:(UITapGestureRecognizer*)tap{
    if (self.zoomScale == 1.0f) {
        [self.dismissDelegate dismiss];
    }
}

- (void)scaleBack{
     [self setZoomScale:1.0f animated:NO];
}


#pragma mark -  scrollview delegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}



@end
