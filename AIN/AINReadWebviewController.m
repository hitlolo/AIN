//
//  AINReadWebviewController.m
//  AIN
//
//  Created by Lolo on 16/6/27.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINReadWebviewController.h"
#import "RTSpinKitView.h"
#import "AINBackgroundView.h"
#import "AINRootController.h"

#import "HITImageController/HITImageController.h"
#import "WebViewJavascriptBridge.h"
@interface AINReadWebviewController ()
<UIWebViewDelegate,
UIGestureRecognizerDelegate,
HITImageControllerDatasource,
HITImageControllerDelegate>
@property(nonatomic,strong)AINBackgroundView* backgroundView;
@property(nonatomic,strong)RTSpinKitView* spinner;
@property(nonatomic,strong)UIWebView* articleWebView;


@property (strong, nonatomic) UISwipeGestureRecognizer* nextPageGesture;
@property (strong, nonatomic) UISwipeGestureRecognizer* lastPageGesture;
@property (assign, nonatomic) BOOL isReadOnPageMode;

@property (assign, nonatomic) NSInteger currentPageIndex;
@property (assign, nonatomic) CGFloat pageWidth;
//toolbar
@property (strong, nonatomic) UIBarButtonItem* pageToolButton;

@property (assign, nonatomic) BOOL articleLoaded;

@property (strong, nonatomic) WebViewJavascriptBridge* bridge;
@property (strong, nonatomic) NSMutableArray* imageUrlsArray;
//@property (strong, nonatomic) NSMutableArray* imageFrameArray;
@property (assign, nonatomic) CGRect imageStartFrame;

@end

@implementation AINReadWebviewController

- (void)loadView{
    self.view = self.backgroundView;
    [self.view addSubview:self.articleWebView];
    [self.view addSubview:self.spinner];
    self.spinner.center = self.view.center;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateThemeWhenNotificationReceived)
                                                name:mAINSettingManagerThemeChangeNotification
                                              object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateReadModeWhenNotificationReceived)
                                                name:mAINSettingManagerReadModeChangeNotification
                                              object:nil];
    
    
    [self prepare];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self.navigationController setHidesBarsOnSwipe:YES];
    
    [self.rootController setHideCustomBarOnSwipe:NO];
    [self.rootController setCustomToolbarHidden:YES];
    if (!_articleLoaded) {
        [self beginLoading];
        _articleLoaded = YES;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[self.navigationController setHidesBarsOnSwipe:NO];
    [self.rootController setHideCustomBarOnSwipe:YES];
   
    
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    self.articleWebView = nil;
}


- (void)updateThemeWhenNotificationReceived{
    //self.view.backgroundColor = [[[AINSettingManager sharedManager]themeManager]backgroundColor];
    [self beginLoading];
}

- (void)updateReadModeWhenNotificationReceived{
    BOOL readInPage = [[AINSettingManager sharedManager]readInPageMode];
    [self setReadingMode:readInPage];
    [self beginLoading];

}

- (void)prepare{
    BOOL readInPage = [[AINSettingManager sharedManager]readInPageMode];
    [self setReadingMode:readInPage];
    
    [self prepareWebviewImageHandler];
    

}


- (void)prepareWebviewImageHandler{
    _bridge = [WebViewJavascriptBridge bridgeForWebView:self.articleWebView];
    
    [_bridge setWebViewDelegate:self];
    
    [self.bridge registerHandler:@"imagesDidLoad" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self.imageUrlsArray removeAllObjects];        
        [self.imageUrlsArray addObjectsFromArray:data];

    }];
    
    [self.bridge registerHandler:@"imageDidClicked" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self imageDidClicked:data];
    }];
    
//    [self.bridge callHandler:@"JS Echo" data:@"hitlolo" responseCallback:^(id responseData) {
//         NSLog(@"ObjC received response: %@", responseData);
//    }];

}

//- (void)prepareConstraints{
//    _articleWebView.translatesAutoresizingMaskIntoConstraints = NO;
//    _articleWebView.
//}


#pragma mark - webview loaddata & delegate

- (void)beginLoading{
    
    [self.spinner startAnimating];
    
    [self webviewStartLoading];
   
    
}

