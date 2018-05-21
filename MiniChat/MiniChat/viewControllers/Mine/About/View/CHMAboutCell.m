//
//  CHMAboutCell.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/9.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMAboutCell.h"

@interface CHMAboutCell ()
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subItemLabel;
@end


@implementation CHMAboutCell

- (void)setInfoDict:(NSDictionary *)infoDict {
    _infoDict = infoDict;
    _itemNameLabel.text = _infoDict[@"item"];
    _subItemLabel.text = _infoDict[@"subItem"];
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
