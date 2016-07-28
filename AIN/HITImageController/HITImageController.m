//
//  HITImageController.m
//  AIN
//
//  Created by Lolo on 16/6/3.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITImageController.h"
#import "HITImageControllerTransition.h"
#import "HITZoomImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HITImageController ()
<UIScrollViewDelegate,HITZoomImageViewDismissDelegate>
//transition
@property(nonatomic,strong)HITImageControllerTransition* transition;
//view
@property(nonatomic,strong)UIScrollView* scrollview;
@property(nonatomic,strong)NSMutableArray* imageViews;

//toolbar
@property(nonatomic,strong)UIToolbar* toolbar;
@property(nonatomic,strong)UILabel* indexLabel;
@property(nonatomic,strong)UIButton* saveButton;
@property(nonatomic,strong)UIButton* dismissButton;
@end

@implementation HITImageController

- (instancetype)init{
    self = [super init];
    if (self) {
        _transition = [[HITImageControllerTransition alloc]init];
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = _transition;
    }
    return self;
}

- (instancetype)initWithDatasource:(id<HITImageControllerDatasource>)datasource Delegate:(id<HITImageControllerDelegate>)delegate{
    self = [self init];
    if (self) {
        self.dataSource = datasource;
        self.delegate = delegate;
        self.startIndex = 0;
    }
    return self;
}

- (instancetype)initWithDatasource:(id<HITImageControllerDatasource>)datasource Delegate:(id<HITImageControllerDelegate>)delegate startIndex:(NSInteger)index{
    self = [self initWithDatasource:datasource Delegate:delegate];
    if (self) {
        self.startIndex = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9f];
    [self prepareConstraints];
    
    [self loadData];
}

- (void)loadView{
    [super loadView];
    
    [self.view addSubview:self.scrollview];
    [self.view addSubview:self.toolbar];
}

- (void)prepareConstraints{
    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.toolbar.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.toolbar.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden{
    //如果隐藏status bar 提示消息需改用其他方式。 不能用JDStatusBarNotification
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleDefault;
}


#pragma mark - load image data

- (void)loadData{
    self.count = [self.dataSource numberOfImagesForImageController:self];
    self.currentIndex = self.startIndex;
    self.indexLabel.text = [NSString stringWithFormat:@"%d/%d",self.currentIndex+1,self.count];
    
    for (int i = 0; i < self.count; i++) {
        CGRect rect = CGRectMake(0 + i * self.view.width, 0, self.view.width, self.view.height);
        HITZoomImageView* zoomImageView = [[HITZoomImageView alloc]initWithFrame:rect];
        //imageView.contentMode = UIViewContentModeScaleAspectFit;
        NSURL* url = [self.dataSource imageController:self urlOfImageAtIndex:i];
        [zoomImageView.imageView sd_setImageWithURL:url];
        zoomImageView.dismissDelegate = self;
        [self.scrollview addSubview:zoomImageView];
        [self.imageViews addObject:zoomImageView];
    }
    [self.scrollview setContentSize:CGSizeMake(self.view.width * _count, self.view.height)];
    [self.scrollview setContentOffset:CGPointMake(self.view.width * _currentIndex, 0)];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageController:didSlideToImageIndex:)]) {
        [self.delegate imageController:self didSlideToImageIndex:self.currentIndex];
    }
}

#pragma mark - Setter & Getter

- (UIScrollView*)scrollview{
    if (_scrollview == nil) {
        _scrollview = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        _scrollview.pagingEnabled = YES;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.delegate = self;
        _scrollview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _scrollview;
}

- (NSMutableArray*)imageViews{
    if (_imageViews == nil) {
        _imageViews = [[NSMutableArray alloc]init];
    }
    return _imageViews;
}

- (UIToolbar*)toolbar{
    if (_toolbar == nil) {
        _toolbar = [[UIToolbar alloc]init];
        [_toolbar setBarStyle:UIBarStyleBlackTranslucent];
        UIBarButtonItem* dismissItem = [[UIBarButtonItem alloc]initWithCustomView:self.dismissButton];
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem* indexItem = [[UIBarButtonItem alloc]initWithCustomView:self.indexLabel];
        UIBarButtonItem* saveItem = [[UIBarButtonItem alloc]initWithCustomView:self.saveButton];
        [_toolbar setItems:@[dismissItem,flexibleItem,indexItem,flexibleItem,saveItem]];
    }
    return _toolbar;
}

- (UILabel*)indexLabel{
    if (_indexLabel == nil) {
        _indexLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        _indexLabel.text = @"0/0";
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.textColor = [UIColor lightGrayColor];
        //[_indexLabel sizeToFit];
        [_indexLabel setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
        //[_indexLabel sizeToFit];
    }
    return _indexLabel;
}

- (UIButton*)saveButton{
    if (_saveButton == nil) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setFrame:CGRectMake(0, 0, 40, 40)];
        UIImage* image = [UIImage imageNamed:@"ic_desc_gray"];
        [_saveButton setImage:image forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(saveImageToGallery) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (UIButton*)dismissButton{
    if (_dismissButton == nil) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dismissButton setFrame:CGRectMake(0, 0, 30, 30)];
        UIImage* image = [UIImage imageNamed:@"navi_back_n@3x"];
        [_saveButton setImage:image forState:UIControlStateNormal];
        [_dismissButton setImage:image forState:UIControlStateNormal];
        [_dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissButton;
}


#pragma mark - Button Actions

- (void)saveImageToGallery{
    HITZoomImageView* zoomImageView = self.imageViews[self.currentIndex];
    UIImage* image = zoomImageView.imageView.image;
    [JDStatusBarNotification showWithStatus:@"保存中..." styleName:JDStatusBarStyleWarning];
    [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleGray];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    // Was there an error?
   
    if (error == NULL) {
        [JDStatusBarNotification showWithStatus:@"保存成功！" dismissAfter:3 styleName:JDStatusBarStyleSuccess];
    }
    else if (error) {

        [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:3 styleName:JDStatusBarStyleError];
    }
}

- (void)dismiss{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageController:willDissmissFromImageIndex:)]) {
        [self.delegate imageController:self willDissmissFromImageIndex:self.currentIndex];
    }
    
    HITZoomImageView* zoomImageView = self.imageViews[self.currentIndex];
    //imageview.contentMode = UIViewContentModeCenter;
    self.view = zoomImageView.imageView;
    [self.toolbar setHidden:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - scrollview delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index =  scrollView.contentOffset.x/scrollView.width;
    if (self.currentIndex != index) {
        HITZoomImageView* zoomImageView = self.imageViews[self.currentIndex];
        [zoomImageView scaleBack];
        self.currentIndex = index;
        self.indexLabel.text = [NSString stringWithFormat:@"%d/%d",self.currentIndex+1,self.count];
        if (self.delegate && [self.delegate respondsToSelector:@selector(imageController:didSlideToImageIndex:)]) {
            [self.delegate imageController:self didSlideToImageIndex:self.currentIndex];
        }
    }
   
}


@end
