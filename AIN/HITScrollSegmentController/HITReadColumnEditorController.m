//
//  HITReadColumnEditorController.m
//  One
//
//  Created by Lolo on 16/5/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITReadColumnEditorController.h"
#import "HITReadColumnCell.h"
#import "HITReadColunmHeader.h"
#import "HITReadColunmFooter.h"
#import <AudioToolbox/AudioServices.h>
static NSString* const iCellIdentifier = @"columCell";
static NSString* const iFooterIdentifier = @"columnFooter";
static NSString* const iHeaderIdentifier = @"columnHeader";

@interface HITReadColumnEditorController ()
<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic,strong)id<UIViewControllerTransitioningDelegate> transitionObject;
@property(nonatomic,strong)UIView* promptView;
@property(nonatomic,strong)UIButton* cancelButton;
@property(nonatomic,strong)UIButton* doneButton;
@property(nonatomic,strong)UICollectionView* columnsCollection;
@property(nonatomic,strong)UIButton* deleteButton;
@property(nonatomic,strong)NSIndexPath* selectedIndexPath;
@property(nonatomic,assign)BOOL deleteActived;
@property(nonatomic,assign)BOOL haveChange;
@end

@implementation HITReadColumnEditorController


- (instancetype)init{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare{
    self.transitionObject = [[HITReadColumnEditorTransition alloc]init];
    self.transitioningDelegate = self.transitionObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _deleteActived = NO;
    _haveChange = NO;
    
    [self.view setClipsToBounds:YES];    
    _columnsCollection.delegate = self;
    _columnsCollection.dataSource = self;
    [_columnsCollection registerClass:[HITReadColumnCell class] forCellWithReuseIdentifier:iCellIdentifier];

    [_columnsCollection registerClass:[HITReadColunmHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:iHeaderIdentifier];
    
    [(UICollectionViewFlowLayout*)_columnsCollection.collectionViewLayout setEstimatedItemSize:CGSizeMake(80, 25)];
    
    [(UICollectionViewFlowLayout*)_columnsCollection.collectionViewLayout setHeaderReferenceSize:CGSizeMake(100, 25)];

    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]init];
    [longPress addTarget:self action:@selector(handleColumnsReorder:)];
    [_columnsCollection addGestureRecognizer:longPress];
    
    UITapGestureRecognizer* twoTap = [[UITapGestureRecognizer alloc]init];
    twoTap.numberOfTapsRequired = 2;
    [twoTap addTarget:self action:@selector(handleColumnDelete:)];
    [_columnsCollection addGestureRecognizer:twoTap];

}

