//
//  CHMPushSettingController.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/11.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMPushSettingController.h"
#import "CHMNewMsgSettingCell.h"

static NSString *const reuseId = @"CHMNewMsgSettingCell";

@interface CHMPushSettingController ()
@property(nonatomic, assign) BOOL isReceiveNotification;
@end

@implementation CHMPushSettingController

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
    
    self.title = @"推送设置";
    
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
    cell.itemNameLabel.text = @"显示远程推送的内容";
    [cell.switchButton addTarget:self action:@selector(switchValueChang:) forControlEvents:UIControlEventValueChanged];
    [cell.switchButton setOn:[RCIMClient sharedRCIMClient].pushProfile.isShowPushContent];
    return cell;
}


/**
 switch  切换
 */
- (void)switchValueChang:(UISwitch *)switchBtn {
    if (switchBtn.on) {
        [[RCIMClient sharedRCIMClient].pushProfile updateShowPushContentStatus:YES
                                                                       success:^{
                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                               [CHMProgressHUD showSuccessWithInfo:@"设置成功"];
                                                                           });
                                                                       }
                                                                         error:^(RCErrorCode status) {
                                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                                 [CHMProgressHUD showErrorWithInfo:@"设置失败"];
                                                                             });
                                                                         }];
    } else {
        [[RCIMClient sharedRCIMClient].pushProfile updateShowPushContentStatus:NO
                                                                       success:^{
                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                               [CHMProgressHUD showSuccessWithInfo:@"设置成功"];
                                                                           });
                                                                       }
                                                                         error:^(RCErrorCode status) {
                                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                                 [CHMProgressHUD showErrorWithInfo:@"设置失败"];
                                                                             });
                                                                         }];
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
