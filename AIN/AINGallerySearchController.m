//
//  AINGallerySearchController.m
//  AIN
//
//  Created by Lolo on 16/6/12.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINGallerySearchController.h"
#import "AINBackgroundView.h"

#import "AINGalleryPaintingFetcher.h"
#import "AINGallerySearchController.h"
#import "HITRefresh/HITTableRefreshHeader.h"
#import "HITRefresh/HITTableLoadmoreFooter.h"


#import "UITableView+EmptyData.h"
#import "AINGalleryTableCell.h"
#import "AINPainting.h"

#import "HITImageController/HITImageController.h"

static NSString* const iPaintingCellIdentifier = @"paintingCell";

@interface AINGallerySearchController ()
<UISearchBarDelegate,
UITableViewDelegate,UITableViewDataSource,
HITImageTappedDelegate>

@property(nonatomic,strong) UINavigationBar* navigationBar;
@property(nonatomic,strong,readwrite) UINavigationItem* navigationItem;
@property(nonatomic,strong) UISearchBar* searchBar;
@property(nonatomic,strong) UITableView* resultTable;
@property(nonatomic,strong) NSMutableArray* paintings;
@property(nonatomic,strong) AINGalleryPaintingFetcher* paintingFetcher;
@end

@implementation AINGallerySearchController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareConstraints];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView{
    
    self.view = [[AINBackgroundView alloc]initWithFrame:CGRectMake(0, 0, self.screenSize.width, self.screenSize.height)];
    
    UIView* statusBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.screenSize.width, 20)];
    statusBackground.backgroundColor = [[UINavigationBar appearance]barTintColor];
    [self.view addSubview:statusBackground];
    

    [self.view addSubview:self.resultTable];
    [self.view addSubview:self.navigationBar];
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

#pragma mark - Constraints

- (void)prepareConstraints{
    _resultTable.translatesAutoresizingMaskIntoConstraints = NO;
    [_resultTable.topAnchor constraintEqualToAnchor:[self.topLayoutGuide bottomAnchor]].active = YES;
    [_resultTable.bottomAnchor constraintEqualToAnchor:[self.bottomLayoutGuide topAnchor]].active = YES;
    [_resultTable.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [_resultTable.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
}

#pragma mark - Getter & Setter

- (UINavigationBar*)navigationBar{
    if (_navigationBar == nil) {
        _navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, self.view.width, 44)];
        //_navigationBar = [[UINavigationBar alloc]init];
        //[_navigationBar setTitleVerticalPositionAdjustment:20.0 forBarMetrics:UIBarMetricsDefault];
        [_navigationBar setItems:@[self.navigationItem]];
        
        self.edgesForExtendedLayout = UIRectEdgeAll;
    }
    return _navigationBar;
}

- (UINavigationItem*)navigationItem{
    if (_navigationItem == nil) {
        _navigationItem = [super navigationItem];
        _navigationItem.titleView = self.searchBar;
    }
    return _navigationItem;
}

- (UISearchBar*)searchBar{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc]init];
        _searchBar.placeholder = @"search";
        _searchBar.barStyle = UIBarStyleBlackTranslucent;
        _searchBar.showsCancelButton = YES;
        _searchBar.delegate = self;
        _searchBar.origin = CGPointMake(0, 10);
    }
    return _searchBar;
}

- (UITableView*)resultTable{
    if (_resultTable == nil) {
        _resultTable = [[UITableView alloc]init];
        _resultTable.delegate = self;
        _resultTable.dataSource = self;
        _resultTable.estimatedRowHeight = 320;
        _resultTable.rowHeight = UITableViewAutomaticDimension;
        _resultTable.contentInset = UIEdgeInsetsMake(self.navigationBar.height, 0, 0, 0);
        _resultTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        UINib* nib = [UINib nibWithNibName:@"AINGalleryTableCell" bundle:[NSBundle mainBundle]];
        [_resultTable registerNib:nib forCellReuseIdentifier:iPaintingCellIdentifier];
        
    }
    return _resultTable;
    
}

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


#pragma mark - Searchbar delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
    [JDStatusBarNotification showWithStatus:@"searching..." styleName:JDStatusBarStyleDark];
    NSString* keywords = searchBar.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.paintingFetcher fetchPaintingsByKeywords:keywords completionHandler:^(NSMutableArray * _Nullable objectArray, NSError * _Nullable error) {
            
            if (!error) {
                self.paintings = [objectArray mutableCopy];
                [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"搜索到%ld副画作",(unsigned long)[self.paintings count]]  dismissAfter:3 styleName:JDStatusBarStyleSuccess];
            }
            if (error) {
                [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:3 styleName:JDStatusBarStyleError];
            }
            [self.resultTable reloadData];
        }];
     });
}


#pragma mark - tableview delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSUInteger rows = [self.paintings count];
    //[tableView tableViewDisplayMessage:@"请输入作品关键字..." forRow:rows];
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

    HITImageController* imageController = [[HITImageController alloc]initWithDatasource:source Delegate:nil];
    [self presentViewController:imageController animated:YES completion:nil];
}



@end
