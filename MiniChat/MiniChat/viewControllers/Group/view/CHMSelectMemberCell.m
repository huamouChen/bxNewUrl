//
//  CHMSelectMemberCell.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/4.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMSelectMemberCell.h"
#import "CHMFriendModel.h"
#import "CHMGroupMemberModel.h"


@interface CHMSelectMemberCell ()
@property (weak, nonatomic) IBOutlet UIImageView *portraitImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@end


@implementation CHMSelectMemberCell

- (void)setFriendModel:(CHMFriendModel *)friendModel {
    _friendModel = friendModel;
    [_portraitImg chm_imageViewWithURL:_friendModel.HeaderImage placeholder:@"icon_person"];
    _nameLabel.text = _friendModel.NickName;
    [_checkButton setSelected:_friendModel.isCheck];
}

- (void)setGroupMemberModel:(CHMGroupMemberModel *)groupMemberModel {
    _groupMemberModel = groupMemberModel;
    [_portraitImg chm_imageViewWithURL:_groupMemberModel.HeaderImage placeholder:@"icon_person"];
    _nameLabel.text = _groupMemberModel.NickName;
    [_checkButton setSelected:_groupMemberModel.isCheck];
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
