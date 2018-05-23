//
//  CHMUserDetailController.m
//  MiniChat
//
//  Created by 陈华谋 on 03/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMUserDetailController.h"
#import "CHMMineDetailCell.h"
#import "CHMFriendModel.h"
#import "CHMGroupMemberModel.h"
#import "CHMUserDetailFooter.h"
#import "CHMConversationController.h"

static NSString *const detailReuseablId = @"CHMMineDetailCell";

@interface CHMUserDetailController ()

@property (nonatomic, strong) NSArray *datasArray;

// 当前用户的 账号
@property (nonatomic, copy) NSString *targetId;
// 当前用户的 昵称
@property (nonatomic, copy) NSString *nickName;

// 是否是从群组那边进来的，是的话，就更新群组成员本地数据库
@property (nonatomic, assign) BOOL isFromGroup;

@end

@implementation CHMUserDetailController

#pragma mark - 查询用户信息，更新用户信息
/**
 查询用户信息，更新用户信息
 */
- (void)updateUserInfo {
    __weak typeof(self) weakSelf = self;
    [CHMHttpTool searchUserInfoWithUserId:_targetId success:^(id response) {
        NSLog(@"-----------%@",response);
        NSNumber *codeId = response[@"Code"][@"CodeId"];
        if (codeId.integerValue == 100) {
            NSNumber *isExist = response[@"Value"][@"Exist"];
            if (isExist.integerValue == 1) {
                [CHMProgressHUD dismissHUD];
                NSString *userName = response[@"Value"][@"UserName"];
                NSString *nickName = response[@"Value"][@"NickName"];
                NSString *headimg = response[@"Value"][@"Headimg"];
//                NSNumber *relationCode = response[@"Value"][@"Relation"];
                
                nickName = [nickName isKindOfClass:[NSNull class]] || nickName == nil || [nickName isEqualToString:@""]  ? userName : nickName;
                headimg = ([headimg isKindOfClass:[NSNull class] ] || headimg == nil || [headimg isEqualToString:@""]  ? KDefaultPortrait : [NSString stringWithFormat:@"%@%@", BaseURL, headimg]);
                RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:userName name:nickName portrait:headimg];
                weakSelf.datasArray = @[@[@{KPortrait:userInfo.portraitUri, KNickName: userInfo.name, KAccount: userInfo.userId}]];
                [weakSelf.tableView reloadData];
                
                if (weakSelf.isFriend) {
                    // 更新本地数据
                    [[CHMDataBaseManager shareManager] insertUserToDB:userInfo];
                    [[CHMDataBaseManager shareManager] insertFriendToDB:userInfo];
                }

                // 更新群组成员信息
                if (weakSelf.isFromGroup) {
                    [[CHMDataBaseManager shareManager] updateMember:userInfo toGroupId:weakSelf.groupMemberModel.GroupId complete:^(BOOL isComplete) { } ];
                }
                
            }
        } else {
            [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"%@", response[@"Code"][@"Description"]]];
        }
    } failure:^(NSError *error) {
        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"%ld", (long)error.code]];
    }];
    
}

#pragma mark - 点击操作
/**
 点击发消息
 */
- (void)sendMessage {
    //新建一个聊天会话View Controller对象,建议这样初始化
    CHMConversationController *chatController = [[CHMConversationController alloc] initWithConversationType:ConversationType_PRIVATE targetId:_targetId];
    [chatController setHidesBottomBarWhenPushed:YES];
    //设置会话的类型，如单聊、讨论组、群聊、聊天室、客服、公众服务会话等
    chatController.conversationType = ConversationType_PRIVATE;
    //设置会话的目标会话ID。（单聊、客服、公众服务会话为对方的ID，讨论组、群聊、聊天室为会话的ID）
    chatController.targetId = _targetId;
    //设置聊天会话界面要显示的标题
    chatController.title = _nickName;
    //显示聊天会话界面
    [self.navigationController pushViewController:chatController animated:YES];
}


/**
 加为好友
 */
- (void)addFriend {
    [CHMProgressHUD showWithInfo:@"正在发送..." isHaveMask:YES];
    NSString *currentInfo = [[NSUserDefaults standardUserDefaults] valueForKey:KNickName];
    currentInfo = ([currentInfo isEqualToString:@""] || currentInfo == nil) ? [[NSUserDefaults standardUserDefaults] valueForKey:KAccount] : currentInfo;
    [CHMHttpTool addFriendWithUserId:_targetId mark:[NSString stringWithFormat:@"我是%@，想加你为好友",currentInfo] success:^(id response) {
        NSLog(@"-------%@", response);
        NSNumber *codeId = response[@"Code"][@"CodeId"];
        if (codeId.integerValue == 100) {
            [CHMProgressHUD showSuccessWithInfo:@"发送成功"];
        } else {
            [CHMProgressHUD showErrorWithInfo:response[@"Code"][@"Description"]];
        }
    } failure:^(NSError *error) {
        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"错误码--%ld",(long)error.code]];
    }];
}

- (void)footerButtonClick {
    if (_isFriend) {
        [self sendMessage];
    } else {
        [self addFriend];
    }
}

#pragma mark - view life cycler
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    [self setupAppearance];
}

/**
 设置控件
 */
- (void)setupAppearance {
    self.title = @"用户详情";
    // 设置尾部视图
    CHMUserDetailFooter *footer = [CHMUserDetailFooter footerWithTableView:self.tableView];
    footer.footerTitler = _isFriend ? @"发消息" : @"加为好友";
    // 点击发送消息的按钮
    footer.sendMessageBlock = ^{
        [self footerButtonClick];
    };
    self.tableView.tableFooterView = footer;
    
    // register cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CHMMineDetailCell class]) bundle:nil] forCellReuseIdentifier:detailReuseablId];
    
    // auto estima height
    self.tableView.estimatedRowHeight = 70;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.backgroundColor = [UIColor chm_colorWithHexString:KTableViweBackgroundColor alpha:1.0];
}


/**
 初始化数据
 */
- (void)initData {
    
    self.targetId = _friendModel ? _friendModel.UserName : _groupMemberModel.UserName;
    self.nickName = _friendModel ? _friendModel.NickName : _groupMemberModel.NickName;
    
    if (_friendModel) {
        self.datasArray = @[@[@{KPortrait:_friendModel.HeaderImage, KNickName: _friendModel.NickName, KAccount: _friendModel.UserName}]];
    }
    
    if (_groupMemberModel) {
        self.datasArray = @[@[@{KPortrait:_groupMemberModel.HeaderImage, KNickName: _groupMemberModel.NickName == nil ? _groupMemberModel.UserName : _groupMemberModel.NickName, KAccount: _groupMemberModel.UserName}]];
        self.isFromGroup = YES;
    }
    
    RCUserInfo *userInfo = [[CHMDataBaseManager shareManager] getFriendInfo:self.targetId];
    _isFriend = userInfo ? YES : NO;
    
    [self updateUserInfo];
}


#pragma mark - table view data sourece
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *itemArray = self.datasArray[section];
    return itemArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHMMineDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:detailReuseablId];
    cell.infoDict = self.datasArray[indexPath.section][indexPath.row];
    cell.isHideRightArrow = YES;
    return cell;
}


#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionView = [UIView new];
    sectionView.backgroundColor = [UIColor chm_colorWithHexString:KTableViweBackgroundColor alpha:1.0];
    return sectionView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
