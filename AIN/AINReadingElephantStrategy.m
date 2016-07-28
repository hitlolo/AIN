//
//  AINReadingElephantStrategy.m
//  AIN
//
//  Created by Lolo on 16/6/24.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINReadingElephantStrategy.h"

#import "AINReadArticleFetcher.h"
#import "HITRefresh/HITTableRefreshHeader.h"
#import "HITRefresh/HITTableLoadmoreFooter.h"

#import "UITableView+EmptyData.h"
#import "ONEElephantDescriptionCell.h"
#import "ONEElephantArticleBrief.h"

#import "AINTableHeaderView.h"

#import "RTSpinKitView.h"

#import "AINRootController.h"

#import "AINReadWebviewController.h"

static NSString* const iCellIdentifier = @"articleIndexCell";


@interface AINReadingElephantStrategy ()


@property(nonatomic,assign)BOOL dataInitialized;
@property(nonatomic,strong)RTSpinKitView* spinView;
@property(nonatomic,strong)HITTableRefreshHeader* refreshHeader;
@property(nonatomic,strong)HITTableLoadmoreFooter*  loadmoreFooter;
@property(nonatomic,weak)AINReadArticleFetcher* articleFetcher;
@end


@implementation AINReadingElephantStrategy




#pragma mark - Getter & Setter


- (RTSpinKitView*)spinView{
    if (_spinView == nil) {
        _spinView = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStylePulse];
        _spinView.color = globalControlTintColor;
        [_spinView stopAnimating];
        [_spinView setHidesWhenStopped:YES];
        _spinView.center = self.hosterController.view.center;
        [self.hosterController.view addSubview:_spinView];
        [self.hosterController.view bringSubviewToFront:_spinView];
        
        _spinView.translatesAutoresizingMaskIntoConstraints = NO;
        [_spinView.centerXAnchor constraintEqualToAnchor:_spinView.superview.centerXAnchor].active = YES;
        [_spinView.centerYAnchor constraintEqualToAnchor:_spinView.superview.centerYAnchor constant:-44].active = YES;
        
    }
    return _spinView;
}


- (AINReadArticleFetcher*)articleFetcher{
    if (_articleFetcher == nil) {
        _articleFetcher = [AINReadArticleFetcher sharedFetcher];
    }
    return _articleFetcher;
}


- (HITTableRefreshHeader*)refreshHeader{
    if (_refreshHeader == nil) {
        _refreshHeader = [[HITTableRefreshHeader alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].width, 60)];
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



- (void)initialData{
    
    [self.spinView startAnimating];
    //[self.tableView setHidden:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.articleFetcher fetchElephantIndexWithCompletion:^(ArticleArray * _Nullable articleArray, NSError * _Nullable error) {
            
            if (error) {
                [self.spinView stopAnimating];
                return ;
            }
            
            if (!error) {
                
                //[self.columnContents removeAllObjects];
                [self.columnContents addObjectsFromArray:articleArray];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //[self.tableView setHidden:NO];
                    [self.spinView stopAnimating];
                    
                    [self.tableView reloadData];
                });
                
            }
            
        }];
    });
    
}

- (void)refresh{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.articleFetcher fetchElephantIndexWithCompletion:^(ArticleArray * _Nullable articleArray, NSError * _Nullable error) {
            
            if (error) {
                [self.refreshHeader endRefresh];
                return ;
            }
            
            if (!error) {
                
                [self.columnContents removeAllObjects];
                [self.columnContents addObjectsFromArray:articleArray];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.refreshHeader endRefresh];
                    [self.tableView reloadData];
                });
                
            }
            
        }];
    });
}


- (void)loadmore{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        ONEElephantArticleBrief* articleBrief = [self.columnContents lastObject];
        NSString* createTime = articleBrief.create_time;
        NSString* updateTime = articleBrief.update_time;
       [self.articleFetcher fetchElephantIndexWithCreateTime:createTime updateTime:updateTime completionHandler:^(NSMutableArray * _Nullable objectArray, NSError * _Nullable error) {
           if (error) {
               [self.loadmoreFooter endLoadmoreWithMoreData:YES infoMessage:nil];
               return ;
           }
           
           if (!error) {
               
               if ([objectArray count] == 0) {
                   [self.loadmoreFooter endLoadmoreWithMoreData:NO infoMessage:nil];
               }
               
               else{
                   [self.columnContents addObjectsFromArray:objectArray];
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                       
                       [self.loadmoreFooter endLoadmoreWithMoreData:YES infoMessage:nil];
                       [self.tableView reloadData];
                   });
               }
               
               
           }

       }];
    });
}



- (void)columnViewControllerDidLoad:(UIViewController*)hostController withTableView:(UITableView*)tableview{
    
    [super columnViewControllerDidLoad:hostController withTableView:tableview];
    [self.hosterController.view addSubview:self.refreshHeader];
    [self.hosterController.view addSubview:self.loadmoreFooter];

    
}

- (void)columnTableViewCellNeedRegisteredBeforeReuse:(UITableView*)tableview{
    
    UINib* nib = [UINib nibWithNibName:@"ONEElephantDescriptionCell" bundle:[NSBundle mainBundle]];
    [tableview registerNib:nib forCellReuseIdentifier:iCellIdentifier];
}


- (void)columnViewDidAppear:(BOOL)animated{
    
    if (_dataInitialized == NO) {
        [self initialData];
        _dataInitialized = YES;
    }
}

#pragma mark - tableview datasource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rows = [self.columnContents count];
    [tableView tableViewDisplayMessage:@"暂无数据" forRow:rows separator:UITableViewCellSeparatorStyleNone];
    return rows;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    ONEElephantDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:iCellIdentifier forIndexPath:indexPath];
    
    //fix a bug,
    //but what makes the bug
    
    if (indexPath.row > [self.columnContents count]) {
        return cell;
    }
    
    ONEElephantArticleBrief* articleBrief = self.columnContents[indexPath.row];
    [cell setArticle:articleBrief];
    // Configure the cell...
    
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self pushElephantArticleAtIndexPath:indexPath];
    
}

- (void)pushElephantArticleAtIndexPath:(NSIndexPath *)indexPath{
    
    __weak typeof(AINReadArticleFetcher*) weakFetcher = [AINReadArticleFetcher sharedFetcher];
    __weak typeof(self) weakSelf = self;
    
    void (^loadBlock)(void(^)(NSString* html)) = ^(void(^completion)(NSString* html)){
        
        ONEElephantArticleBrief* articleBrief = weakSelf.columnContents[indexPath.row];
        [weakFetcher fetchElephantArticleWithArticleID:articleBrief.article_id completionHandler:^(id<AINArticle>  _Nullable article, NSError * _Nullable error) {
            if (!error) {
                completion([article articleToHTML]);
            }
            if (error) {
                completion(nil);
            }
        }];
    };
    
    AINReadWebviewController* reading = [[AINReadWebviewController alloc]init];
    reading.hidesBottomBarWhenPushed = YES;
    reading.articleLoadBlock = loadBlock;
    [self.hosterController.navigationController pushViewController:reading animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    AINTableHeaderView* header = [[AINTableHeaderView alloc]init];
    [header setMessage:@"大象公社"];
    
    return header;
}

@end