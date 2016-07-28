//
//  AINMovieDetailInfoCell.m
//  AIN
//
//  Created by Lolo on 16/7/10.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINMovieDetailInfoCell.h"

@interface AINMovieDetailInfoCell ()
@property (strong, nonatomic) IBOutlet UITextView *infoText;

@end

@implementation AINMovieDetailInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMovieInfo:(NSString *)info{
    self.infoText.text = info;
}

@end
