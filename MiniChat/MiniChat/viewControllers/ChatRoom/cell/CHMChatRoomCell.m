//
//  CHMChatRoomCell.m
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMChatRoomCell.h"
#import "CHMChatRoomModel.h"

@interface CHMChatRoomCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation CHMChatRoomCell

- (void)setChatRoomModel:(CHMChatRoomModel *)chatRoomModel {
    _chatRoomModel = chatRoomModel;
    [_headerImageView chm_imageViewWithURL:_chatRoomModel.GroupImage placeholder:KDefaultPortrait];
    _nameLabel.text = _chatRoomModel.GroupName;
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
