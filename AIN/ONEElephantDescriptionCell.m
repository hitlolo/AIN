//
//  ONEElephantDescriptionCell.m
//  One
//
//  Created by Lolo on 16/5/17.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEElephantDescriptionCell.h"
#import "ONEElephantArticleBrief.h"
@interface ONEElephantDescriptionCell ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *authorImage;
@property (strong, nonatomic) IBOutlet UITextView *excerptText;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) IBOutlet UILabel *readNumberLabel;
@end

@implementation ONEElephantDescriptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.authorImage.layer.masksToBounds = YES;
    self.authorImage.layer.cornerRadius = 5.0f;
//    self.authorImage.layer.borderColor = one_tintColor.CGColor;
//    self.authorImage.layer.borderWidth = 2.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setArticle:(ONEElephantArticleBrief *)articleBrief{
    
    
    self.titleLabel.text = articleBrief.title;
    self.authorLabel.text = articleBrief.author;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.authorLabel.textColor = [UIColor whiteColor];
    
    self.excerptText.text = articleBrief.brief;
    self.excerptText.textColor = [[UITextView appearance]textColor];
    self.timeLabel.text = [HITDateHelper getDateByTimeInterval:articleBrief.create_time];
    self.readNumberLabel.text = [NSString stringWithFormat:@"阅读量:%@",articleBrief.read_num];
    
    NSURL* url = [NSURL URLWithString:articleBrief.headpic];
    UIImage* placeHolder = one_placeHolder_elephant;
    [self.authorImage sd_setImageWithURL:url placeholderImage:placeHolder];
    
    //[self setTextSize];
}

- (void)setTextSize{
    //self.timeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    //self.authorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.excerptText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    //self.timeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    //self.readNumberLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}
@end
