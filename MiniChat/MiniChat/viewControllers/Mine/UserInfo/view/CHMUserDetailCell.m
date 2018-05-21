//
//  CHMUserDetailCell.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/10.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMUserDetailCell.h"

@interface CHMUserDetailCell ()
@property (weak, nonatomic) IBOutlet UILabel *itemNaleLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemValueLabel;

@end

@implementation CHMUserDetailCell

- (void)setInfoDict:(NSDictionary *)infoDict {
    _infoDict = infoDict;
    _itemNaleLabel.text = _infoDict[KItemName];
    _itemValueLabel.text = _infoDict[KItemValue];
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
