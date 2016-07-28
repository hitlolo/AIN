//
//  HITReadingController.m
//  One
//
//  Created by Lolo on 16/5/17.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITReadingController.h"
#import "HITTreeView.h"

@interface HITReadingController ()<UIWebViewDelegate>
@property(nonatomic,strong)HITTreeView* loadingView;
@property(nonatomic,strong)UIWebView* webView;
@property(nonatomic,assign)BOOL needsLoad;
@end

@implementation HITReadingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _needsLoad = YES;
    //_webView.backgroundColor = [UIColor whiteColor];
    [_webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateFast];
    

}

- (void)dealloc{
    [self.webView loadHTMLString:@"" baseURL:nil];
    self.webView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_needsLoad) {
    
        [self.loadingView setHidden:NO];
        [self.loadingView startAnimating];
        
        __weak typeof(self)weakSelf = self;
        void (^completion)(NSString* html) = ^(NSString* html){
            [weakSelf.webView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
        };
        self.refreshBlock(completion);
    }
    
//    [self.navigationController setToolbarHidden:YES];
//    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setHidesBarsOnSwipe:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setHidesBarsOnSwipe:NO];
    [self.navigationController setToolbarHidden:YES];
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillDisappear:animated];
}

- (void)loadView{
    [super loadView];
    
    _webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    _webView.delegate = self;
    [self.view addSubview:_webView];
}

- (HITTreeView*)loadingView{
    if (_loadingView == nil) {
        _loadingView = [[HITTreeView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        _loadingView.center = self.view.center;
        _loadingView.hidden = YES;
        [self.view addSubview:_loadingView];
    }
    return _loadingView;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    _needsLoad = NO;
    [self.loadingView stopAnimating];
    [self.loadingView setHidden:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
