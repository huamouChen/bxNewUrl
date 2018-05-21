//
//  CHMConversationController.m
//  MiniChat
//
//  Created by 陈华谋 on 02/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMConversationController.h"
#import "CHMBettingController.h"
#import "CHMGroupSettingController.h"
#import "CHMUserDetailController.h"
#import "CHMFriendModel.h"
#import "CHMGroupTipCell.h"
#import "CHMGroupTipMessage.h"
#import "CHMGroupModel.h"

static NSInteger const bettingTag = 2000;

@interface CHMConversationController ()

@end

@implementation CHMConversationController

#pragma mark - view life  cycler
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [CHMProgressHUD dismissHUD];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.conversationType == ConversationType_GROUP) {
        CHMGroupModel *groupModel = [[CHMDataBaseManager shareManager] getGroupByGroupId:self.targetId];
        self.title = groupModel.GroupName;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //清除历史消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearHistoryMSG:)
                                                 name:KClearHistoryMsg
                                               object:nil];
    
    ///注册自定义测试消息Cell
    [self registerClass:[CHMGroupTipCell class] forMessageClass:[CHMGroupTipMessage class]];
    
    [self setupRightBarButton];
    
    if (self.conversationType == ConversationType_GROUP || self.conversationType == ConversationType_CHATROOM) {
        // 添加拓展框的插件
        [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"AddPhotoDefault"] title:@"玩法" atIndex:0 tag:bettingTag];
    } else { // 其他会话不显示玩法
        if ([self.chatSessionInputBarControl.pluginBoardView viewWithTag:bettingTag]) {
            [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:bettingTag];
        }
    }
}

/**
 扩展框方法响应
 */
- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag {
    [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
    
    // 玩法
    if (tag == bettingTag) {
        CHMBettingController *bettingController = [CHMBettingController new];
        bettingController.targetId = self.targetId;
        bettingController.conversationType = self.conversationType;
        // 设置样式才能设置透明
        bettingController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:bettingController animated:YES completion:nil];
    }
}

#pragma mark 清除聊天记录
- (void)clearHistoryMSG:(NSNotification *)notification {
    [self.conversationDataRepository removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.conversationMessageCollectionView reloadData];
    });
}



#pragma mark - 发送消息
// 发送消息
- (void)sendMessage:(RCMessageContent *)messageContent pushContent:(NSString *)pushContent {
    [super sendMessage:messageContent pushContent:pushContent];
    if (self.conversationType == ConversationType_GROUP || self.conversationType == ConversationType_CHATROOM) {
        if ([messageContent isKindOfClass:[RCTextMessage class]]) {
            RCTextMessage *txtMsg = (RCTextMessage *)messageContent;
            // 把文本消息都发送到服务器
            [CHMHttpTool postTxtMessageToServiceWithMessage:txtMsg.content groupId:self.targetId success:^(id response) {
                NSLog(@"--------%@",response);
            } failure:^(NSError *error) {
                NSLog(@"--------%zd",error.code);
            }];
        }
    }
}

// 发送消息回调
- (void)didSendMessage:(NSInteger)status content:(RCMessageContent *)messageContent {
    if (status == 0) { // 发送成功
    }
}

