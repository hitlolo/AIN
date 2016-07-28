//
//  ONEReadingListController.m
//  One
//
//  Created by Lolo on 16/5/1.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEReadingIndexController.h"
#import "ONEEssayDescription.h"
#import "ONESerialDescription.h"
#import "ONEQuestionDescription.h"

#import "HITRefresh/HITTableRefreshHeader.h"
#import "ONEArticleReadingController.h"
#import "ONEReadingIndexCell.h"
#import "AINReadArticleFetcher.h"
#import "YYModel/YYModel.h"
#import "HITCategory/UITableView+EmptyData.h"

static NSString* const CellIdentifier = @"cellIdentifier";

@interface ONEReadingIndexController ()
<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) HITTableRefreshHeader* refreshHeader;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* articleDescriptions;
@property (assign, nonatomic) BOOL dataInitialized;
@end

@implementation ONEReadingIndexController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self prepare];

}

- (void)dealloc{
    [self.refreshHeader cleanUp];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = self.selectedDate;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_dataInitialized == NO) {
        [self.refreshHeader startRefresh];
        _dataInitialized = YES;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepare{
    _dataInitialized = NO;
    [self setHidesBottomBarWhenPushed:YES];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 44.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    UINib* nib = [UINib nibWithNibName:@"ONEReadingIndexCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    [self.view addSubview:self.refreshHeader];
}

- (UITableView*)embededTableView{
    return self.tableView;
}

#pragma mark - Getter

- (HITTableRefreshHeader*)refreshHeader{
    if (_refreshHeader == nil) {
        _refreshHeader = [[HITTableRefreshHeader alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].width, 80)];
        _refreshHeader.scrollView = self.tableView;
        [_refreshHeader addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshHeader;

}

- (void)refresh{

    [self fetchArticleList];
    
}

- (void)endRefresh{
    [self.refreshHeader endRefresh];
    [self.tableView reloadData];
}


- (NSMutableArray*)articleDescriptions{
    if (_articleDescriptions == nil) {
        _articleDescriptions = [NSMutableArray array];
    }
    return _articleDescriptions;
}

- (void)fetchArticleList{
    [[AINReadArticleFetcher sharedFetcher]fetchArticleByMonthWithType:self.articleType selectedMonth:self.selectedDate completionHadnler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error");
            [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:3 styleName:JDStatusBarStyleError];
            [self endRefresh];
            return;
        }
        
        NSString* successMessage = [NSString stringWithFormat:@"成功加载%@期刊",self.selectedDate];
        [JDStatusBarNotification showWithStatus:successMessage dismissAfter:3 styleName:JDStatusBarStyleSuccess];
        
        [self.articleDescriptions removeAllObjects];
        Class class = [self getArticleTypeClass];
        NSArray* data = [responseObject objectForKey:@"data"];
        
        
        for (id articleJson in data) {
            id<AINArticleDescription> article = [class yy_modelWithJSON:articleJson];
            [self.articleDescriptions addObject:article];
            //NSLog(@"%@",[article articleTitle]);
        }
        //end
        [self endRefresh];

    }];
}

- (Class)getArticleTypeClass{
    if (self.articleType == Essay) {
        return [ONEEssayDescription class];
    }
    else if (self.articleType == Serial){
        return [ONESerialDescription class];
    }
    else
        return [ONEQuestionDescription class];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = [self.articleDescriptions count];
    [tableView tableViewDisplayMessage:@"无期刊" forRow:rows];
    
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ONEReadingIndexCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setArticle:self.articleDescriptions[indexPath.row]];
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self pushArticleAtIndexPath:indexPath];
}



- (void)pushArticleAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Reading" bundle:[NSBundle mainBundle]];
    ONEArticleReadingController* readingController = [storyboard instantiateViewControllerWithIdentifier:@"ONEArticleReadingController"];
    readingController.articleDescription = self.articleDescriptions[indexPath.row];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:readingController animated:YES];
}

@end
