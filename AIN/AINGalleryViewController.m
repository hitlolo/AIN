//
//  AINGalleryViewController.m
//  AIN
//
//  Created by Lolo on 16/6/2.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINGalleryViewController.h"
#import "AINGalleryPaintingFetcher.h"
#import "AINGallerySearchController.h"
#import "HITRefresh/HITTableRefreshHeader.h"
#import "HITRefresh/HITTableLoadmoreFooter.h"


#import "UITableView+EmptyData.h"
#import "AINGalleryTableCell.h"
#import "AINPainting.h"
#import "HITImageController/HITImageController.h"
#import "AINRootController.h"

static NSString* const iPaintingCellIdentifier = @"paintingCell";

@interface AINGalleryViewController ()
<UITableViewDelegate,UITableViewDataSource,
HITImageTappedDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* paintings;
@property (strong, nonatomic) AINGalleryPaintingFetcher* paintingFetcher;

@property (strong, nonatomic) HITTableRefreshHeader* refreshHeader;
@property (strong, nonatomic) HITTableLoadmoreFooter* loadmoreFooter;

@property (assign, nonatomic) BOOL refreshTriggerd;
@end

@implementation AINGalleryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepare];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rootController setHideCustomBarOnSwipe:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!_refreshTriggerd) {
        [self.refreshHeader startRefresh];
        _refreshTriggerd = YES;
    }
}

- (UITableView*)embededTableView{
    return _tableView;
}

- (void)prepare{
    _refreshTriggerd = NO;
    [self prepareTableview];
    [self prepareHeaderFooter];
    
    [self prepareCachedData];
}

- (void)prepareTableview{
    UINib* nib = [UINib nibWithNibName:@"AINGalleryTableCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:iPaintingCellIdentifier];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 400.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)prepareHeaderFooter{
    [self.view addSubview:self.refreshHeader];
    [self.view addSubview:self.loadmoreFooter];
}

- (void)prepareCachedData{
    [self fetchCachedPaintings];
}


#pragma mark - Setter & Getter

- (AINGalleryPaintingFetcher*)paintingFetcher{
    if (_paintingFetcher == nil) {
        _paintingFetcher = [[AINGalleryPaintingFetcher alloc]init];
    }
    return _paintingFetcher;
}

- (NSMutableArray*)paintings{
    if (_paintings == nil) {
        _paintings = [NSMutableArray array];
    }
    return _paintings;
}

- (HITTableRefreshHeader*)refreshHeader{
    if (_refreshHeader == nil) {
        _refreshHeader = [[HITTableRefreshHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
        _refreshHeader.scrollView = self.tableView;
        [_refreshHeader addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshHeader;
}

- (HITTableLoadmoreFooter*)loadmoreFooter{
    if (_loadmoreFooter == nil) {
        _loadmoreFooter = [[HITTableLoadmoreFooter alloc]init];
        _loadmoreFooter.scrollView = self.tableView;
        [_loadmoreFooter addTarget:self action:@selector(loadmore) forControlEvents:UIControlEventValueChanged];
    }
    return _loadmoreFooter;
}


#pragma mark - Refresh & Loadmore

- (void)fetchCachedPaintings{
    
    [self.paintingFetcher fetchPaintingsFromDatabaseWithOffset:@"0" completionHandler:^(NSMutableArray * _Nullable objectArray, NSError * _Nullable error) {
        
        if (objectArray && [objectArray count] != 0) {
            self.paintings = [objectArray mutableCopy];
            [self.tableView reloadData];
        }
      
    }];
}

- (void)refresh{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.paintingFetcher fetchPaintingsFromHTTPWithOffset:@"0" completionHandler:^(NSMutableArray *objectArray, NSError * _Nullable error) {
            if (!error) {
                self.paintings = [objectArray mutableCopy];
                [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"成功加载%ld副画作",(long)[self.paintings count]]  dismissAfter:3 styleName:JDStatusBarStyleSuccess];
            }
            if (error) {
                NSString* errorMessage = [NSString stringWithFormat:@"%d,%@",error.code,error.localizedDescription];
                [JDStatusBarNotification showWithStatus:errorMessage dismissAfter:3 styleName:JDStatusBarStyleError];
            }
            [self.tableView reloadData];
            [self.refreshHeader endRefresh];
    
                       
        }];
    });
}

- (void)loadmore{
    
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         
         AINPainting* lastPainting = [self.paintings lastObject];
         [self.paintingFetcher fetchPaintingsFromHTTPWithOffset:lastPainting.hpcontent_id completionHandler:^(NSMutableArray *objectArray, NSError * _Nullable error) {
             if (!error) {
                 [self.paintings addObjectsFromArray:objectArray];
                 [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"成功加载%ld副画作",[objectArray count]]  dismissAfter:3 styleName:JDStatusBarStyleSuccess];
             }
             if (error) {
                 [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:3 styleName:JDStatusBarStyleError];
             }
             [self.tableView reloadData];
             [self.loadmoreFooter endLoadmoreWithMoreData:YES infoMessage:@"没有更多画作"];
             
             
         }];

     
     
     });
}



#pragma mark -- UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSUInteger rows = [self.paintings count];
    [tableView tableViewDisplayMessage:@"无画作" forRow:rows];
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AINGalleryTableCell *paintingCell = [tableView dequeueReusableCellWithIdentifier:iPaintingCellIdentifier forIndexPath:indexPath];
    [paintingCell setPainting:self.paintings[indexPath.row]];
    [paintingCell setDelegate:self];
    return paintingCell;
    
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - HITImageTapped delegate

- (void)tappedOnImageSource:(id)source startIndex:(NSInteger)index{
    [self showImageControllerWithImageSource:source];
}

- (void)showImageControllerWithImageSource:(id)datasource{
    
    HITImageController* imageController = [[HITImageController alloc]initWithDatasource:datasource Delegate:nil];
    [self presentViewController:imageController animated:YES completion:nil];
}

#pragma mark - navibar 

- (IBAction)searchItemClicked:(id)sender {
    
    AINGallerySearchController* searchController = [[AINGallerySearchController alloc]init];
    [self presentViewController:searchController animated:YES completion:nil];
    
}


@end
