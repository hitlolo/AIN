//
//  AINMovieDetailKeywordsCell.m
//  AIN
//
//  Created by Lolo on 16/7/10.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINMovieDetailKeywordsCell.h"
#import "AINMovieKeywordCell.h"

static NSString* const iKeywordCellIdentifier = @"iKeywordCellIdentifier";
@interface AINMovieDetailKeywordsCell ()
<UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray* keywordArray;
@end

@implementation AINMovieDetailKeywordsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self prepare];
}


- (void)prepare{
    [(UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout setEstimatedItemSize:CGSizeMake(120, 30)];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    UINib* nib = [UINib nibWithNibName:@"AINMovieKeywordCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:iKeywordCellIdentifier];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setKeywords:(NSString *)keywords{
    self.keywordArray = [keywords componentsSeparatedByString:@";"];
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AINMovieKeywordCell *cell = (AINMovieKeywordCell*)[collectionView dequeueReusableCellWithReuseIdentifier:iKeywordCellIdentifier forIndexPath:indexPath];
    [cell setKeyword:self.keywordArray[indexPath.row]];
    // Configure the cell
    return cell;
}

#pragma mark <UICollectionViewDelegate>


// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}



// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
@end
