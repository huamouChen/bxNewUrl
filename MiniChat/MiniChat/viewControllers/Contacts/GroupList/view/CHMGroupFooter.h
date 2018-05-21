//
//  CHMGroupFooter.h
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/5.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHMGroupFooter : UITableViewHeaderFooterView
@property (strong, nonatomic)  UILabel *footerTitleLabel;

+ (instancetype)footerWithTableView:(UITableView *)tableView;
@end
