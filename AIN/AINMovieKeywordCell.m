//
//  AINMovieKeywordCell.m
//  AIN
//
//  Created by Lolo on 16/7/10.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINMovieKeywordCell.h"

@interface AINMovieKeywordCell ()
@property (strong, nonatomic) IBOutlet UILabel *keywordLabel;

@end

@implementation AINMovieKeywordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setKeyword:(NSString *)keyword{
    
    if (keyword == nil) {
        return;
    }
    //下划线
    
    NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleThick],
                                 NSBaselineOffsetAttributeName: [NSNumber numberWithFloat:2.0f]};
    
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:keyword attributes:attribtDic];

    self.keywordLabel.attributedText = attribtStr;
}
@end
