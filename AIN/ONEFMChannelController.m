//
//  ONEFMChannelController.m
//  One
//
//  Created by Lolo on 16/5/3.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEFMChannelController.h"
#import "ONEFMChannelCell.h"
#import "ONEChannel.h"
#import "AINTableHeaderView.h"
#import "YYModel/YYModel.h"

static NSString* const channel_hot_url = @"http://douban.fm/j/explore/hot_channels";
static NSString* const channel_uptrend_url = @"http://douban.fm/j/explore/up_trending_channels";
static NSString* const channel_recommend_url = @"http://douban.fm/j/explore/get_recommend_chl";

typedef NS_ENUM(NSInteger,ONEFMIndex){
    recommend = 0,
    hot,
    uptrending
};
@interface ONEFMChannelController ()

@property(nonatomic,strong)AFHTTPSessionManager* httpManager;
@property(nonatomic,strong)NSArray<NSString*> *channelSectionTitles;
@property(nonatomic,strong)NSArray<NSMutableArray*> *channelSections;
@property(nonatomic,strong)ONEChannel* currentChannel;
@property(nonatomic,assign)BOOL initialized;

@end

@implementation ONEFMChannelController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self prepare];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_initialized == NO) {
        [self triggerRefresh];
        _initialized = YES;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepare{
    _channelSectionTitles = @[@"今日推荐",@"热门赫兹",@"上升最快"];
    _channelSections = @[
                         [NSMutableArray array],
                         [NSMutableArray array],
                         [NSMutableArray array]
                         ];
    _httpManager = [AFHTTPSessionManager manager];
    
    [self prepareTableView];
    
}

- (void)prepareTableView{
    self.tableView.estimatedRowHeight = 60;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.tintColor = globalControlTintColor;
    [self.refreshControl addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
}

- (void)triggerRefresh{
    [self.refreshControl beginRefreshing];
    [self fecthChannelsFromURL];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_channelSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_channelSections[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ONEFMChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"channelCell" forIndexPath:indexPath];
    
    // Configure the cell...
    ONEChannel* channel = self.channelSections[indexPath.section][indexPath.row];
    [cell setChannel:channel];
    
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    AINTableHeaderView* header = [[AINTableHeaderView alloc]init];
    [header setMessage:self.channelSectionTitles[section]];
    return header;
}
//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return self.channelSectionTitles[section];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ONEChannel* channel = self.channelSections[indexPath.section][indexPath.row];
    [self.delegate channelController:self didSelectedChannel:channel];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)fecthChannelsFromURL{
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
   [_httpManager GET:channel_hot_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
       [self.channelSections[hot] removeAllObjects];
       NSDictionary *channelData = [responseObject objectForKey:@"data"];
       NSArray* channelsJson = [channelData objectForKey:@"channels"];
       
       for (id channelJson in channelsJson){
           
           ONEChannel *channel = [ONEChannel yy_modelWithJSON:channelJson];
           [self.channelSections[hot] addObject:channel];
           //
       }

       dispatch_group_leave(group);
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       dispatch_group_leave(group);
   }];
    
    dispatch_group_enter(group);
    [_httpManager GET:channel_recommend_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.channelSections[recommend] removeAllObjects];
        NSDictionary *channelData = [responseObject objectForKey:@"data"];
        NSDictionary* channelJson = [channelData objectForKey:@"res"];
        

        ONEChannel *channel = [ONEChannel yy_modelWithJSON:channelJson];
        [self.channelSections[recommend] addObject:channel];
            //
        dispatch_group_leave(group);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [_httpManager GET:channel_uptrend_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.channelSections[uptrending] removeAllObjects];
        NSDictionary *channelData = [responseObject objectForKey:@"data"];
        NSArray* channelsJson = [channelData objectForKey:@"channels"];
        
        for (id channelJson in channelsJson){
            
            ONEChannel *channel = [ONEChannel yy_modelWithJSON:channelJson];
            [self.channelSections[uptrending] addObject:channel];
            //
        }
        //
        dispatch_group_leave(group);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    });
    
}

@end
