//
//  CHMContactCell.m
//  MiniChat
//
//  Created by 陈华谋 on 03/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMContactCell.h"
#import "CHMFriendModel.h"
#import "CHMGroupModel.h"

@interface CHMContactCell ()
@property (weak, nonatomic) IBOutlet UIImageView *portraitImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation CHMContactCell

- (void)setFriendModel:(CHMFriendModel *)friendModel {
    _friendModel = friendModel;
    [_portraitImageView chm_imageViewWithURL:_friendModel.HeaderImage placeholder:KDefaultPortrait];
    _nameLabel.text = _friendModel.NickName;
}

- (void)setGroupModel:(CHMGroupModel *)groupModel {
    _groupModel = groupModel;
    [_portraitImageView chm_imageViewWithURL:_groupModel.GroupImage placeholder:KDefaultPortrait];
    _nameLabel.text = _groupModel.GroupName;
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