- (void)setupRightBarButton {
    if (self.conversationType != ConversationType_CHATROOM) {
        if (self.conversationType == ConversationType_DISCUSSION) {
            [[RCIMClient sharedRCIMClient]
             getDiscussion:self.targetId
             success:^(RCDiscussion *discussion) {
                 if (discussion != nil && discussion.memberIdList.count > 0) {
                     if ([discussion.memberIdList
                          containsObject:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
                         [self setRightNavigationItem:[UIImage imageNamed:@"Private_Setting"]
                                            withFrame:CGRectMake(0 , 0, 16, 18.5)];
                     } else {
                         self.navigationItem.rightBarButtonItem = nil;
                     }
                 }
             }
             error:^(RCErrorCode status){
                 
             }];
        } else if (self.conversationType == ConversationType_GROUP) {
            [self setRightNavigationItem:[UIImage imageNamed:@"Group_Setting"] withFrame:CGRectMake(0,0, 21, 19.5)];
        } else {
            [self setRightNavigationItem:[UIImage imageNamed:@"Private_Setting"]
                               withFrame:CGRectMake(0, 0, 16, 18.5)];
        }
        
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)setRightNavigationItem:(UIImage *)image withFrame:(CGRect)frame {
    CHMBarButtonItem *rightBtn = [[CHMBarButtonItem alloc] initContainImage:image imageViewFrame:frame buttonTitle:nil
                                                                 titleColor:nil
                                                                 titleFrame:CGRectZero
                                                                buttonFrame:frame
                                                                     target:self
                                                                     action:@selector(rightBarButtonItemClicked:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

#pragma mark - 点击navigationBar right item
/**
 *  此处使用自定义设置，开发者可以根据需求自己实现
 *  不添加rightBarButtonItemClicked事件，则使用默认实现。
 */
- (void)rightBarButtonItemClicked:(id)sender {
    [self.view endEditing:YES];
    
    if (self.conversationType == ConversationType_PRIVATE) {
        
        CHMUserDetailController *userDetailController = [CHMUserDetailController new];
        RCUserInfo *userInfo = [[CHMDataBaseManager shareManager] getFriendInfo:self.targetId];
        CHMFriendModel *friendModel = [[CHMFriendModel alloc] initWithUserId:userInfo.userId nickName:userInfo.name portrait:userInfo.portraitUri];
        userDetailController.friendModel = friendModel;
        [self.navigationController pushViewController:userDetailController animated:YES];
        
        
        //        RCDUserInfo *friendInfo = [[RCDataBaseManager shareInstance] getFriendInfo:self.targetId];
        //        if (![friendInfo.status isEqualToString:@"20"]) {
        //            RCDAddFriendViewController *vc = [[RCDAddFriendViewController alloc] init];
        //            vc.targetUserInfo = friendInfo;
        //            [self.navigationController pushViewController:vc animated:YES];
        //        } else {
        //            RCDPrivateSettingsTableViewController *settingsVC =
        //            [RCDPrivateSettingsTableViewController privateSettingsTableViewController];
        //            settingsVC.userId = self.targetId;
        //            [self.navigationController pushViewController:settingsVC animated:YES];
        //        }
        
    } else if (self.conversationType == ConversationType_DISCUSSION) {
        //        RCDDiscussGroupSettingViewController *settingVC = [[RCDDiscussGroupSettingViewController alloc] init];
        //        settingVC.conversationType = self.conversationType;
        //        settingVC.targetId = self.targetId;
        //        settingVC.conversationTitle = self.userName;
        //        //设置讨论组标题时，改变当前会话页面的标题
        //        settingVC.setDiscussTitleCompletion = ^(NSString *discussTitle) {
        //            self.title = discussTitle;
        //        };
        //        //清除聊天记录之后reload data
        //        __weak RCDChatViewController *weakSelf = self;
        //        settingVC.clearHistoryCompletion = ^(BOOL isSuccess) {
        //            if (isSuccess) {
        //                [weakSelf.conversationDataRepository removeAllObjects];
        //                dispatch_async(dispatch_get_main_queue(), ^{
        //                    [weakSelf.conversationMessageCollectionView reloadData];
        //                });
        //            }
        //        };
        //
        //        [self.navigationController pushViewController:settingVC animated:YES];
    }
    
    //群组设置
    else if (self.conversationType == ConversationType_GROUP) {
        
        // 在群组详情界面可能会受到群组解散的消息
        CHMGroupModel *groupModel = [[CHMDataBaseManager shareManager] getGroupByGroupId:self.targetId];
        if (!groupModel) {
            [CHMProgressHUD showErrorWithInfo:@"你不在该群组或群组已解散"];
            return;
        }
        
        CHMGroupSettingController *settingVC = [CHMGroupSettingController new];
        settingVC.groupId = self.targetId;
        [self.navigationController pushViewController:settingVC animated:YES];
        
        //        RCDGroupSettingsTableViewController *settingsVC =
        //        [RCDGroupSettingsTableViewController groupSettingsTableViewController];
        //        if (_groupInfo == nil) {
        //            settingsVC.Group = [[RCDataBaseManager shareInstance] getGroupByGroupId:self.targetId];
        //        } else {
        //            settingsVC.Group = _groupInfo;
        //        }
        //        [self.navigationController pushViewController:settingsVC animated:YES];
    }
    
    //客服设置
    else if (self.conversationType == ConversationType_CUSTOMERSERVICE ||
             self.conversationType == ConversationType_SYSTEM) {
        //        RCDSettingBaseViewController *settingVC = [[RCDSettingBaseViewController alloc] init];
        //        settingVC.conversationType = self.conversationType;
        //        settingVC.targetId = self.targetId;
        //        //清除聊天记录之后reload data
        //        __weak RCDChatViewController *weakSelf = self;
        //        settingVC.clearHistoryCompletion = ^(BOOL isSuccess) {
        //            if (isSuccess) {
        //                [weakSelf.conversationDataRepository removeAllObjects];
        //                dispatch_async(dispatch_get_main_queue(), ^{
        //                    [weakSelf.conversationMessageCollectionView reloadData];
        //                });
        //            }
        //        };
        //        [self.navigationController pushViewController:settingVC animated:YES];
    } else if (ConversationType_APPSERVICE == self.conversationType ||
               ConversationType_PUBLICSERVICE == self.conversationType) {
        RCPublicServiceProfile *serviceProfile =
        [[RCIMClient sharedRCIMClient] getPublicServiceProfile:(RCPublicServiceType)self.conversationType
                                               publicServiceId:self.targetId];
        
        RCPublicServiceProfileViewController *infoVC = [[RCPublicServiceProfileViewController alloc] init];
        infoVC.serviceProfile = serviceProfile;
        infoVC.fromConversation = YES;
        [self.navigationController pushViewController:infoVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
