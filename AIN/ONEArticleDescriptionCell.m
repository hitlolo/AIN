//
//  ONEArticleDescriptionCell.m
//  AIN
//
//  Created by Lolo on 16/6/14.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "ONEArticleDescriptionCell.h"


@interface ONEArticleDescriptionCell ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet UITextView *excerptText;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *articleIcon;

@end

@implementation ONEArticleDescriptionCell

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
    self.subtitleLabel.text = [article articleSubtitle];
    self.excerptText.text = [article articleExcerpt];
    self.excerptText.textColor = [[UITextView appearance]textColor];
    self.dateLabel.text = [article articleTime];

    UIImage* icon;
    if ([article articleType] == Essay) {
        icon = one_placeHolder_essay;
    }
    else if ([article articleType] == Serial){
        icon = one_placeHolder_serial;
    }
    else{
        icon = one_placeHolder_question;
    }
    [self.articleIcon setImage:icon];


    [self setTextSize];
}

- (void)setTextSize{
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.excerptText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

@end
