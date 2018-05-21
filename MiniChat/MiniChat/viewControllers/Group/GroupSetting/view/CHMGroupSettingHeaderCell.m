//
//  CHMGroupSettingHeaderCell.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/6.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMGroupSettingHeaderCell.h"
#import "CHMGroupMemberModel.h"


@interface CHMGroupSettingHeaderCell ()
@property (weak, nonatomic) IBOutlet UIImageView *portraitImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@end

@implementation CHMGroupSettingHeaderCell

- (void)setGroupMemberModel:(CHMGroupMemberModel *)groupMemberModel {
    _groupMemberModel = groupMemberModel;
    [_portraitImageView chm_imageViewWithURL:_groupMemberModel.HeaderImage placeholder:@"icon_person"];
    _nickNameLabel.text = _groupMemberModel.NickName;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
