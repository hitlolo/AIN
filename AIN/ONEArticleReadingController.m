//
//  ONEArticleReadingController.m
//  One
//
//  Created by Lolo on 16/5/1.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEArticleReadingController.h"
#import "ONEReadingIndexCell.h"


#import "ONEEssay.h"
#import "ONESerial.h"
#import "ONEQuestion.h"
#import "ONESerialList.h"
#import "ONESerialListItem.h"

#import "ONEEssayDescription.h"
#import "ONESerialDescription.h"
#import "ONEQuestionDescription.h"

#import "AINReadArticleFetcher.h"
#import "YYModel/YYModel.h"

#import "AINRootController.h"

#import "RTSpinKitView.h"

#import "ONEBarButtonComments.h"
#import "ONEBarButtonAudioPlay.h"

#import "AINReadCommentController.h"
#import "ONESerialContentListTableController.h"

#import "AINTableHeaderView.h"

#import "ONEArticleAudio.h"
#import "AINPlayer.h"

static NSString* const CellIdentifier = @"cellIdentifier";

@interface ONEArticleReadingController ()
<UITableViewDelegate,UITableViewDataSource,
UIWebViewDelegate,
UIGestureRecognizerDelegate,
ONESerialContentListDelegate>


@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIWebView *articleWebView;
@property (strong, nonatomic) IBOutlet UITableView *relatedTable;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *articleBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *articleHeightConstraint;

@property (strong, nonatomic) RTSpinKitView* spinView;
//data
@property (strong, nonatomic) id<AINArticle> article;
@property (strong, nonatomic) NSMutableArray* relatedArticles;
@property (strong, nonatomic) ONESerialList* serialContentList;

@property (assign, nonatomic) NSInteger currentPageIndex;
@property (assign, nonatomic) CGFloat pageWidth;

//toolbar
@property (strong, nonatomic) UIBarButtonItem* leftToolButton;
@property (strong, nonatomic) UIBarButtonItem* centerToolButton;
@property (strong, nonatomic) UIBarButtonItem* rightToolButton;


@property (strong, nonatomic) UISwipeGestureRecognizer* nextPageGesture;
@property (strong, nonatomic) UISwipeGestureRecognizer* lastPageGesture;
@property (assign, nonatomic) BOOL isReadOnPageMode;
@end

@implementation ONEArticleReadingController


#pragma mark - theme & initial

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
    
    self.title = [self.articleDescription articleTitle];
    [self prepare];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self.navigationController setHidesBarsOnSwipe:YES];


    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO animated:NO];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.rootController setCustomToolbarHidden:YES];
    [self.rootController setHideCustomBarOnSwipe:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[self.navigationController setHidesBarsOnSwipe:NO];
    //[self.rootController setHideCustomBarOnSwipe:YES];
    [self.navigationController setToolbarHidden:YES];

}

//- (BOOL)prefersStatusBarHidden{
//    return YES;
//}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.relatedTable removeObserver:self forKeyPath:@"contentSize"];
    self.articleWebView = nil;
}


- (void)updateThemeWhenNotificationReceived{
    //self.view.backgroundColor = [[[AINSettingManager sharedManager]themeManager]backgroundColor];
    [self beginLoading];
    [self webViewStartLoad];
}

- (void)updateReadModeWhenNotificationReceived{
    [self beginLoading];
    BOOL readInPage = [[AINSettingManager sharedManager]readInPageMode];
    [self setReadingMode:readInPage];
    [self webViewStartLoad];
}

#pragma mark - prepare

- (void)prepare{
    
    [self beginLoading];
    
   
    [self prepareWebView];
    [self prepareRelatedTableview];
    [self prepareBarHideAction];
    
    
    [self fetchArticle];
    [self fetchRelatedArticleFromURL];
    
    if ([self.articleDescription articleType] == Serial) {
        [self.leftToolButton setEnabled:NO];
        [self fetchSerialContentsFromURL];
    }
    
    if ([self.articleDescription articleType] == Essay) {
        [self.leftToolButton setEnabled:NO];
    }
}

- (void)changeTextSize{
    //[self beginLoading];
    //[self.webView reload];
    //[self.webView loadHTMLString:[self toHTML] baseURL:[[NSBundle mainBundle] bundleURL]];
}

- (void)prepareWebView{
    
  
    
    
    self.articleWebView.scrollView.scrollsToTop = NO;

    BOOL readInPage = [[AINSettingManager sharedManager]readInPageMode];
    [self setReadingMode:readInPage];
    
    self.articleWebView.delegate = self;
    self.pageWidth = self.view.width;
    [self.articleWebView addGestureRecognizer:self.nextPageGesture];
    [self.articleWebView addGestureRecognizer:self.lastPageGesture];

}

