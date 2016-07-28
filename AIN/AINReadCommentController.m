//
//  AINReadCommentController.m
//  AIN
//
//  Created by Lolo on 16/6/17.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINReadCommentController.h"
#import "AINCommentCell.h"
#import "AINBackgroundView.h"

#import "HITRefresh/HITTableRefreshHeader.h"
#import "HITRefresh/HITTableLoadmoreFooter.h"
#import "AINReadArticleFetcher.h"
#import "ONEReadingComment.h"
#import "YYModel/YYModel.h"
#import "HITCategory/UITableView+EmptyData.h"

#import "AINTableHeaderView.h"


static NSString* const iCommentCellIdentifier = @"iCommentCellIdentifier";

@interface AINReadCommentController ()
<UITableViewDataSource,UITableViewDelegate>

@property(strong,nonatomic)UITableView* tableView;
@property(strong,nonatomic)NSMutableArray* comments;
@property(assign,nonatomic)NSInteger commentCount;

@property(strong,nonatomic)HITTableRefreshHeader* refreshHeader;
@property(strong,nonatomic)HITTableLoadmoreFooter* loadmoreFooter;

@property(strong,nonatomic,readwrite)UIToolbar* toolbar;
@property(assign,nonatomic)BOOL initialized;
@end

@implementation AINReadCommentController

- (void)loadView{
    
//    [super loadView];
    CGRect frame = CGRectMake(0, 0, self.screenSize.width, self.screenSize.height);
    self.view = [[AINBackgroundView alloc]initWithFrame:frame];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepare];
    [self prepareConstraints];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.navigationController.hidesBarsOnSwipe = NO;
    self.navigationController.hidesBottomBarWhenPushed = YES;
    
    if (_initialized == NO) {
        [self.refreshHeader startRefresh];
        _initialized = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepare{
    _commentCount = 0;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.refreshHeader];
    [self.view addSubview:self.loadmoreFooter];
    
    

}

- (void)dealloc{
    [self.refreshHeader cleanUp];
    [self.loadmoreFooter cleanUp];
}



#pragma mark - Constraints

- (void)prepareConstraints{
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
//    [_tableView.topAnchor constraintEqualToAnchor:[self.topLayoutGuide bottomAnchor]].active = YES;
//    [_tableView.bottomAnchor constraintEqualToAnchor:[self.bottomLayoutGuide topAnchor]].active = YES;
    [_tableView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [_tableView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_tableView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}




#pragma mark - Getter & Setter

- (UITableView*)embededTableView{
    return self.tableView;
}

- (UITableView*)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 240;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.contentInset = UIEdgeInsetsMake(self.statusBarHeight + self.navigationBarHeight , 0, 0, 0);
        _tableView.scrollIndicatorInsets = _tableView.contentInset;
        //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UINib* nib = [UINib nibWithNibName:@"AINCommentCell" bundle:[NSBundle mainBundle]];
        [_tableView registerNib:nib forCellReuseIdentifier:iCommentCellIdentifier];

    }
    return _tableView;
}

- (NSMutableArray*)comments{
    if (_comments == nil) {
        _comments = [NSMutableArray new];
    }
    return _comments;
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





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger rows = [self.comments count];
    [tableView tableViewDisplayMessage:@"暂无评论" forRow:rows];
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AINCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:iCommentCellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    [cell setComment:self.comments[indexPath.row]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 24.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    AINTableHeaderView* header = [[AINTableHeaderView alloc]init];
    [header setMessage:@"热门评论"];
    return header;
}

#pragma mark - Refresh & Loadmore

- (void)refresh{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fetchCommentFromURL];
    });
}

- (void)loadmore{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fetchMoreCommentFromURL];
        
    });
}



- (void)fetchCommentFromURL{
    
    AINArticleType type = [self.articleDescription articleType];
    NSString* articleID = [self.articleDescription articleID];
    NSString* commentID = @"0";
    
    [[AINReadArticleFetcher sharedFetcher]fetchCommentWithReadingType:type articleID:articleID commentID:commentID completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"%@",error);
            [self endRefresh];
            [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:2 styleName:JDStatusBarStyleError];
            return ;
        }
        
        [self.comments removeAllObjects];
        
        NSDictionary* dataJson = [responseObject objectForKey:@"data"];
        self.commentCount = [[dataJson objectForKey:@"count"]integerValue];
        NSArray* commentsJson = [dataJson objectForKey:@"data"];
        for (NSDictionary* commentJson in commentsJson) {
            ONEReadingComment* comment = [ONEReadingComment yy_modelWithJSON:commentJson];
            [self.comments addObject:comment];
        }
        
        [self endRefresh];
    }];
}


- (void)fetchMoreCommentFromURL{
    
    AINArticleType type = [self.articleDescription articleType];
    NSString* articleID = [self.articleDescription articleID];
    NSString* commentID = [self lastCommentID];
    
    [[AINReadArticleFetcher sharedFetcher]fetchCommentWithReadingType:type articleID:articleID commentID:commentID completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"%@",error);
            
            return ;
        }
        
        NSDictionary* dataJson = [responseObject objectForKey:@"data"];
        self.commentCount = [[dataJson objectForKey:@"count"]integerValue];
        NSArray* commentsJson = [dataJson objectForKey:@"data"];
        for (NSDictionary* commentJson in commentsJson) {
            ONEReadingComment* comment = [ONEReadingComment yy_modelWithJSON:commentJson];
            [self.comments addObject:comment];
        }
        [self endLoadmore];
    }];
}


- (void)endRefresh{
    [self.tableView reloadData];
    [self.refreshHeader endRefresh];
}


- (void)endLoadmore{
    [self.tableView reloadData];
    NSInteger currentCount = [self.comments count];
    if (currentCount < self.commentCount) {
        [self.loadmoreFooter endLoadmoreWithMoreData:YES infoMessage:nil];
    }
    else{
        [self.loadmoreFooter endLoadmoreWithMoreData:NO infoMessage:@"没有更多评论"];
    }
    
    
}


- (NSString*)lastCommentID{
    
    if ([self.comments count] == 0) {
        return @"0";
    }
    
    ONEReadingComment* lastComment = [self.comments lastObject];
    return lastComment.comment_id;
}


@end