- (void)endLoading{
    
    [self.spinner stopAnimating];
}


- (void)webviewStartLoading{
    
    __weak typeof(self)weakSelf = self;
    void (^completion)(NSString* html) = ^(NSString* html){
        [weakSelf.articleWebView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
    };
    self.articleLoadBlock(completion);
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    

    [self updatePageIndex:0];
    [self endLoading];
}


#pragma mark - Getter& Setter

- (AINBackgroundView*)backgroundView{
    if (_backgroundView == nil) {
        CGRect frame = CGRectMake(0, 0, self.screenSize.width, self.screenSize.height);
        _backgroundView = [[AINBackgroundView alloc]initWithFrame:frame];
    }
    return _backgroundView;
}

- (RTSpinKitView*)spinner{
    if (_spinner == nil) {
        _spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStylePulse];
        _spinner.color = globalControlTintColor;
        [_spinner stopAnimating];
        [_spinner setHidesWhenStopped:YES];
    }
    return _spinner;
}

- (UIWebView*)articleWebView{
    if (_articleWebView == nil) {
        CGRect frame = CGRectMake(0, 0, self.screenSize.width, self.screenSize.height);
        _articleWebView = [[UIWebView alloc]initWithFrame:frame];
        _articleWebView.delegate = self;
        _articleWebView.backgroundColor = [UIColor clearColor];
        self.pageWidth = _articleWebView.width;
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
        [tap addTarget:self action:@selector(tapToHideBar:)];
        tap.numberOfTapsRequired = 2;
        tap.delegate = self;
        tap.delaysTouchesEnded = NO;
        tap.cancelsTouchesInView = NO;
        [_articleWebView addGestureRecognizer:tap];
        
        [_articleWebView addGestureRecognizer:self.nextPageGesture];
        [_articleWebView addGestureRecognizer:self.lastPageGesture];
        
    }
    return _articleWebView;
}


- (UISwipeGestureRecognizer*)nextPageGesture{
    if (_nextPageGesture == nil) {
        _nextPageGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipePage:)];
        _nextPageGesture.delegate = self;
        _nextPageGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    }
    return _nextPageGesture;
}

- (UISwipeGestureRecognizer*)lastPageGesture{
    if (_lastPageGesture == nil) {
        _lastPageGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipePage:)];
        _lastPageGesture.delegate = self;
        _lastPageGesture.direction = UISwipeGestureRecognizerDirectionRight;
    }
    return _lastPageGesture;
}

- (UIBarButtonItem*)pageToolButton{
    if (_pageToolButton == nil) {
        _pageToolButton = [[UIBarButtonItem alloc]init];
        _pageToolButton.target = self;
        _pageToolButton.action = @selector(rewindToFirstPage);
    }
    return _pageToolButton;
}

- (NSArray <__kindof UIBarButtonItem *>*)toolbarItems{
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    return @[flexibleItem,self.pageToolButton,flexibleItem];
}

- (NSMutableArray*)imageUrlsArray{
    if (_imageUrlsArray == nil) {
        _imageUrlsArray = [NSMutableArray array];
    }
    return _imageUrlsArray;
}

#pragma mark -page & page gesture deleagte

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return YES;
    }
    
    UISwipeGestureRecognizer* swipeGesture = (UISwipeGestureRecognizer*)gestureRecognizer;
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight && self.currentPageIndex == 0) {
        return NO;
    }
    else{
        return YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)swipePage:(UISwipeGestureRecognizer*)swipeGesture{
    
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self nextPage];
    }
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight){
        [self lastPage];
    }
}

- (void)lastPage{
    if (self.currentPageIndex > 0 ) {
        CGPoint nextOffset = self.articleWebView.scrollView.contentOffset;
        
        NSInteger offset = (NSInteger)nextOffset.x % (NSInteger)self.pageWidth;
        nextOffset.x -= self.pageWidth;
        if (offset != 0) {
            offset = (self.pageWidth - offset);
        }
        nextOffset.x += offset ;
        
        [self.articleWebView.scrollView setContentOffset:nextOffset animated:YES];
        self.currentPageIndex = nextOffset.x / self.pageWidth;
        [self updatePageIndex:nextOffset.x];
    }
}

