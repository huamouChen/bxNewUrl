//
//  CHMGroupSettingFooter.h
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/6.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DismissButtonClickBlock)(void);

@interface CHMGroupSettingFooter : UITableViewHeaderFooterView

@property (nonatomic, strong) UIButton *dismissButton;

@property (nonatomic, copy) DismissButtonClickBlock dismissButtonClickBlock;

+ (instancetype)groupSettingFooterViewTableView:(UITableView *)tableView;

@end
