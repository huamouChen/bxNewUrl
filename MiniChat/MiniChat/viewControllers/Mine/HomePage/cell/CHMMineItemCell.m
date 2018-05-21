//
//  CHMMineItemCell.m
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMMineItemCell.h"


@interface CHMMineItemCell ()
@property (weak, nonatomic) IBOutlet UIImageView *symbolImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end


@implementation CHMMineItemCell

- (void)setInfoDict:(NSDictionary *)infoDict {
    _infoDict = infoDict;
    _symbolImg.image = [UIImage imageNamed:infoDict[KPortrait]];
    _nameLabel.text =infoDict[KNickName];
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