- (void)prepareRelatedTableview{
    
    
    //    self.relatedTable.tableHeaderView = related;
    
    [self.relatedTable addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    self.relatedTable.scrollsToTop = NO;
    self.relatedTable.delegate = self;
    self.relatedTable.dataSource = self;
    self.relatedTable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.relatedTable.estimatedRowHeight = 80;
    self.relatedTable.rowHeight = UITableViewAutomaticDimension;
    UINib* nib = [UINib nibWithNibName:@"ONEReadingIndexCell" bundle:[NSBundle mainBundle]];
    [self.relatedTable registerNib:nib forCellReuseIdentifier:CellIdentifier];
    [self.relatedTable setScrollEnabled:NO];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    CGSize new = [[change objectForKey:NSKeyValueChangeNewKey]CGSizeValue];
    
    // self.tableHeightConstraint.constant = self.relatedTable.contentSize.height;
    if ([self.relatedArticles count] == 0) {
        self.tableHeightConstraint.constant = 0;
        self.articleBottomConstraint.constant = 0;
    }
    else{
        self.tableHeightConstraint.constant = new.height;
    }
}



#pragma mark - status bar actions

- (void)prepareBarHideAction{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
    [tap addTarget:self action:@selector(tapToHideBar:)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    tap.delaysTouchesEnded = NO;
    tap.cancelsTouchesInView = NO;
    [self.articleWebView addGestureRecognizer:tap];
}


- (void)tapToHideBar:(UITapGestureRecognizer*)tap{
    
    if ([self.navigationController isNavigationBarHidden]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
    else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];

    }
}




#pragma mark - Page Navigation



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
        [self.centerToolButton setTitle:@""];
    }
    else{
        NSInteger pageCount = self.articleWebView.pageCount;
        [self.centerToolButton setTitle:[NSString stringWithFormat:@"%d/%d页",self.currentPageIndex + 1,pageCount]];

    }
}


#pragma mark - Load Data

- (void)beginLoading{
    
    [self.spinView startAnimating];
    [self.contentView setHidden:YES];
    

}

- (void)endLoading{
    
    [self.spinView stopAnimating];
    [self.contentView setHidden:NO];
}

- (void)fetchArticle{
    
    AINArticleType type = [self.articleDescription articleType];
    NSString* contentID = [self.articleDescription articleID];
    
    [[AINReadArticleFetcher sharedFetcher]fetchOneArticleWithType:type articleID:contentID completionHandler:^(id<AINArticle>  _Nullable article, NSError * _Nullable error) {
        
        if (!error) {
            self.article = article;
            [self webViewStartLoad];
        }
    }];
    
    
}


- (void)webViewStartLoad{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.articleWebView loadHTMLString:[self.article articleToHTML]
                                    baseURL:[[NSBundle mainBundle] bundleURL]];

    });
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    
    [self updateArticleWebViewHeight];
    [self updatePageIndex:0];
    
    [self updatePlayAudioButton];
    [self.rightToolButton setTitle:[self.article articleCommentNumber]];
    [self endLoading];
//    [self.navigationController setToolbarHidden:NO animated:NO];
//    [self.delegate articleDidFinishLoad:self.article];
}


#pragma mark - Related Table for Essays

- (void)reloadRelatedTable{
    
    if ([self.relatedArticles count] == 0) {
        self.tableHeightConstraint.constant = 0;
        return;
    }
    
    [self.relatedTable reloadData];
    //self.tableHeightConstraint.constant = self.relatedTable.contentSize.height;
}

- (void)fetchRelatedArticleFromURL{
    
    AINArticleType type = [self.articleDescription articleType];
    NSString* contentID = [self.articleDescription articleID];
    
    [[AINReadArticleFetcher sharedFetcher] fetchRelatedArticleWithReadingType:type articleID:contentID completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@",error);
            return ;
        }
        
        NSArray* data = [responseObject objectForKey:@"data"];
        
       
        Class class = [self.articleDescription class];
        
        for (NSDictionary* dataJson in data) {
            id<AINArticleDescription> articleDescription = [class yy_modelWithJSON:dataJson];
            [self.relatedArticles addObject:articleDescription];
        }

        [self reloadRelatedTable];
        
    }];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.relatedArticles count];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ONEReadingIndexCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    id<AINArticleDescription> articleDescription = self.relatedArticles[indexPath.row];
    [cell setArticle:articleDescription];
    
   
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    id<ONEArticleDescription> articleDescription = self.relatedArticles[indexPath.row];
//    CGFloat height = [ONEReadingIndexCell cellHeightForTableView:tableView data:[articleDescription articleTitle]];
//    return height;
//}

