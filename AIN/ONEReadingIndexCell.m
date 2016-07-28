//
//  ONEReadingIndexCell.m
//  One
//
//  Created by Lolo on 16/4/29.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEReadingIndexCell.h"

@interface ONEReadingIndexCell()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *infoImage;

@end


@implementation ONEReadingIndexCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setArticle:(id<AINArticleDescription>)article{
    self.titleLabel.text = [article articleTitle];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    AINArticleType type = [article articleType];
    switch (type) {
        case Essay:
            [self.infoImage setImage:[UIImage imageNamed:@"essay_image"]];
            break;
        case Serial:
            [self.infoImage setImage:[UIImage imageNamed:@"serial_image"]];
            break;
        case Question:
            [self.infoImage setImage:[UIImage imageNamed:@"question_image"]];
            break;
        default:
            break;
    }

}


+ (CGFloat)cellHeightForTableView:(UITableView *)tableView data:(NSString*)data{
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 21)];
    contentLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    contentLabel.numberOfLines = 0;
    [contentLabel setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
    contentLabel.text = data;
    [contentLabel sizeToFit];
    
    
    CGFloat cellHeight = ceil(contentLabel.height + 32.0f);
    
    return cellHeight;
}

@end