- (void)loadView{
    [super loadView];
    
    [self loadPromptView];
    
    [self loadColumnsCollectionView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPromptView{
    
    _promptView = [UIView new];
    _promptView.backgroundColor = [UIColor colorWithRed:0.8945 green:0.8926 blue:0.9249 alpha:1.0];
    _promptView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_promptView];
    [_promptView.topAnchor constraintLessThanOrEqualToAnchor:self.view.topAnchor].active = YES;
    [_promptView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [_promptView.heightAnchor constraintLessThanOrEqualToConstant:44.0f].active = YES;
    [_promptView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    
    UILabel* promptLabel = [UILabel new];
    promptLabel.text = @"编辑栏目";
    promptLabel.textColor = [UIColor lightGrayColor];
    [_promptView addSubview:promptLabel];
    promptLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [promptLabel.leadingAnchor constraintEqualToAnchor:_promptView.layoutMarginsGuide.leadingAnchor].active = YES;
    [promptLabel.centerYAnchor constraintEqualToAnchor:_promptView.centerYAnchor].active = YES;
    
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelButton setTintColor:[UIColor colorWithRed:0.5798 green:0.5798 blue:0.5798 alpha:1.0]];
    [_cancelButton addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_promptView addSubview:_cancelButton];
    [_cancelButton.trailingAnchor constraintEqualToAnchor:_promptView.layoutMarginsGuide.trailingAnchor].active = YES;
    [_cancelButton.centerYAnchor constraintEqualToAnchor:_promptView.centerYAnchor].active = YES;

// TODO: Done button
}

- (void)loadColumnsCollectionView{
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    flowLayout.itemSize = CGSizeMake(65, 30);
    flowLayout.minimumInteritemSpacing = 8;
    flowLayout.minimumLineSpacing = 20;
    flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
    _columnsCollection = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _columnsCollection.backgroundColor = [UIColor colorWithRed:0.9255 green:0.9216 blue:0.9529 alpha:1.0];
    
    [self.view addSubview:_columnsCollection];
    _columnsCollection.translatesAutoresizingMaskIntoConstraints = NO;
    [_columnsCollection.topAnchor constraintEqualToAnchor:_promptView.bottomAnchor].active = YES;
    [_columnsCollection.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [_columnsCollection.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [_columnsCollection.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    
}


- (UIButton*)deleteButton{
    if (_deleteButton == nil) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setFrame:CGRectMake(70, -10, 20, 20)];
        [_deleteButton setImage:[UIImage imageNamed:@"hit_column_delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(moveColumnToOffStage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)exit{
    if (_deleteActived) {
        [self.deleteButton removeFromSuperview];
        _deleteActived = NO;
    }
    else{
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate columnEditorDidFinishEditing:_haveChange];
        }];
    }
    
}

- (void)moveColumnToOffStage:(UIButton*)sender{
  
    [self.delegate columnEditorDidDeleteColumnFromOnstageAtIndexPath:_selectedIndexPath inCollectionView:self.columnsCollection];
    _selectedIndexPath = nil;
    [sender removeFromSuperview];
    _deleteActived = NO;
    _haveChange = YES;
}

#pragma mark - Collection view datasource & delegate

- (void)handleColumnDelete:(UITapGestureRecognizer*)twoTap{
    
    if (twoTap.state == UIGestureRecognizerStateRecognized) {
            _selectedIndexPath = [self.columnsCollection indexPathForItemAtPoint:[twoTap locationInView:self.columnsCollection]];
        
        if (_selectedIndexPath.section == 0 && _selectedIndexPath.row != 0) {
            HITReadColumnCell* cell = (HITReadColumnCell*)[self.columnsCollection cellForItemAtIndexPath:_selectedIndexPath];
            CGRect rect = [cell convertRect:CGRectMake(70, -10, 20, 20) toView:self.columnsCollection];
            [self.deleteButton setFrame:rect];
            [self.columnsCollection addSubview:self.deleteButton];
            _deleteActived = YES;
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
            
    }

}

- (void)handleColumnsReorder:(UILongPressGestureRecognizer*)longPress{
    switch(longPress.state) {
        case UIGestureRecognizerStateBegan:{
            NSIndexPath* selectedIndexPath = [self.columnsCollection indexPathForItemAtPoint:[longPress locationInView:self.columnsCollection]];
            if (selectedIndexPath) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            
            [self.columnsCollection beginInteractiveMovementForItemAtIndexPath:selectedIndexPath];
        }
            break;
        case UIGestureRecognizerStateChanged:{
            [self.columnsCollection updateInteractiveMovementTargetPosition:[longPress locationInView:self.columnsCollection]];
        }
            break;
        case UIGestureRecognizerStateEnded:{
            [self.columnsCollection endInteractiveMovement];
        }
            break;
        case UIGestureRecognizerStateCancelled:{
            [self.columnsCollection cancelInteractiveMovement];
        }
            break;
        default:
            [self.columnsCollection cancelInteractiveMovement];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger number =  [self.datasource numberOfColumnsForSection:section];
    return number;
}


- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    
    HITReadColumnCell* columnCell = [collectionView dequeueReusableCellWithReuseIdentifier:iCellIdentifier forIndexPath:indexPath];
    HITReadColumn* column = [self.datasource columnForColumnEditorAtIndexPath:indexPath];
    [columnCell setColumn:column];
    
    return columnCell;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    
    HITReadColunmHeader* header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:iHeaderIdentifier forIndexPath:indexPath];
    NSString* prompt = [self.datasource promptTitleOfHeaderForSection:indexPath.section];
    
    [header setPrompt:prompt];
    return header;
}



// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath{
    [self.delegate columnEditorDidMoveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    _haveChange = YES;
}
@end
