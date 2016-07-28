//
//  AINMovieListController.m
//  AIN
//
//  Created by Lolo on 16/7/8.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINMovieListController.h"

#import "HITRefresh/HITTableRefreshHeader.h"
#import "HITRefresh/HITTableLoadmoreFooter.h"
#import "AINMovieListCell.h"
#import "UITableView+EmptyData.h"
#import "AINMovieFetcher.h"
#import "ONEMovieBrief.h"

#import "AINMovieDetailController.h"

#define CoverImageWidth 1120
#define CoverImageHeight 487

static NSString* const iMovieCellIdentifier = @"iMovieCellIdentifier";

@interface AINMovieListController ()
<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AINMovieFetcher* movieFetcher;

@property (strong, nonatomic) HITTableRefreshHeader* refreshHeader;
@property (strong, nonatomic) HITTableLoadmoreFooter* loadmoreFooter;
@property (assign, nonatomic) BOOL refreshTriggerd;

@property (strong, nonatomic) NSMutableArray* movies;

@end

@implementation AINMovieListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepare];
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

- (void)prepare{
    _refreshTriggerd = NO;
    [self prepareTableview];
    [self prepareHeaderFooter];
    
}

- (void)prepareTableview{
    UINib* nib = [UINib nibWithNibName:@"AINMovieListCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:iMovieCellIdentifier];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
//    self.tableView.estimatedRowHeight = 200.0f;
    self.tableView.rowHeight = self.screenSize.width / (CoverImageWidth/CoverImageHeight);
}

- (void)prepareHeaderFooter{
    [self.view addSubview:self.refreshHeader];
    [self.view addSubview:self.loadmoreFooter];
}

- (UITableView*)embededTableView{
    return _tableView;
}



#pragma mark - Refresh & Loadmore

- (void)refresh{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        [self.movieFetcher fetchMovieIndexWithCompletion:^(MovieArray * _Nullable movieArray, NSError * _Nullable error) {
            if (!error) {
                self.movies = [movieArray mutableCopy];
                [JDStatusBarNotification showWithStatus:@"加载成功"  dismissAfter:3 styleName:JDStatusBarStyleSuccess];
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
        
        ONEMovieBrief* lastMovie = [self.movies lastObject];
        [self.movieFetcher fetchMovieIndexWithOffset:lastMovie.movie_id completion:^(MovieArray * _Nullable movieArray, NSError * _Nullable error) {
            if (!error) {
                [self.movies addObjectsFromArray:movieArray];
                [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"成功加载%d部电影",[movieArray count]]  dismissAfter:3 styleName:JDStatusBarStyleSuccess];
            }
            if (error) {
                NSString* errorMessage = [NSString stringWithFormat:@"%d,%@",error.code,error.localizedDescription];
                [JDStatusBarNotification showWithStatus:errorMessage dismissAfter:3 styleName:JDStatusBarStyleError];
            }
            
            [self.tableView reloadData];
            [self.loadmoreFooter endLoadmoreWithMoreData:YES infoMessage:@"没有更多电影"];
        }];
        
    });
}



#pragma mark -- UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSUInteger rows = [self.movies count];
    [tableView tableViewDisplayMessage:@"无电影" forRow:rows];
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AINMovieListCell *movieCell = [tableView dequeueReusableCellWithIdentifier:iMovieCellIdentifier forIndexPath:indexPath];
    
    ONEMovieBrief* movie = self.movies[indexPath.row];
    [movieCell setCoverImage:movie.cover];
    return movieCell;
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
   
    AINMovieDetailController* detailController = [[AINMovieDetailController alloc]init];
    detailController.movieBrief = self.movies[indexPath.row];
    [self.navigationController pushViewController:detailController animated:YES];
    
}


#pragma mark - Getters

- (NSMutableArray*)movies{
    if (_movies == nil) {
        _movies = [NSMutableArray array];
    }
    return _movies;
}

- (AINMovieFetcher*)movieFetcher{
    if (_movieFetcher == nil) {
        _movieFetcher = [[AINMovieFetcher alloc]init];
    }
    return _movieFetcher;
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



@end
