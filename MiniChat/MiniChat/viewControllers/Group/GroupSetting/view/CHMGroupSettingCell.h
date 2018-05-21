//
//  CHMGroupSettingCell.h
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/6.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SwitchButtonClickBlock)(NSIndexPath *selectedIndexPath, UISwitch *switchBtn);


@interface CHMGroupSettingCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *infoDict;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) SwitchButtonClickBlock switchClickBlock;

@end
