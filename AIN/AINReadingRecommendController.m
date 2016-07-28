//
//  AINReadingColumnController.m
//  AIN
//
//  Created by Lolo on 16/6/22.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINReadingRecommendController.h"
#import "AINBackgroundView.h"
#import "ONEColumn.h"
#import "ONEColumnItem.h"
#import "AINReadingRecommendCell.h"
#import "HITCategory/UIColor+HexColor.h"
#import "AINReadArticleFetcher.h"
#import "ONEArticleReadingController.h"

@interface AINReadingRecommendController ()
<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UIImageView* imageHeader;
@property(nonatomic,strong)UIView* titleView;
@property(nonatomic,strong)UILabel* titleLabel;
@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)NSLayoutConstraint* headerWidthConstraint;

@property(nonatomic,strong)NSMutableArray* columnItemArray;

@property(nonatomic,strong,readwrite)UINavigationItem* navigationItem;

@property(nonatomic,assign)BOOL initialized;
@property(nonatomic,assign)BOOL prepared;
@end


static NSString* const iCellIdentifier = @"iRecommendCellIdentifier";

@implementation AINReadingRecommendController


- (void)loadView{
    [super loadView];
    
    [self.titleView addSubview:self.titleLabel];
    [self.tableView addSubview:self.imageHeader];
    [self.tableView sendSubviewToBack:self.imageHeader];
    [self.tableView insertSubview:self.titleView aboveSubview:self.imageHeader];
    
//    [self.view addSubview:self.imageHeader];
    [self.view addSubview:self.tableView];
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    _initialized = NO;
    _prepared = NO;
    [self prepareConstriants];


    

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!_initialized) {
        NSURL* url = [NSURL URLWithString:self.column.cover];
        [self.imageHeader sd_setImageWithURL:url];
        self.titleLabel.text = self.column.bottom_text;
        self.navigationItem.title = self.column.title;
        self.tableView.backgroundColor = [UIColor colorFromHexString:self.column.bgcolor];
        
        
        [self fetchColumnItemsFromHTTP];
    }

}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //imageheader's height
    //64 = 20 status bar + 44 navi bar
    //titleview.height
    //-20 = titleview position offset
    //24 = shadow offset
    
    if (!_prepared ) {
        
        [self.tableView setContentInset:UIEdgeInsetsMake(self.imageHeader.height + 64 + self.titleView.height - 20 + 24, 0, 0, 0)];
        [self.tableView setContentOffset:CGPointMake(0,-self.tableView.contentInset.top + self.titleView.height + 24) animated:YES];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:_titleView.bounds];
        _titleView.layer.shadowPath = path.CGPath;
        _prepared = YES;
    }


}


- (void)prepareConstriants{
    
    self.imageHeader.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleView.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.tableView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.tableView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [self.tableView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.tableView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;

    
    
    [self.imageHeader.topAnchor constraintEqualToAnchor:[self.topLayoutGuide bottomAnchor]].active = YES;
    self.headerWidthConstraint = [self.imageHeader.widthAnchor constraintEqualToAnchor:self.view.widthAnchor];
    [self.headerWidthConstraint setActive:YES];
    [self.imageHeader.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.imageHeader.heightAnchor constraintEqualToAnchor:self.imageHeader.widthAnchor multiplier:0.45].active = YES;



    
    
    [self.titleView.widthAnchor constraintEqualToAnchor:self.tableView.widthAnchor multiplier:0.9].active = YES;
    [self.titleView.topAnchor constraintEqualToAnchor:self.imageHeader.bottomAnchor constant:-20].active = YES;
    [self.titleView.centerXAnchor constraintEqualToAnchor:self.imageHeader.centerXAnchor].active = YES;
    
    [self.titleLabel.widthAnchor constraintEqualToAnchor:self.titleView.widthAnchor multiplier:0.9].active = YES;
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.titleView.topAnchor constant:8].active = YES;
    [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.titleView.bottomAnchor constant:-8].active = YES;
    [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.titleView.centerXAnchor].active = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Getter & setter

- (UITableView*)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 200.0f;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        UINib* nib = [UINib nibWithNibName:@"AINReadingRecommendCell" bundle:[NSBundle mainBundle]];
        [_tableView registerNib:nib forCellReuseIdentifier:iCellIdentifier];
        
    }
    return _tableView;
}

