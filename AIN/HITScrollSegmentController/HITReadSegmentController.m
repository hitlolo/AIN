//
//  HITScrollSegmentController.m
//  HITScrollListController
//
//  Created by Lolo on 16/5/12.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITReadSegmentController.h"
#import "HITScrollSegmentView.h"
#import "HITReadColumnProvider.h"
#import "HITReadColumnEditorController.h"
#import "HITReadColumnIndexPage.h"
#import "HITReadColumn.h"

#define OnStageColumnSection 0
#define OffStageColumnSection 1

@interface HITReadSegmentController ()
<HITScrollSegmentViewDatasource,HITScrollSegmentViewDelegate,
HITReadColumnEditorDatasource,HITReadColumnEditorDelegate,
UIPageViewControllerDataSource,UIPageViewControllerDelegate>


@property(nonatomic,strong)id<HITReadColumnStrategyDatasource> columnStrategyProvider;
@property(nonatomic,strong)HITReadColumnProvider* columnProvider;
@property(nonatomic,strong)HITScrollSegmentView* columnSegment;
@property(nonatomic,strong)UIPageViewController* columnPageController;
@property(nonatomic,strong)UIView* contentView;                             //container for uipageview controller
@property(nonatomic,strong)NSMutableDictionary* controllers;

@property(nonatomic,assign)BOOL started;
@end

@implementation HITReadSegmentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepare];
    [self prepareConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!_started) {
        [self start];
        _started = YES;
    }

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)loadView{
    [super loadView];

    [self.view addSubview:self.columnSegment];
    [self.view addSubview:self.contentView];

}

- (void)prepare{
    _started = NO;
    
    NSAssert(self.delegate, @"HITReadSegmentControllerDelegate needed");
    
    //columns
    _columnProvider = [[HITReadColumnProvider alloc]initWithColumnDatasource:[self.delegate columnsDataSource]];
    //column handle strategy
    _columnStrategyProvider = [self.delegate columnsStrategyDataSource];
    
    //uipage view controller
    //NSDictionary* options = @{UIPageViewControllerOptionInterPageSpacingKey:[NSNumber numberWithFloat:10.0]};
    _columnPageController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _columnPageController.dataSource = self;
    _columnPageController.delegate = self;
    
    [self addChildViewController:_columnPageController];
    [_columnPageController.view setFrame:self.contentView.bounds];
    [self.contentView addSubview:_columnPageController.view];
    [_columnPageController didMoveToParentViewController:self];

}


