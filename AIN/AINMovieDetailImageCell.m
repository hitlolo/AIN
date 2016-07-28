//
//  AINMovieDetailImageCell.m
//  AIN
//
//  Created by Lolo on 16/7/10.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINMovieDetailImageCell.h"
#import "AINMovieImageCell.h"

static NSString* const iImageCellIdentifier = @"iImageCellIdentifier";
@interface AINMovieDetailImageCell ()
<UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray* photoArray;


@end

@implementation AINMovieDetailImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self prepare];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepare{
    [(UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout setItemSize:CGSizeMake(200,150)];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    UINib* nib = [UINib nibWithNibName:@"AINMovieImageCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:iImageCellIdentifier];
    
}

- (void)setPhotos:(NSArray *)photos{
    self.photoArray = [photos copy];
    [self.collectionView reloadData];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.photoArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AINMovieImageCell *cell = (AINMovieImageCell*)[collectionView dequeueReusableCellWithReuseIdentifier:iImageCellIdentifier forIndexPath:indexPath];
    
    NSString* urlString = self.photoArray[indexPath.row];
    NSURL* url = [NSURL URLWithString:urlString];
    [cell.imageView sd_setImageWithURL:url];
    // Configure the cell
    return cell;
}

#pragma mark <UICollectionViewDelegate>


// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate) {
        [self.delegate tappedOnImageSource:self startIndex:indexPath.row];
    }
}


#pragma mark - HITImageController delegate & datasource

//- (void)imageController:(HITImageController *)imagecontroller didSlideToImageIndex:(NSInteger)index{
//    NSIndexPath* indexpath = [NSIndexPath indexPathForRow:index inSection:0];
//    [self.collectionView scrollToItemAtIndexPath:indexpath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
//}

- (void)imageController:(HITImageController *)imagecontroller willDissmissFromImageIndex:(NSInteger)index{
    
    NSIndexPath* indexpath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexpath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (NSInteger)numberOfImagesForImageController:(HITImageController *)imagecontroller{
    return [self.photoArray count];
}

- (NSURL*)imageController:(HITImageController *)imagecontroller urlOfImageAtIndex:(NSInteger)index {
    return [NSURL URLWithString:self.photoArray[index]];
}

- (CGRect)imageController:(HITImageController *)imagecontroller originalFrameOfImageAtIndex:(NSInteger)index{
    
    NSIndexPath* indexpath = [NSIndexPath indexPathForRow:index inSection:0];
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexpath];
    
    CGFloat offsetX = self.collectionView.contentOffset.x;
    CGFloat offsetY = self.collectionView.contentOffset.y;
    CGFloat insetX;
    CGFloat insetY;
    
    UICollectionViewFlowLayout* flowlayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    
    insetX = flowlayout.minimumInteritemSpacing;
    insetY = flowlayout.minimumLineSpacing;
    
    CGRect frame = CGRectMake(cell.frame.origin.x - offsetX + insetX , cell.frame.origin.y - offsetY + insetY, cell.frame.size.width, cell.frame.size.height);
    CGRect rect = [self convertRect:frame toView:[UIApplication sharedApplication].keyWindow];
    
    return rect;
}


@end