//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return @"相关推荐:";
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
//    UILabel* related = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
//    related.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
//    related.text = @"相关推荐:";
//    //related.textColor = [[[AINSettingManager sharedManager]themeManager]fontColor];
//    //related.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.101008234797297];
//    
//    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
//    [view setBackgroundColor:[UIColor colorWithRed:0.7556 green:0.7556 blue:0.7556 alpha:0.10]];
//    [view addSubview:related];
//    related.translatesAutoresizingMaskIntoConstraints = NO;
//    //    view.translatesAutoresizingMaskIntoConstraints = NO;
//    [NSLayoutConstraint constraintWithItem:related attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0].active = YES;
//    [NSLayoutConstraint constraintWithItem:related attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeading multiplier:1 constant:8].active = YES;
//
    AINTableHeaderView *header = [[AINTableHeaderView alloc]initWithMessage:@"相关推荐"];
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self pushArticleAtIndexPath:indexPath];
}


- (void)pushArticleAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Reading" bundle:[NSBundle mainBundle]];
    ONEArticleReadingController* readingController = [storyboard instantiateViewControllerWithIdentifier:@"ONEArticleReadingController"];
    readingController.articleDescription = self.relatedArticles[indexPath.row];
    [self.navigationController pushViewController:readingController animated:YES];
}




#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



#pragma mark - Getter

- (UIBarButtonItem*)leftToolButton:(AINArticleType)type{
    UIBarButtonItem* item = nil;
    if (type == Essay) {
        
        item = [[ONEBarButtonAudioPlay alloc]init];
        item.target = self;
        item.action = @selector(contentAudioPlayBarButtonClicked:);
    }
    if (type == Serial) {
        item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(contentListBarButtonClicked:)];
        
    }
    if (type == Question) {
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];;
    }
    return item;
}

- (UIBarButtonItem*)leftToolButton{
    if (_leftToolButton == nil) {
        _leftToolButton = [self leftToolButton:[self.articleDescription articleType]];
    }
    return _leftToolButton;
}

- (UIBarButtonItem*)centerToolButton{
    if (_centerToolButton == nil) {
        _centerToolButton = [[UIBarButtonItem alloc]init];
        _centerToolButton.target = self;
        _centerToolButton.action = @selector(rewindToFirstPage);
    }
    return _centerToolButton;
}

- (UIBarButtonItem*)rightToolButton{
    if (_rightToolButton == nil) {
        _rightToolButton = [[ONEBarButtonComments alloc]init];
        _rightToolButton.target = self;
        _rightToolButton.action = @selector(contentCommentsButtonClicked:);
    }
    return _rightToolButton;
}


- (NSArray <__kindof UIBarButtonItem *>*)toolbarItems{
    
 
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    return @[self.leftToolButton,flexibleItem,self.centerToolButton,flexibleItem,self.rightToolButton];
}

- (RTSpinKitView*)spinView{
    if (_spinView == nil) {
        _spinView = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStylePulse];
        _spinView.color = globalControlTintColor;
        [_spinView stopAnimating];
        [_spinView setHidesWhenStopped:YES];
        _spinView.center = self.view.center;
        [self.view addSubview:_spinView];
        
    }
    return _spinView;
}

- (NSMutableArray*)relatedArticles{
    if (_relatedArticles == nil) {
        _relatedArticles = [NSMutableArray array];
    }
    return _relatedArticles;
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


#pragma mark - actions


- (void)rewindToFirstPage{
    [self gotoFirstPage];
}

- (void)contentAudioPlayBarButtonClicked:(ONEBarButtonAudioPlay*)sender{

    
    ONEArticleAudio* audio = [[[AINPlayer sharedPlayer]articlePlayer]audioArticle];
    if ([audio.articleID isEqualToString:[self.article articleID]]) {
        
        if ([[[AINPlayer sharedPlayer]articlePlayer]isFinished]) {
            [[[AINPlayer sharedPlayer]articlePlayer]restart];
        }
        
        else if ([[[AINPlayer sharedPlayer]articlePlayer]isPlaying]) {
            [[[AINPlayer sharedPlayer]articlePlayer]pause];
        }
        else if ([[[AINPlayer sharedPlayer]articlePlayer]isPaused]) {
            [[[AINPlayer sharedPlayer]articlePlayer]unpause];
        }


    }
    
    else{
        
        NSDictionary* dic = @{@"articleID":[self.article articleID],
                              @"title":[self.article articleTitle],
                              @"author":[[self.article articleAuthor]user_name],
                              @"authorAvatar":[[self.article articleAuthor]web_url],
                              @"audioURL":[self.article articleAudio]
                            };
        
        ONEArticleAudio* audio = [ONEArticleAudio yy_modelWithDictionary:dic];
        
        //NSLog(@"%@",audio.audioFileURL);
        [[AINPlayer sharedPlayer]playAudioArticle:audio];
    }
}

- (void)contentListBarButtonClicked:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Reading" bundle:[NSBundle mainBundle]];
    ONESerialContentListTableController* contentListController = [storyboard instantiateViewControllerWithIdentifier:@"serialContentListController"];
    contentListController.modalPresentationStyle = UIModalPresentationCustom;
    contentListController.serialContentList = self.serialContentList;
    contentListController.delegate = self;
    [self presentViewController:contentListController animated:YES completion:nil];
}

