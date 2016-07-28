//
//  AINCommentCell.m
//  AIN
//
//  Created by Lolo on 16/6/3.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINCommentCell.h"
#import "ONEReadingComment.h"

@interface AINCommentCell ()
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) IBOutlet UIStackView *labelStack;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *praisedNumLabel;
@property (strong, nonatomic) IBOutlet UIView *subCommentView;

@property (strong, nonatomic) IBOutlet UILabel *subUserNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *subConentText;
@property (strong, nonatomic) IBOutlet UITextView *contentText;

@property (copy, nonatomic) NSArray* subCommentConstraints;
@property (strong, nonatomic) NSLayoutConstraint* contentTextTopConstraint;

@end

@implementation AINCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.userImage.layer.masksToBounds = YES;
    self.userImage.layer.cornerRadius = 5.0f;
//    self.userImage.layer.borderColor = [UIColor colorWithRed:0.1922 green:0.7137 blue:0.9373 alpha:1.0].CGColor;
//    self.userImage.layer.borderWidth = 2.0f;
    
    self.subCommentView.layer.masksToBounds = YES;
    self.subCommentView.layer.cornerRadius = 2.0f;
    self.subCommentView.layer.borderWidth = 1.0f;
    self.subCommentView.layer.borderColor = [UIColor colorWithRed:0.8196 green:0.7333 blue:0.6314 alpha:0.8].CGColor;
    self.subCommentConstraints = [self.subCommentView constraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSLayoutConstraint*)contentTextTopConstraint{
    if (_contentTextTopConstraint == nil) {
        _contentTextTopConstraint = [NSLayoutConstraint constraintWithItem:self.contentText attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.labelStack attribute:NSLayoutAttributeBottom multiplier:1.0f constant:8];
    }
    return _contentTextTopConstraint;
}

- (void)setComment:(ONEReadingComment *)comment{
    
    NSURL* imageURL = [NSURL URLWithString:comment.user.web_url];
    UIImage* placeHolder = one_placeHolder_head;
    [self.userImage sd_setImageWithURL:imageURL placeholderImage:placeHolder];
    
    self.userNameLabel.text = comment.user.user_name;
    self.dateLabel.text = [HITDateHelper getDayMonthYear:comment.input_date];
    self.praisedNumLabel.text = [NSString stringWithFormat:@"%ld", (long)comment.praisenum];
    
    if (comment.quote == nil || [comment.quote isEqualToString:@""]) {
        
        self.subUserNameLabel.text = nil;
        self.subConentText.text = nil;
        
        if (![self.subCommentView isHidden]) {
            [NSLayoutConstraint deactivateConstraints:self.subCommentView.constraints];
            [self.contentTextTopConstraint setActive:YES];
            
            [self.subCommentView setHidden:YES];
            
        }
        //[self.subCommentView setNeedsUpdateConstraints];
        //[self.subCommentView invalidateIntrinsicContentSize];
        
    }
    else{
        
        if ([self.subCommentView isHidden]) {
            [NSLayoutConstraint activateConstraints:self.subCommentConstraints];
            
            [self.contentTextTopConstraint setActive:NO];
            [self.subCommentView setHidden:NO];
            
        }
        
        
        self.subUserNameLabel.text = [NSString stringWithFormat:@"@%@:",comment.touser.user_name];
        self.subConentText.text = comment.quote;
        
        //[self.subCommentView setNeedsUpdateConstraints];
        //[self.subCommentView invalidateIntrinsicContentSize];
    }
    
    self.contentText.text = comment.content;
}

@end
