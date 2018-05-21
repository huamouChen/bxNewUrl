//
//  CHMUserPortraitCell.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/10.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMUserPortraitCell.h"

@interface CHMUserPortraitCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *portraitImageView;
@end

@implementation CHMUserPortraitCell

- (void)setInfoDict:(NSDictionary *)infoDict {
    _infoDict = infoDict;
    _nameLabel.text = _infoDict[KItemName];
    [_portraitImageView chm_imageViewWithURL:_infoDict[KItemValue] placeholder:KDefaultPortrait];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