- (void)nextPage{
    if (self.currentPageIndex < self.articleWebView.pageCount - 1) {
        CGPoint nextOffset = self.articleWebView.scrollView.contentOffset;
        nextOffset.x += self.pageWidth;
        NSInteger offset = (NSInteger)nextOffset.x % (NSInteger)self.pageWidth;
        
        nextOffset.x -= offset;
        [self.articleWebView.scrollView setContentOffset:nextOffset animated:YES];
        [self updatePageIndex:nextOffset.x];
    }
}

- (void)gotoFirstPage{
    CGPoint nextOffset = self.articleWebView.scrollView.contentOffset;
    nextOffset.x = 0;
    [self.articleWebView.scrollView setContentOffset:nextOffset animated:YES];
    [self updatePageIndex:nextOffset.x];
    
}

- (void)updatePageIndex:(CGFloat)offset{
    self.currentPageIndex = offset / self.pageWidth;
    //[self.delegate articleDidChangeToPageIndex:self.currentPageIndex pageCount:self.articleWebView.pageCount];
    
    if (!self.isReadOnPageMode) {
        [self.pageToolButton setTitle:@""];
    }
    else{
        NSInteger pageCount = self.articleWebView.pageCount;
        [self.pageToolButton setTitle:[NSString stringWithFormat:@"%d/%d页",self.currentPageIndex + 1,pageCount]];
        
    }
}



#pragma mark - private method


- (void)setReadingMode:(BOOL)inPageMode{
    
    self.isReadOnPageMode = inPageMode;
    
    
    if (inPageMode) {
        self.articleWebView.paginationMode = UIWebPaginationModeLeftToRight;
        self.articleWebView.pageLength = self.view.width;
        self.articleWebView.paginationBreakingMode = UIWebPaginationBreakingModePage;
        self.articleWebView.scrollView.scrollEnabled = YES;
        [self.nextPageGesture setEnabled:YES];
        [self.lastPageGesture setEnabled:YES];
        [self.pageToolButton setEnabled:YES];
        [self.navigationController setToolbarHidden:NO];
        
    }
    else{
        self.articleWebView.paginationMode = UIWebPaginationModeUnpaginated;
//        self.articleWebView.scrollView.scrollEnabled = NO;
        [self.nextPageGesture setEnabled:NO];
        [self.lastPageGesture setEnabled:NO];
        [self.pageToolButton setEnabled:NO];
        [self.navigationController setToolbarHidden:YES];
        
    }
    
}



#pragma mark - actions


- (void)tapToHideBar:(UITapGestureRecognizer*)tap{
    
    if ([self.navigationController isNavigationBarHidden]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        if (self.pageToolButton.enabled) {
            [self.navigationController setToolbarHidden:NO animated:YES];
        }

    }
    else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
        
    }
}


- (void)rewindToFirstPage{
    [self gotoFirstPage];
}


#pragma mark - uiwebview image handle & image view delegate & datasource

- (void)imageController:(HITImageController *)imagecontroller willDissmissFromImageIndex:(NSInteger)index{
    
    
    NSString *result = [self.articleWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"frameOfImageAtIndex(%d)",index]];
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    //CGRect frame;
    CGFloat x = [[dic objectForKey:@"x"]floatValue];
    CGFloat y = [[dic objectForKey:@"y"]floatValue];
    //CGFloat width = [[dic objectForKey:@"width"]floatValue];
    CGFloat height = [[dic objectForKey:@"height"]floatValue];
    y += self.articleWebView.scrollView.contentInset.top;
    //frame = CGRectMake(x,y,width, height);
    
    if (self.isReadOnPageMode) {
        x -= 13;
        y = -self.articleWebView.scrollView.contentInset.top;;
    }
    else{
        x = 0;
    }
   // NSLog(@"%f,%f,%f,%f",x,y,width,height);

    if (!self.isReadOnPageMode) {
        if (y > self.articleWebView.height) {
            y = self.articleWebView.scrollView.contentOffset.y + y - self.articleWebView.scrollView.contentInset.top;;
            
            if (self.articleWebView.scrollView.contentSize.height - y < self.articleWebView.height) {
                y = self.articleWebView.scrollView.contentSize.height - self.articleWebView.height;
            }
            
            [self.articleWebView.scrollView setContentOffset:CGPointMake(x, y)];
        }
        
        else if (y < -height){
            y = self.articleWebView.scrollView.contentOffset.y + y - self.articleWebView.scrollView.contentInset.top;;
            
            [self.articleWebView.scrollView setContentOffset:CGPointMake(x, y)];
        }

    }
    else{
        
        if (x >= self.articleWebView.width) {
            x = self.articleWebView.scrollView.contentOffset.x + x;
            
            [self.articleWebView.scrollView setContentOffset:CGPointMake(x, y)];
        }
        
        else if (x < 0){
            x = self.articleWebView.scrollView.contentOffset.x + x;
            
            [self.articleWebView.scrollView setContentOffset:CGPointMake(x, y)];
        }

    }
    
    
   
}