- (UIImageView*)imageHeader{
    if (_imageHeader == nil) {
        _imageHeader = [[UIImageView alloc]init];
        _imageHeader.contentMode = UIViewContentModeScaleAspectFill;
        //_imageHeader.clipsToBounds = YES;
    }
    return _imageHeader;
}

- (UIView*)titleView{
    if (_titleView == nil) {
        _titleView = [[UIView alloc]init];
        [_titleView setBackgroundColor:[UIColor colorFromHexString:self.column.bgcolor]];
        _titleView.layer.cornerRadius = 5.0f;
        _titleView.layer.shadowColor = [[UIColor colorWithRed:0.992 green:0.996 blue:0.9496 alpha:1.0] CGColor];
        _titleView.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        _titleView.layer.shadowOpacity = 1.0;
        _titleView.layer.shadowRadius = 5.0;
        

    }
    return _titleView;
}

- (UILabel*)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
    
}

//override
- (UINavigationItem*)navigationItem{
    
    if (_navigationItem == nil) {
        _navigationItem = [super navigationItem];
        //_navigationItem = [[UINavigationItem alloc]init];
        UIButton* dismissButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [dismissButton setImage:[UIImage imageNamed:@"ic_back_alpha"] forState:UIControlStateNormal];
        [dismissButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* dissmissItem = [[UIBarButtonItem alloc]initWithCustomView:dismissButton];
        
        [_navigationItem setLeftBarButtonItem:dissmissItem];
        
    }
    return _navigationItem;
}

- (NSMutableArray*)columnItemArray{
    if (_columnItemArray == nil) {
        _columnItemArray = [NSMutableArray array];
    }
    return _columnItemArray;
}



#pragma mark - Tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.columnItemArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AINReadingRecommendCell* cell = [tableView dequeueReusableCellWithIdentifier:iCellIdentifier forIndexPath:indexPath];
    
    ONEColumnItem* item = self.columnItemArray[indexPath.row];
    cell.backgroundColor = [UIColor colorFromHexString:self.column.bgcolor];
    [cell setIndex:indexPath.row + 1];
    [cell setColumnItem:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pushArticleAtIndex:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    if (offset.y <= -scrollView.contentInset.top) {
        self.headerWidthConstraint.constant = - (offset.y + scrollView.contentInset.top);
    }
}


#pragma mark - HTTP

- (void)fetchColumnItemsFromHTTP{
    
    [[AINReadArticleFetcher sharedFetcher]fetchColumnIndexWithColumnID:self.column.column_id completionHandler:^(NSMutableArray * _Nullable objectArray, NSError * _Nullable error) {
        if (!error) {
            [self.columnItemArray removeAllObjects];
            [self.columnItemArray addObjectsFromArray:objectArray];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationMiddle];
            
            _initialized = YES;
        }
    }];
}

#pragma mark - Actions

- (void)dismiss:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pushArticleAtIndex:(NSIndexPath*)indexPath{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Reading" bundle:[NSBundle mainBundle]];
    //    ONEEssayReadingController* nextReading = [storyboard instantiateViewControllerWithIdentifier:@"essayReadingController"];
    
    ONEArticleReadingController* readingController = [storyboard instantiateViewControllerWithIdentifier:@"ONEArticleReadingController"];
    ONEColumnItem* columnItem = self.columnItemArray[indexPath.row];
    readingController.articleDescription = [columnItem itemToArticle];
    readingController.modalPresentationCapturesStatusBarAppearance = YES;
    [self.navigationController pushViewController:readingController animated:YES];
}


@end
