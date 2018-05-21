//
//  CHMMineController.m
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMMineController.h"
#import "CHMMineDetailCell.h"
#import "CHMMineItemCell.h"
#import "CHMAccountSettingController.h"
#import "RCDCustomerServiceViewController.h"
#import "CHMAboutController.h"
#import "CHMUserInfoController.h"

static NSString *const detailReuseablId = @"CHMMineDetailCell";
static NSString *const itemReuseablId = @"CHMMineItemCell";

@interface CHMMineController ()

@property (nonatomic, strong) NSArray *datasArray;

@end

@implementation CHMMineController


#pragma mark - view life cycler
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 修改头像通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPortrait:) name:KChangeUserInfoNotification object:nil];
    
    [self setupAppearance];
    
    [self initData];
}

/**
 刷新头像
 */
- (void)reloadPortrait:(NSNotification *)noti {
    [self initData];
    [self.tableView reloadData];
}

/**
 设置控件
 */
- (void)setupAppearance {
    // 设置尾部视图
    self.tableView.tableFooterView = [UIView new];
    
    // register cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CHMMineDetailCell class]) bundle:nil] forCellReuseIdentifier:detailReuseablId];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CHMMineItemCell class]) bundle:nil] forCellReuseIdentifier:itemReuseablId];
    
    // auto estima height
    self.tableView.estimatedRowHeight = 70;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.backgroundColor = [UIColor chm_colorWithHexString:KTableViweBackgroundColor alpha:1.0];
}


/**
 初始化数据
 */
- (void)initData {
    // 从沙盒中取登录时保存的用户信息
    NSString *nickName = [[NSUserDefaults standardUserDefaults] valueForKey:KNickName];
    NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:KAccount];
    NSString *portrait = [[NSUserDefaults standardUserDefaults] valueForKey:KPortrait];
    
    self.datasArray = @[@[@{KPortrait:portrait, KNickName: nickName, KAccount: account}],
                        @[@{KPortrait:@"setting_up", KNickName: @"帐号设置"}],
                        @[@{KPortrait:@"sevre_inactive", KNickName: @"意见反馈"},
                          @{KPortrait:@"about_rongcloud", KNickName: @"关于博信"}]];
    
//    @{KPortrait:@"wallet", KNickName: @"我的钱包"}
}


#pragma mark - table view data sourece
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datasArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = self.datasArray[section];
    return sectionArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CHMMineDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:detailReuseablId];
        cell.infoDict = self.datasArray[indexPath.section][indexPath.row];
        return cell;
    }
    
    CHMMineItemCell *cell = [tableView dequeueReusableCellWithIdentifier:itemReuseablId];
    cell.infoDict = self.datasArray[indexPath.section][indexPath.row];
    return cell;
}


#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) { // 个人信息
        [self.navigationController pushViewController:[CHMUserInfoController new] animated:YES];
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) { // 账号设置
            [self.navigationController pushViewController:[CHMAccountSettingController new] animated:YES];
        }
    }
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) { // 意见反馈
            [self feedBackCellClick];
        }
        if (indexPath.row == 1) { // 关于博信
            [self.navigationController pushViewController:[CHMAboutController new] animated:YES];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionView = [UIView new];
    sectionView.backgroundColor = [UIColor chm_colorWithHexString:KTableViweBackgroundColor alpha:1.0];
    return sectionView;
}



#pragma mark - 意见反馈
- (void)feedBackCellClick {
    RCDCustomerServiceViewController *chatService = [[RCDCustomerServiceViewController alloc] init];
    chatService.conversationType = ConversationType_CUSTOMERSERVICE;
    chatService.targetId = SERVICE_ID;
    chatService.title = @"客服";
    chatService.hidesBottomBarWhenPushed = YES;
//    chatService.csInfo = csInfo; //用户的详细信息，此数据用于上传用户信息到客服后台，数据的nickName和portraitUrl必须填写。(目前该字段暂时没用到，客服后台显示的用户信息是你获取token时传的参数，之后会用到）
    [self.navigationController pushViewController :chatService animated:YES];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
