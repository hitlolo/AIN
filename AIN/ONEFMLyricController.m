//
//  ONEFMLyricController.m
//  One
//
//  Created by Lolo on 16/5/3.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEFMLyricController.h"
#import "UITableView+EmptyData.h"
#import "ONEFMLyricParser.h"
#import "AINPlayer.h"
#import "ONEFMLyricCell.h"
#import "RTSpinKitView.h"

static void *lyricStatusKVOKey = &lyricStatusKVOKey;
static void *lyricSongKVOKey = &lyricSongKVOKey;

@interface ONEFMLyricController ()

@property(weak, nonatomic)ONESong* currentSong;
@property(strong,nonatomic)ONEFMLyricParser* lyricParser;
@property(strong,nonatomic)NSTimer* lyricTimer;
@property(strong,nonatomic)RTSpinKitView* spinView;
@property(assign,nonatomic)BOOL initialized;
@end

@implementation ONEFMLyricController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self prepare];
    
    
}

- (void)dealloc{
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (!_initialized) {
        self.lyricTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                           target:self
                                                         selector:@selector(scrollLyric)
                                                         userInfo:nil
                                                          repeats:YES];
        
        [[AINPlayer sharedPlayer].fmPlayer.playList addObserver:self
                                              forKeyPath:@"currentSong"
                                                 options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                                                 context:lyricSongKVOKey];
        
        [[AINPlayer sharedPlayer].fmPlayer addObserver:self
                                    forKeyPath:@"status"
                                       options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                                       context:lyricStatusKVOKey];
        _initialized = YES;

    }
    
   
    

}

- (void)viewWillDisappear:(BOOL)animated{
    
    if (_initialized == YES) {
        [self.lyricTimer invalidate];
        self.lyricTimer = nil;
        
        [[AINPlayer sharedPlayer].fmPlayer.playList removeObserver:self forKeyPath:@"currentSong" context:lyricSongKVOKey];
        
        [[AINPlayer sharedPlayer].fmPlayer removeObserver:self forKeyPath:@"status" context:lyricStatusKVOKey];
        
        _initialized = NO;
    }

    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepare{

    _lyricParser = [[ONEFMLyricParser alloc]init];
    self.tableView.estimatedRowHeight = 30;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.top = 50;
    [self.tableView setContentInset:contentInset];
}

//- (void)viewWillLayoutSubviews{
//    [super viewWillLayoutSubviews];
//    
//    
//}

- (RTSpinKitView*)spinView{
    if (_spinView == nil) {
        _spinView = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStylePulse
                                                   color:globalControlTintColor];
        [_spinView stopAnimating];
        [_spinView setHidesWhenStopped:YES];
        _spinView.center = self.view.center;
        [self.view addSubview:_spinView];
        
    }
    return _spinView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //[tableView tableViewDisplayMessage:@"暂无记录" forRow:[self.users count]];
    if (self.lyricParser.lyricType == LyricEmpty || self.lyricParser.timeArray == nil) {
        [tableView tableViewDisplayMessage:@"无歌词数据" forRow:0];
        return 0;
    }
    else if (self.lyricParser.lyricType == LyricNormal) {
        [tableView tableViewDisplayMessage:@"无歌词数据" forRow:1];
        return [self.lyricParser.timeArray count];
    }
    
    else if (self.lyricParser.lyricType == LyricNoTimeline){
        [tableView tableViewDisplayMessage:@"无歌词数据" forRow:1];
        return [self.lyricParser.lyricArray count];
    }
    
    else return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ONEFMLyricCell *cell = [tableView dequeueReusableCellWithIdentifier:@"lyricCell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;//该表格选中后没有颜色
    cell.backgroundColor = [UIColor clearColor];
    // Configure the cell...
    if (self.lyricParser.lyricType == LyricNormal) {
        cell.lyricLabel.text = self.lyricParser.timeLyricDic[self.lyricParser.timeArray[indexPath.row]];
    }
    else if (self.lyricParser.lyricType == LyricNoTimeline){
        cell.lyricLabel.text = self.lyricParser.lyricArray[indexPath.row];
    }
    
    if (indexPath.row == self.lyricParser.highlightIndex ) {
        
        
        cell.lyricLabel.textColor = globalControlTintColor;
        cell.lyricLabel.font = [UIFont boldSystemFontOfSize:16];
        
    }
    else {
   
        cell.lyricLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        cell.lyricLabel.font = [UIFont systemFontOfSize:13];
    }
    cell.lyricLabel.backgroundColor = [UIColor clearColor];
    cell.lyricLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

#pragma mark - Lyric


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if (context == lyricStatusKVOKey) {
        
        ONEFMStatus status = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
        //NSLog(@"status:%d",status);
        [self updateStatus:status];
    }
    
    else if (context == lyricSongKVOKey) {
        ONESong* song = [change objectForKey:NSKeyValueChangeNewKey];
        [self updateLyric:song];
    }
}


- (void)updateLyric:(ONESong*)song{

    if (song == nil || [song isEqual:[NSNull null]]) {
        NSLog(@"return");
        return;
    }
   
    if (self.currentSong == nil || self.currentSong != song) {
        [self pauseLyricTimer];
        [self.spinView startAnimating];
        [self.lyricParser fetchLyric:song completion:^{
            [self.tableView reloadData];
            [self unpauseLyricTimer];
            [self.spinView stopAnimating];
        }];
    }
    
}

- (void)updateStatus:(ONEFMStatus)status{
    switch (status) {
        case FMPlaying:{
            [self unpauseLyricTimer];
        }
            break;
        case FMIdle:
        case FMPaused:
        case FMFinished:
        case FMError:
        case FMBuffering:
            [self pauseLyricTimer];
            break;
        default:
            
            break;
    }
}

- (void)pauseLyricTimer{
    [self.lyricTimer setFireDate:[NSDate distantFuture]];
}

- (void)unpauseLyricTimer{
    [self.lyricTimer setFireDate:[NSDate date]];
}

- (void)scrollLyric{
    
    NSTimeInterval currentTime = [[AINPlayer sharedPlayer].fmPlayer playedTime];
    
    // 歌词解析器中提供了一个 startIndex的属性
    // 以标示当前阶段开始查询的索引 以避免每次都重新迭代
    // 初始化为0
    for (NSInteger index = [_lyricParser startIndex]; index < [[_lyricParser timeArray]count]; index++) {
        
        
        // 下一个时间戳索引
        NSInteger nextIndex = index+1;
        // 索引未越界 但是当前时间大于下一个时间戳
        // 即下一句歌词的时间戳也已过时
        // 这种情况出现在，用户在播放了很久才开始查看歌词，或者查看歌词过程中关闭又重新点开
        if (nextIndex < [_lyricParser.timeArray count] && currentTime >= [[_lyricParser timeArray][nextIndex]doubleValue]) {
            continue;
        }
        
        
        // 找到匹配时间戳
        if (currentTime >= [[_lyricParser timeArray][index]doubleValue]) {
            
            // 如果是第一次尝试就成功，将下一次的开始索引设置为当前索引的后一位
            if (_lyricParser.startIndex == index) {
                _lyricParser.startIndex = index+1;
            }
            // 否则下次的开始索引为当前索引
            else{
                [_lyricParser setStartIndex:index];
            }
            
            // 高亮歌词视图的当前索引值的歌词
            [_lyricParser setHighlightIndex:index];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            
            break;
        }
    }

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

@end
