//
//  CHMNewFriendCell.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/8.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMNewFriendCell.h"
#import "CHMFriendModel.h"

@interface CHMNewFriendCell ()
@property (weak, nonatomic) IBOutlet UIImageView *portrait;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@end

@implementation CHMNewFriendCell
// 接受按钮点击
- (IBAction)acceptButtonClick:(id)sender {
    if (self.acceptButtonClickBlock) {
        self.acceptButtonClickBlock(self.indexPath);
    }
}

- (void)setFriendModel:(CHMFriendModel *)friendModel {
    _friendModel = friendModel;
    [_portrait chm_imageViewWithURL:_friendModel.HeaderImage placeholder:KDefaultPortrait];
    _nameLabel.text = _friendModel.NickName;
    BOOL isAccept = _friendModel.isCheck;
    
    if (isAccept) {
        [_acceptButton setTitle:@"接受" forState:UIControlStateNormal];
        _acceptButton.layer.borderWidth = 0;
        [_acceptButton setBackgroundColor:[UIColor chm_colorWithHexString:KMainColor alpha:1.0]];
        _acceptButton.userInteractionEnabled = YES;
    } else {
        [_acceptButton setTitle:@"已接受" forState:UIControlStateNormal];
        _acceptButton.layer.borderWidth = 1;
        _acceptButton.layer.borderColor = [UIColor chm_colorWithHexString:KSeparatorColor alpha:1.0].CGColor;
        [_acceptButton setBackgroundColor:[UIColor chm_colorWithHexString:@"#eaeaea" alpha:1.0]];
        _acceptButton.userInteractionEnabled = NO;
    }
}




- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
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
