//
//  CHMUserDetailFooter.h
//  MiniChat
//
//  Created by 陈华谋 on 03/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SendMessageBlock)(void);

@interface CHMUserDetailFooter : UITableViewHeaderFooterView

+ (instancetype)footerWithTableView:(UITableView *)tableView;

@property (nonatomic, copy) NSString *footerTitler;

// 点击发送消息的block
@property (nonatomic, copy) SendMessageBlock sendMessageBlock;

@end