- (void)contentCommentsButtonClicked:(id)sender{
    
    AINReadCommentController* commentController = [[AINReadCommentController alloc]init];
    commentController.articleDescription = self.articleDescription;
    [self.navigationController pushViewController:commentController animated:YES];
}


#pragma mark - Serial Content List delegate
- (void)serialContentListTable:(ONESerialContentListTableController *)contentTable didSelectedItem:(ONESerialListItem *)item{
    
    NSDictionary* dic = @{@"id":item.item_id,
                          @"serial_id":item.serial_id,
                          @"title":[self.articleDescription articleTitle]
                          };
    Class class = [self.articleDescription class];
    id<AINArticleDescription> serialDescription = [class yy_modelWithDictionary:dic];
    
    [contentTable dismissViewControllerAnimated:YES completion:^{
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Reading" bundle:[NSBundle mainBundle]];
        ONEArticleReadingController* readingController = [storyboard instantiateViewControllerWithIdentifier:@"ONEArticleReadingController"];
        readingController.articleDescription = serialDescription;
        [self.navigationController pushViewController:readingController animated:YES];
        
    }];
}

#pragma mark - fetch contents data

- (void)fetchSerialContentsFromURL{
    
    NSString* serialID = [self.articleDescription serialId];
    
    if ([serialID isEqual:[NSNull null]] || [serialID isEqualToString:@""] || serialID == nil){
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[AINReadArticleFetcher sharedFetcher]fetchSerialContentListWithSerialID:serialID completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (!error) {
                NSDictionary* dic = [responseObject objectForKey:@"data"];
                self.serialContentList = [ONESerialList yy_modelWithDictionary:dic];
                [self.leftToolButton setEnabled:YES];
                
            }
        }];
    });
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
        [self.centerToolButton setEnabled:YES];

    }
    else{
        self.articleWebView.paginationMode = UIWebPaginationModeUnpaginated;
        self.articleWebView.scrollView.scrollEnabled = NO;
        [self.nextPageGesture setEnabled:NO];
        [self.lastPageGesture setEnabled:NO];
        [self.centerToolButton setEnabled:NO];

    }

}

- (void)updateArticleWebViewHeight{
    if (self.isReadOnPageMode) {
        self.articleHeightConstraint.constant = self.scrollView.height;

    }
    else{
        self.articleHeightConstraint.constant = self.articleWebView.scrollView.contentSize.height;
    }
    
    [self.articleWebView layoutIfNeeded];
}

- (void)updatePlayAudioButton{
    
    if ([self.articleDescription articleType] != Essay) {
        return;
    }
    
    
    
    if ([self.article articleAudio] != nil && ![[self.article articleAudio]isEqualToString:@""]) {
    
        
        [self.leftToolButton setEnabled:YES];
        
        ONEArticleAudio* audio = [[[AINPlayer sharedPlayer]articlePlayer]audioArticle];
        if ([audio.articleID isEqualToString:[self.article articleID]]) {
            
            if ([[[AINPlayer sharedPlayer]articlePlayer]isPlaying]) {
                ONEBarButtonAudioPlay* audioButton = (ONEBarButtonAudioPlay*)self.leftToolButton;
                [audioButton setPaused:NO];
            }
            if ([[[AINPlayer sharedPlayer]articlePlayer]isPaused]) {
                ONEBarButtonAudioPlay* audioButton = (ONEBarButtonAudioPlay*)self.leftToolButton;
                [audioButton setPaused:YES];
            }
        }
        
    }

//    BOOL hasAudio = [self.article articleHasAudio];
//    if (hasAudio) {
//        [self.leftToolButton setEnabled:YES];
//    }
    
    
    //item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];;
}



@end
