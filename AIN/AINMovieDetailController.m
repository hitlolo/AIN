//
//  AINMovieDetailController.m
//  AIN
//
//  Created by Lolo on 16/7/10.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINMovieDetailController.h"
#import "AINBackgroundView.h"
#import "ONEMovie.h"
#import "ONEMovieBrief.h"
#import "AINMovieFetcher.h"
#import "RTSpinKitView.h"
#import "YYModel/YYModel.h"

#import "AINMovieDetailInfoCell.h"
#import "AINMovieDetailKeywordsCell.h"
#import "AINMovieDetailImageCell.h"

#import "AINTableHeaderView.h"
#import "AINHeaderView.h"

#import "AINPlayer.h"

#import "AVKit/AVkit.h"
#import "AVFoundation/AVFoundation.h"

const NSInteger NumOfSections = 5;

typedef NS_ENUM(NSInteger,MVSection){
    movie_brief = 0,
    movie_info,
    movie_keywords,
    movie_pic,
    movie_story,
    movie_comment
};

static NSString* const iMovieInfoCellIdentifier = @"iMovieInfoCellIdentifier";
static NSString* const iMovieKeyrwordsCellIdentifier = @"iMovieKeyrwordsCellIdentifier";
static NSString* const iMoviePhotoCellIdentifier = @"iMoviePhotoCellIdentifier";

static NSString* const iMovieSectionHeaderIdentifier = @"iMovieSectionHeaderIdentifier";

@interface AINMovieDetailController ()
<UITableViewDelegate,UITableViewDataSource,
HITImageTappedDelegate>

@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)UIImageView* imageHeader;
@property(nonatomic,strong)NSLayoutConstraint* headerWidthConstraint;

@property (strong, nonatomic) RTSpinKitView* spinView;
@property(nonatomic,strong) AINMovieFetcher* movieFetcher;
@property(nonatomic,strong) ONEMovie* movie;
@property(nonatomic,assign) BOOL initialized;
@end

@implementation AINMovieDetailController


- (void)updateThemeWhenNotificationReceived{
    [super updateThemeWhenNotificationReceived];
    self.tableView.backgroundColor = [[[AINSettingManager sharedManager]themeManager]tableBGColor];
}

- (void)loadView{
    CGRect frame = CGRectMake(0, 0, self.screenSize.width, self.screenSize.height);
    AINBackgroundView *view = [[AINBackgroundView alloc]initWithFrame:frame];
    self.view = view;
    
    [self.tableView addSubview:self.imageHeader];
    [self.tableView sendSubviewToBack:self.imageHeader];
    
    //    [self.view addSubview:self.imageHeader];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareAVPlayer];
    
    [self prepareConstriants];
    
    [self prepareMovieData];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.tableView setContentInset:UIEdgeInsetsMake(self.imageHeader.height + 44 + 20, 0, 0, 0)];
    [self.tableView setContentOffset:CGPointMake(0,-self.tableView.contentInset.top) animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareConstriants{
    
    self.imageHeader.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;

    
    [self.tableView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.tableView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [self.tableView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.tableView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    
    
    
    [self.imageHeader.topAnchor constraintEqualToAnchor:[self.topLayoutGuide bottomAnchor]].active = YES;
//    [self.imageHeader.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    self.headerWidthConstraint = [self.imageHeader.widthAnchor constraintEqualToAnchor:self.view.widthAnchor];
    [self.headerWidthConstraint setActive:YES];
    [self.imageHeader.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.imageHeader.heightAnchor constraintEqualToAnchor:self.imageHeader.widthAnchor multiplier:0.45].active = YES;

    
}

- (void)prepareMovieData{
    
    self.title = self.movieBrief.title;
    
    [self.spinView setHidden:NO];
    [self.spinView startAnimating];
    [self.movieFetcher fetchMovieWithID:self.movieBrief.movie_id completion:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        
        if (error) {
            
        }
        else if (!error) {
            NSDictionary* dic = [responseObject objectForKey:@"data"];
            self.movie = [ONEMovie yy_modelWithDictionary:dic];
            
            [self loadData];
        }
        [self.spinView stopAnimating];
        
    }];
}

- (void)prepareAVPlayer{
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]init];
    tap.numberOfTapsRequired = 1;
    [tap addTarget:self action:@selector(playMovieTrailer:)];
    
    [self.imageHeader addGestureRecognizer:tap];
    [self.imageHeader setUserInteractionEnabled:YES];
    
}
#pragma mark - Getter & setter