- (void)prepareConstraints{
    //column scroll segment view
    _columnSegment.translatesAutoresizingMaskIntoConstraints = NO;
    [_columnSegment.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [_columnSegment.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [_columnSegment.heightAnchor constraintEqualToConstant:44.0f].active = YES;
    [_columnSegment.topAnchor constraintEqualToAnchor:[self.topLayoutGuide bottomAnchor]].active = YES;
    [_columnSegment.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    
    //reading view
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [_contentView.topAnchor constraintEqualToAnchor:_columnSegment.bottomAnchor].active = YES;
    [_contentView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_contentView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
}


- (void)start{
    _controllers = [NSMutableDictionary dictionary];
    //load data to column segment
    [_columnSegment reloadData];
    NSInteger index = self.columnProvider.currentIndex;
    //active a column page
    [self activeColunmForIndex:index needsReload:NO] ;
}

- (void)activeColunmForIndex:(NSInteger)index needsReload:(BOOL)reload{
    
    UIViewController* viewController = [self columnPageForIndex:index];

    UIPageViewControllerNavigationDirection direction;
    if (index > self.columnProvider.currentIndex) {
        direction = UIPageViewControllerNavigationDirectionForward;
    }
    else{
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    __weak typeof(self) weakSelf = self;
    
    BOOL animation = YES;
    //use a blank new  uiviewcontroller to reload once
    //if skip this step, when the viewcontroller to set is the same with the old one,
    //the uipageviewcontroller will not referesh the viewcontroller 's before vc and after vc
    if (reload) {
        animation = NO;
        UIViewController* viewController = [[UIViewController alloc]init];
        [_columnPageController setViewControllers:@[viewController] direction:direction animated:animation completion:nil];
;
    }
   
    [_columnPageController setViewControllers:@[viewController] direction:direction animated:animation completion:^(BOOL finished) {
        if (finished) {
            [weakSelf.columnSegment highLightSegmentAtIndex:index];
            weakSelf.columnProvider.currentIndex = index;
            ((HITReadColumnIndexPage*)viewController).tableView.scrollsToTop = YES;
        }
    }];
    
    
}

#pragma mark - Setter & Getter

- (void)setSegmentDefaultColor:(UIColor *)segmentDefaultColor{
    _segmentDefaultColor = segmentDefaultColor;
    [self.columnSegment setTitleDefaultColor:_segmentDefaultColor];
}

- (void)setSegmentHighlightColor:(UIColor *)segmentHighlightColor{
    _segmentHighlightColor = segmentHighlightColor;
    [self.columnSegment setTitleHighlightedColor:_segmentHighlightColor];
}

- (void)setSegmentBackgroundColor:(UIColor *)segmentBackgroundColor{
    _segmentBackgroundColor = segmentBackgroundColor;
    [self.columnSegment setBackgroundColor:_segmentBackgroundColor];
}

- (HITScrollSegmentView*)columnSegment{
    if (_columnSegment == nil) {
        _columnSegment = [[HITScrollSegmentView alloc]init];
        _columnSegment.segmentDatasource = self;
        _columnSegment.segmentDelegate = self;
    }
    return _columnSegment;
}

- (UIView*)contentView{
    if (_contentView == nil) {
        _contentView = [UIView new];
    }
    return _contentView;
}


#pragma mark - ScrollSegmentView datasource & delegate

- (NSArray*)segmentTitlesForScrollSegmentView{
    NSArray* array = [self.columnProvider.columnsOn array];
    return array;
}

- (void)segmentItemDidSelected:(NSInteger)index{
    [self activeColunmForIndex:index needsReload:NO];
}

- (void)segmentEditDidSelected:(UIButton *)sender{
    HITReadColumnEditorController *columnEditor = [[HITReadColumnEditorController alloc]init];
    columnEditor.delegate = self;
    columnEditor.datasource = self;
    columnEditor.modalPresentationStyle = UIModalPresentationCustom;
   [self presentViewController:columnEditor animated:YES completion:nil];
    HITReadColumnEditorPresntationController* presentation =  (HITReadColumnEditorPresntationController*)columnEditor.presentationController;
    presentation.fromView = self.columnSegment;
}


#pragma mark - Column Editor datascouce & delegate

- (NSInteger)numberOfColumnsForSection:(NSInteger)section{
    if (section == OnStageColumnSection) {
        return [self.columnProvider.columnsOn count];
    }
    else if (section == OffStageColumnSection){
        return [self.columnProvider.columnsOff count];
    }
    return 0;
}

- (NSString*)promptTitleOfHeaderForSection:(NSInteger)section{
    if (section == OnStageColumnSection) {
        return @"关注栏目";
    }
    else if (section == OffStageColumnSection){
        return@"闲置栏目";
    }
    return nil;
}

- (HITReadColumn*)columnForColumnEditorAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == OnStageColumnSection) {
        return [self.columnProvider.columnsOn objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == OffStageColumnSection){
        return [self.columnProvider.columnsOff objectAtIndex:indexPath.row];
    }
    return nil;
}

- (void)columnEditorDidMoveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    HITReadColumn* column = nil;
    if (sourceIndexPath.section == OnStageColumnSection && destinationIndexPath.section == OnStageColumnSection) {
        [self.columnProvider.columnsOn exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        
        if (sourceIndexPath.row == self.columnProvider.currentIndex) {
            self.columnProvider.currentIndex = destinationIndexPath.row;
        }
        
        else if (destinationIndexPath.row == self.columnProvider.currentIndex) {
            self.columnProvider.currentIndex += 1;
        }
    }
    else if (sourceIndexPath.section == OffStageColumnSection && destinationIndexPath.section == OffStageColumnSection) {
        [self.columnProvider.columnsOff exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        
    }
    
    //between sections
    else if (sourceIndexPath.section == OnStageColumnSection) {
        column = [self.columnProvider.columnsOn objectAtIndex:sourceIndexPath.row];
        [self.columnProvider.columnsOff insertObject:column atIndex:destinationIndexPath.row];
        [self.columnProvider.columnsOn removeObjectAtIndex:sourceIndexPath.row];
    }
    else if (sourceIndexPath.section == OffStageColumnSection) {
        column = [self.columnProvider.columnsOff objectAtIndex:sourceIndexPath.row];
        [self.columnProvider.columnsOn insertObject:column atIndex:destinationIndexPath.row];
        [self.columnProvider.columnsOff removeObjectAtIndex:sourceIndexPath.row];
        
        if (destinationIndexPath.row == self.columnProvider.currentIndex) {
            self.columnProvider.currentIndex += 1;
        }
    }

}

- (void)columnEditorDidDeleteColumnFromOnstageAtIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)columnCollection{
    HITReadColumn* column = nil;
    
    if (indexPath.row == self.columnProvider.currentIndex) {

        if (self.columnProvider.currentIndex == [self.columnProvider.columnsOn count] - 1) {
                self.columnProvider.currentIndex -= 1;
        }
        
    }
    
    column = [self.columnProvider.columnsOn objectAtIndex:indexPath.row];
    [self.columnProvider.columnsOff addObject:column];
    [self.columnProvider.columnsOn removeObjectAtIndex:indexPath.row];
    

    [columnCollection reloadData];

}

- (void)columnEditorDidFinishEditing:(BOOL)changed{
    if (changed) {
        [self.columnSegment reloadData];
        [self reload];
        [self.columnProvider save];
        
    }
    
 
}



#pragma mark - Column Page datasource & delegate

#pragma mark - page controller datasource & delegate

- (void)reload{
    NSInteger index = self.columnProvider.currentIndex;
    [self activeColunmForIndex:index needsReload:YES];
}

- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    NSInteger index = self.columnProvider.currentIndex;
    index += 1;
    if (index > [self.columnProvider.columnsOn count] - 1) {
        return nil;
    }
    
    HITReadColumnIndexPage* page =  [self columnPageForIndex:index];
    page.index = self.columnProvider.currentIndex + 1;
    
    return page;
}

- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    NSInteger index = self.columnProvider.currentIndex;
    index -= 1;
    if (index < 0 ) {
        return nil;
    }
    
    HITReadColumnIndexPage* page =  [self columnPageForIndex:index];
    page.index = self.columnProvider.currentIndex - 1;
    
    return page;
}


- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{
    
    HITReadColumnIndexPage* page = (HITReadColumnIndexPage*)[pendingViewControllers lastObject];
    self.columnProvider.currentIndex = page.index;
    
    ((HITReadColumnIndexPage*)page).tableView.scrollsToTop = YES;
}


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    
    HITReadColumnIndexPage* page = (HITReadColumnIndexPage*)[previousViewControllers lastObject];
    if (!completed) {
       page.tableView.scrollsToTop = YES;
        self.columnProvider.currentIndex = page.index;
    }
    else if (completed){
        page.tableView.scrollsToTop = NO;
        [self.columnSegment highLightSegmentAtIndex:self.columnProvider.currentIndex];
    }

}



- (HITReadColumnIndexPage*)createPageForIndex:(NSInteger)index{
    
    HITReadColumnIndexPage* viewController = [[HITReadColumnIndexPage alloc]init];
    id<HITReadColumn> column = [self.columnProvider.columnsOn objectAtIndex:index];

    ((HITReadColumnIndexPage*)viewController).strategy = [self.columnStrategyProvider strategyForColumn:column];
    ((HITReadColumnIndexPage*)viewController).index = index;
    
    return viewController;
}


- (HITReadColumnIndexPage*)columnPageForIndex:(NSInteger)index{
    
    HITReadColumnIndexPage* page = nil;
    
    HITReadColumn* column = [self.columnProvider.columnsOn objectAtIndex:index];
    page = [self.controllers objectForKey:column.title];

    if (!page) {
        page = [self createPageForIndex:index];
        [self.controllers setObject:page forKey:column.title];
    }
    ((HITReadColumnIndexPage*)page).tableView.scrollsToTop = NO;
    return page;
}

@end
