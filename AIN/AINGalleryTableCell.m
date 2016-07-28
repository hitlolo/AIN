//
//  AINGalleryTableCell.m
//  AIN
//
//  Created by Lolo on 16/6/2.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINGalleryTableCell.h"
#import "AINPainting.h"


@interface AINGalleryTableCell()

@property (strong, nonatomic) AINPainting* painting;

@property (strong, nonatomic) IBOutlet UIView *cellBackground;
@property (strong, nonatomic) IBOutlet UIImageView *mottoBackground;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *paintingImage;
@property (strong, nonatomic) IBOutlet UITextView *mottoText;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;

@property (strong, nonatomic) IBOutlet UILabel *commentNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *praisedNumLabel;

@end

@implementation AINGalleryTableCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.mottoText.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 0);
    
    UITapGestureRecognizer* oneTap = [[UITapGestureRecognizer alloc]init];
    [oneTap setNumberOfTapsRequired:1];
    [oneTap addTarget:self action:@selector(imageTapped:)];
    [self.paintingImage addGestureRecognizer:oneTap];
    [self.paintingImage setUserInteractionEnabled:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)setBackgroundImage:(UIImage *)backgroundImage{
    _backgroundImage = backgroundImage;
    [self.mottoBackground setImage:_backgroundImage];
}

- (void)setMottoTextColor:(UIColor *)mottoTextColor{
    [self.mottoText setTextColor:mottoTextColor];
}


- (void)setPainting:(AINPainting *)painting{
    _painting = painting;
    
    self.dateLabel.text = [HITDateHelper getDayMonthYear:painting.hp_makettime];
    self.authorLabel.text = painting.hp_author;
    self.commentNumLabel.text = [NSString stringWithFormat:@"%ld",painting.commentnum];
    self.praisedNumLabel.text = [NSString stringWithFormat:@"%ld",painting.praisenum];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    
    
   
    NSDictionary *attribute = @{
                  NSParagraphStyleAttributeName : paragraphStyle,
                  NSForegroundColorAttributeName : [[UITextView appearanceWhenContainedInInstancesOfClasses:@[[AINGalleryTableCell class]]]textColor],
                  NSFontAttributeName : [UIFont systemFontOfSize:16]
                  };
   
    self.mottoText.attributedText = [[NSAttributedString alloc] initWithString:painting.hp_content attributes:attribute];
//    self.mottoText.text = painting.hp_content;
    
    NSURL* url = [NSURL URLWithString:painting.hp_img_url];
    [self.paintingImage sd_setImageWithURL:url placeholderImage:one_placeHolder_image];
}

#pragma mark - HITImageController delegate & datasource

- (void)imageTapped:(UITapGestureRecognizer*)oneTap{
    if (self.delegate) {
        [self.delegate tappedOnImageSource:self startIndex:0];
    }
}

- (NSInteger)numberOfImagesForImageController:(HITImageController *)imagecontroller{
    return 1;
}

- (NSURL*)imageController:(HITImageController *)imagecontroller urlOfImageAtIndex:(NSInteger)index {
    return [NSURL URLWithString:self.painting.hp_img_url];
}

- (CGRect)imageController:(HITImageController *)imagecontroller originalFrameOfImageAtIndex:(NSInteger)index{
    CGRect rect = [self convertRect:self.paintingImage.frame toView:[UIApplication sharedApplication].keyWindow];
    
    return rect;
}
@end
