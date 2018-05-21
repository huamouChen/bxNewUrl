//
//  CHMAccountSettingCell.m
//  MiniChat
//
//  Created by 陈华谋 on 02/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMAccountSettingCell.h"

@interface CHMAccountSettingCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end

@implementation CHMAccountSettingCell


- (void)setInfoDict:(NSDictionary *)infoDict {
    _infoDict = infoDict;
    _nameLabel.text = _infoDict[KTitle];
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
