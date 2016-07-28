//
//  AINReadingRecommendCell.m
//  AIN
//
//  Created by Lolo on 16/6/23.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINReadingRecommendCell.h"
#import "ONEColumnItem.h"

@interface AINReadingRecommendCell ()
@property (strong, nonatomic) ONEColumnItem* coloumnItem;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet UITextView *excerptText;

@end

@implementation AINReadingRecommendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.numberLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.subtitleLabel.textColor = [UIColor whiteColor];
    self.excerptText.textColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIndex:(NSInteger)index{
    self.numberLabel.text = [NSString stringWithFormat:@"%d",index];
}

- (void)setColumnItem:(ONEColumnItem *)columnItem{
    _coloumnItem = columnItem;
    
//    self.numberLabel.text = [NSString stringWithFormat:@"%d",columnItem.number];
    self.titleLabel.text = columnItem.title;
    self.subtitleLabel.text = columnItem.author;
    self.excerptText.text = columnItem.introduction;
}

@end
