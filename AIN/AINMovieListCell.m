//
//  AINMovieListCell.m
//  AIN
//
//  Created by Lolo on 16/7/8.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINMovieListCell.h"

@interface AINMovieListCell ()

@property (strong, nonatomic) IBOutlet UIImageView *movieCoverImage;
@end

@implementation AINMovieListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCoverImage:(NSString *)url{
    NSURL* imageURL = [NSURL URLWithString:url];
    [self.movieCoverImage sd_setImageWithURL:imageURL placeholderImage:one_placeHolder_movie];
}

@end
