//
//  CHMSeationHeaderView.h
//  MiniChat
//
//  Created by 陈华谋 on 03/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 通讯录界面 组 section header view
 */
@interface CHMSectionHeaderView : UITableViewHeaderFooterView
+ (instancetype)headerWithTableView:(UITableView *)tableView;

/**
 title
 */
@property (copy, nonatomic) NSString *title;

/**
 标题颜色
 */
@property (strong, nonatomic) UIColor *titleColor;

/**
 标题大小
 */
@property (assign, nonatomic) CGFloat titleFont;

/**
 对其方式
 */
@property (assign, nonatomic) NSTextAlignment textAligment;
@end