- (NSInteger)numberOfImagesForImageController:(HITImageController *)imagecontroller{
    return [self.imageUrlsArray  count];
}

- (NSURL*)imageController:(HITImageController *)imagecontroller urlOfImageAtIndex:(NSInteger)index{
    NSURL* url = [NSURL URLWithString:self.imageUrlsArray[index]];
    return url;
}

- (CGRect)imageController:(HITImageController *)imagecontroller originalFrameOfImageAtIndex:(NSInteger)index{
    

    NSString *result = [self.articleWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"frameOfImageAtIndex(%d)",index]];
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    CGRect frame;
    CGFloat x = [[dic objectForKey:@"x"]floatValue];
    CGFloat y = [[dic objectForKey:@"y"]floatValue];
    CGFloat width = [[dic objectForKey:@"width"]floatValue];
    CGFloat height = [[dic objectForKey:@"height"]floatValue];
    
 
    //x -= self.articleWebView.scrollView.contentOffset.x;
    y += self.articleWebView.scrollView.contentInset.top;
    frame = CGRectMake(x,y,width, height);
  
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    
//
//    __block CGRect frame;
//
////    dispatch_group_enter(group);
//    
//    dispatch_group_async(group, queue, ^{
//        [self.bridge callHandler:@"frameOfImageAtIndex" data:[NSNumber numberWithInteger:index] responseCallback:^(id responseData) {
//            CGFloat x = [[responseData objectForKey:@"x"]floatValue];
//            CGFloat y = [[responseData objectForKey:@"y"]floatValue];
//            CGFloat width = [[responseData objectForKey:@"width"]floatValue];
//            CGFloat height = [[responseData objectForKey:@"height"]floatValue];
//            
//            NSLog(@"%f,%f,%f,%f",x,y,width,height);
//            
//            frame = CGRectMake(x,y,width, height);
//            //dispatch_group_leave(group);
//        }];
//
//    });
//    
//    //dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//    return frame;

    //NSLog(@"%f,%f,%f,%f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
//    return self.imageStartFrame;
  
    return frame;
}

- (void)imageDidClicked:(id)data{
    
    //NSString* url = [data objectForKey:@"url"];
//    NSDictionary* frameDic = [data objectForKey:@"frame"];
//    
//    CGFloat x = [[frameDic objectForKey:@"x"]floatValue];
//    CGFloat y = [[frameDic objectForKey:@"y"]floatValue];
//    CGFloat width = [[frameDic objectForKey:@"width"]floatValue];
//    CGFloat height = [[frameDic objectForKey:@"height"]floatValue];
//   // x -= self.articleWebView.scrollView.contentOffset.x;
//    y += self.articleWebView.scrollView.contentInset.top;
//    self.imageStartFrame = CGRectMake(x, y, width, height);
    
    //NSLog(@"%f,%f,%f,%f",x,y,width,height);
    
    NSInteger index =  [self.imageUrlsArray indexOfObject:data];
    HITImageController* imageController = [[HITImageController alloc]initWithDatasource:self Delegate:self startIndex:index];
    [self presentViewController:imageController animated:YES completion:nil];
}
@end
