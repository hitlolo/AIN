//
//  AINReadingEssayStrategy.m
//  AIN
//
//  Created by Lolo on 16/6/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINReadingEssayStrategy.h"
#import "AINReadArticleFetcher.h"
#import "HITRefresh/HITTableRefreshHeader.h"
#import "HITRefresh/HITTableRevealFooter.h"

#import "ONEArticleDescriptionCell.h"
#import "UITableView+EmptyData.h"
#import "AINMonthPickerController.h"
#import "ONEArticleReadingController.h"
#import "ONEReadingIndexController.h"
#import "AINTableHeaderView.h"

#import "RTSpinKitView.h"

#import "AINRootController.h"

static NSString* const iCellIdentifier = @"articleIndexCell";

@interface AINReadingEssayStrategy ()
<AINMonthPickerDatasource,AINMonthPickerDelegate>

@property(nonatomic,assign)BOOL dataInitialized;

@property(nonatomic,strong)RTSpinKitView* spinView;
@property(nonatomic,strong)HITTableRefreshHeader* refreshHeader;
@property(nonatomic,strong)HITTableRevealFooter*  revealFooter;
@property(nonatomic,weak)AINReadArticleFetcher* articleFetcher;
@end

@implementation AINReadingEssayStrategy



- (AINReadArticleFetcher*)articleFetcher{
    if (_articleFetcher == nil) {
        _articleFetcher = [AINReadArticleFetcher sharedFetcher];
    }
    return _articleFetcher;
}

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

- (HITTableRefreshHeader*)refreshHeader{
    if (_refreshHeader == nil) {
        _refreshHeader = [[HITTableRefreshHeader alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].width, 60)];
        _refreshHeader.scrollView = self.tableView;
        [_refreshHeader addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshHeader;
}

- (HITTableRevealFooter*)revealFooter{
    if (_revealFooter == nil) {
        _revealFooter = [[HITTableRevealFooter alloc]init];
        _revealFooter.scrollView = self.tableView;
        [_revealFooter addTarget:self action:@selector(reveal) forControlEvents:UIControlEventValueChanged];
    }
    return _revealFooter;
}


- (void)initialData{
    
    //[self.tableView setHidden:YES];
    [self.spinView startAnimating];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.articleFetcher fetchEssayIndexWithCompletion:^(ArticleArray * _Nullable articleArray, NSError * _Nullable error) {
            
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
        
        [self.articleFetcher fetchEssayIndexWithCompletion:^(ArticleArray * _Nullable articleArray, NSError * _Nullable error) {
            
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


- (void)reveal{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Reading" bundle:[NSBundle mainBundle]];
    AINMonthPickerController* viewController = [storyboard instantiateViewControllerWithIdentifier:@"monthpicker"];
    viewController.delegate = self;
    viewController.datasource = self;
    
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    viewController.transitioningDelegate = self.revealFooter.transition;
    
    [self.hosterController presentViewController:viewController animated:YES completion:nil];
}

- (void)columnViewControllerDidLoad:(UIViewController*)hostController withTableView:(UITableView*)tableview{
    
    [super columnViewControllerDidLoad:hostController withTableView:tableview];
    
    [self.hosterController.view addSubview:self.refreshHeader];
    [self.hosterController.view addSubview:self.revealFooter];
    
}

- (void)columnTableViewCellNeedRegisteredBeforeReuse:(UITableView*)tableview{
    
    UINib* nib = [UINib nibWithNibName:@"ONEArticleDescriptionCell" bundle:[NSBundle mainBundle]];
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
    
    
    ONEArticleDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:iCellIdentifier forIndexPath:indexPath];
    
    //fix a bug,
    //but what makes the bug
    
    if (indexPath.row > [self.columnContents count]) {
        return cell;
    }
    
    id<AINArticleDescription> article = self.columnContents[indexPath.row];
    [cell setArticle:article];
    // Configure the cell...
    
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self pushEssayAtIndexPath:indexPath];
    
}

- (void)pushEssayAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Reading" bundle:[NSBundle mainBundle]];
//    ONEEssayReadingController* nextReading = [storyboard instantiateViewControllerWithIdentifier:@"essayReadingController"];
    
    ONEArticleReadingController* readingController = [storyboard instantiateViewControllerWithIdentifier:@"ONEArticleReadingController"];
    readingController.articleDescription = self.columnContents[indexPath.row];
    readingController.modalPresentationCapturesStatusBarAppearance = YES;
    [self.hosterController.navigationController pushViewController:readingController animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    AINTableHeaderView* header = [[AINTableHeaderView alloc]init];
    [header setMessage:@"最新短篇"];
    return header;
}



#pragma mark - month picker datasource & delegate

- (NSInteger)columnFirstYear{
    return 2012;
}

- (void)monthPickerController:(AINMonthPickerController *)monthPicker didSelectedDate:(NSString *)selectedDate{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Reading" bundle:[NSBundle mainBundle]];
    //    ONEEssayReadingController* nextReading = [storyboard instantiateViewControllerWithIdentifier:@"essayReadingController"];
    
    ONEReadingIndexController* readingController = [storyboard instantiateViewControllerWithIdentifier:@"ONEReadingIndexController"];
    readingController.selectedDate = selectedDate;
    readingController.articleType = Essay;
    //    nextReading.articleDescription = self.columnContents[indexPath.row];
    [self.hosterController.navigationController pushViewController:readingController animated:YES];
}




@end