- (UITableView*)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 200.0f;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        //_tableView.rowHeight = 200;
        _tableView.backgroundColor = [[[AINSettingManager sharedManager]themeManager]tableBGColor];
    
        UINib* nibInfo = [UINib nibWithNibName:@"AINMovieDetailInfoCell" bundle:[NSBundle mainBundle]];
        [_tableView registerNib:nibInfo forCellReuseIdentifier:iMovieInfoCellIdentifier];
      
        
        UINib* nibKeywords = [UINib nibWithNibName:@"AINMovieDetailKeywordsCell" bundle:[NSBundle mainBundle]];
        [_tableView registerNib:nibKeywords forCellReuseIdentifier:iMovieKeyrwordsCellIdentifier];
        
        UINib* nibPhoto = [UINib nibWithNibName:@"AINMovieDetailImageCell" bundle:[NSBundle mainBundle]];
        [_tableView registerNib:nibPhoto forCellReuseIdentifier:iMoviePhotoCellIdentifier];

        
        [_tableView registerClass:[AINHeaderView class] forHeaderFooterViewReuseIdentifier:iMovieSectionHeaderIdentifier];
        
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


- (AINMovieFetcher*)movieFetcher{
    if (_movieFetcher == nil) {
        _movieFetcher = [[AINMovieFetcher alloc]init];
    }
    return _movieFetcher;
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

#pragma mark - Actions

- (void)loadData{
    NSURL* url = [NSURL URLWithString:self.movie.detailcover];
    [self.imageHeader sd_setImageWithURL:url placeholderImage:one_placeHolder_movie];
    [self.tableView reloadData];
    
}

- (void)dismiss:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableview delegate & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == movie_brief) {
        return 1;
    }
    
    else if (section == movie_info) {
        return 1;
    }
    else if (section == movie_keywords){
        return 1;
    }
    else if (section == movie_pic){
        return 1;
    }
    
    return 0;
}
//
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    switch (indexPath.section) {
//        case movie_info:{
//            return 200.0f;
//        }
//            break;
//        case movie_keywords:{
//            return 200.0f;
//        }
//            break;
//        default:
//            break;
//    }
//    return 0.0f;
//
//}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
            
        case movie_brief:{
            AINMovieDetailInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:iMovieInfoCellIdentifier];
            [infoCell setMovieInfo:self.movie.officialstory];
            return infoCell;
        }
            break;
            
        case movie_info:{
            AINMovieDetailInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:iMovieInfoCellIdentifier];
            [infoCell setMovieInfo:self.movie.info];
            return infoCell;
        }
            break;
        case movie_keywords:{
            AINMovieDetailKeywordsCell* keywordsCell = [tableView dequeueReusableCellWithIdentifier:iMovieKeyrwordsCellIdentifier];
            [keywordsCell setKeywords:self.movie.keywords];
            return keywordsCell;
        }
            break;
            
        case movie_pic:{
            AINMovieDetailImageCell* imageCell = [tableView dequeueReusableCellWithIdentifier:iMoviePhotoCellIdentifier];
            [imageCell setPhotos:self.movie.photo];
            imageCell.delegate = self;
            return imageCell;
        }
            break;
        default:
            break;
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case movie_brief:{
            return 24.0f;
        }
            break;
        case movie_info:{
            return 24.0f;
        }
            break;
        case movie_keywords:{
            return 24.0f;
        }
            break;
        case movie_pic:{
            return 24.0f;
        }
            break;

        default:
            break;
    }
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    switch (section) {
            
        case movie_brief:{
            AINHeaderView* header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:iMovieSectionHeaderIdentifier];
            [header setMessage:@"简介"];
            return header;
        }
            break;
            
        case movie_info:{
            AINHeaderView* header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:iMovieSectionHeaderIdentifier];
            [header setMessage:@"剧组"];
            return header;
        }
            break;
        case movie_keywords:{
            AINHeaderView* header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:iMovieSectionHeaderIdentifier];
            [header setMessage:@"关键词"];
            return header;
        }
            break;
        case movie_pic:{
            AINHeaderView* header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:iMovieSectionHeaderIdentifier];
            [header setMessage:@"剧照"];
            return header;
        }
            break;

        default:
            break;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    if (offset.y <= -scrollView.contentInset.top) {
        self.headerWidthConstraint.constant = - (offset.y + scrollView.contentInset.top);
    }
}


#pragma mark - HITImageTapped delegate

- (void)tappedOnImageSource:(id)source startIndex:(NSInteger)index{
    HITImageController* imageController = [[HITImageController alloc]initWithDatasource:source Delegate:source startIndex:index];
    [self presentViewController:imageController animated:YES completion:nil];

}

#pragma mark - actions

- (void)playMovieTrailer:(UITapGestureRecognizer*)tap{
    
    if ([[AINPlayer sharedPlayer]playing]) {
        [[AINPlayer sharedPlayer]pause];
    }
    
    NSURL* url = [NSURL URLWithString:self.movie.video];
    AVPlayer *player = [AVPlayer playerWithURL:url];
//    AVPlayerLayer* playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
//    playerLayer.frame = self.view.bounds;
//    [self.view.layer addSublayer:playerLayer];
//    
//    [player play];
    AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
    controller.player = player;
    [self presentViewController:controller animated:YES completion:^{
        [controller.player play];
    }];
}


@end
