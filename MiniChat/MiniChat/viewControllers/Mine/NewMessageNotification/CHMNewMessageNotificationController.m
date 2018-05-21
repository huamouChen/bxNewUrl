//
//  CHMNewMessageNotificationController.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/9.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMNewMessageNotificationController.h"
#import "CHMNewMsgSettingCell.h"

static NSString *const reuseId = @"CHMNewMsgSettingCell";

@interface CHMNewMessageNotificationController ()
@property(nonatomic, assign) BOOL isReceiveNotification;
@end

@implementation CHMNewMessageNotificationController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[RCIMClient sharedRCIMClient] getNotificationQuietHours:^(NSString *startTime, int spansMin) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (spansMin >= 1439) {
                self.isReceiveNotification = NO;
                [self.tableView reloadData];
            } else {
                self.isReceiveNotification = YES;
                [self.tableView reloadData];
            }
        });
    }
                                                       error:^(RCErrorCode status) {
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               //       cell.switchButton.on = YES;
                                                               self.isReceiveNotification = YES;
                                                               [self.tableView reloadData];
                                                           });
                                                       }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"新消息通知";
    
    self.tableView.tableFooterView = [UIView new];
    
    // register cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CHMNewMsgSettingCell class]) bundle:nil] forCellReuseIdentifier:reuseId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHMNewMsgSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    [cell.switchButton addTarget:self action:@selector(switchValueChang:) forControlEvents:UIControlEventValueChanged];
    [cell.switchButton setOn:self.isReceiveNotification];
    return cell;
}


/**
 switch  切换
 */
- (void)switchValueChang:(UISwitch *)switchBtn {
    if (!switchBtn.on) {
        [[RCIMClient sharedRCIMClient] setNotificationQuietHours:@"00:00:00"
                                                        spanMins:1439
                                                         success:^{
                                                             [CHMProgressHUD showSuccessWithInfo:@"设置成功"];
                                                         } error:^(RCErrorCode status) {
                                                             [CHMProgressHUD showErrorWithInfo:@"设置失败"];
                                                             
                                                         }];
    } else {
        
        [[RCIMClient sharedRCIMClient] removeNotificationQuietHours:^{
            [CHMProgressHUD showSuccessWithInfo:@"设置成功"];
        } error:^(RCErrorCode status) {
            [CHMProgressHUD showErrorWithInfo:@"设置失败"];
            
        }];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
