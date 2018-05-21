//
//  CHMGroupSettingCell.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/6.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMGroupSettingCell.h"


@interface CHMGroupSettingCell ()
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemValueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *portraitImageView;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrowImageView;

@end

@implementation CHMGroupSettingCell
// 开关的值变化
- (IBAction)switchButtonClick:(UISwitch *)sender {
    if (self.switchClickBlock) {
        self.switchClickBlock(self.indexPath, self.switchButton);
    }
}

#pragma mark - setter
- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
}

- (void)setInfoDict:(NSDictionary *)infoDict {
    _infoDict = infoDict;
    _itemNameLabel.text = _infoDict[KItemName];
    // 是否显示开关，如果显示开关，就隐藏其他的
    BOOL isShowSwitch = [_infoDict[KItemIsShowSwitch] isEqualToString:@"1"];
    _switchButton.on = [_infoDict[KItemSwitch] isEqualToString:@"1"];
    if (isShowSwitch) {
        _rightArrowImageView.hidden = YES;
        _itemValueLabel.hidden = YES;
        _portraitImageView.hidden = YES;
        _switchButton.hidden = NO;
    } else {
        _switchButton.hidden = YES;
        _rightArrowImageView.hidden = NO;
        // 头像和名字只显示一个
        if ([_infoDict[KItemPortrait] isEqualToString:@""]) {
            _portraitImageView.hidden = YES;
            _itemValueLabel.hidden = NO;
        } else {
            _portraitImageView.hidden = NO;
            _itemValueLabel.hidden = YES;
        }
    }
    _itemValueLabel.text = _infoDict[KItemValue];
    [_portraitImageView chm_imageViewWithURL:_infoDict[KItemPortrait] placeholder:KDefaultPortrait];
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
