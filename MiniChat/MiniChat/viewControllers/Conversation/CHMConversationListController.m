//
//  CHMConversationController.m
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMConversationListController.h"
#import "CHMConversationController.h"
#import "CHMBarButtonItem.h"
#import "KxMenu.h"
#import "CHMSelectMemberController.h"
#import "CHMSearchFriendController.h"
#import "RCDChatListCell.h"
#import "RCDAddressBookViewController.h"


@interface CHMConversationListController ()

@end

@implementation CHMConversationListController

#pragma mark - view life cycler
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    RCUserInfo *groupNotify = [[RCUserInfo alloc] initWithUserId:@"__system__" name:@"" portrait:nil];
    [[RCIM sharedRCIM] refreshUserInfoCache:groupNotify withUserId:@"__system__"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
    
    // 设置在NavigatorBar中显示连接中的提示
    self.showConnectingStatusOnNavigatorBar = YES;
    
    // 设置需要显示那些类型的会话
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),
                                        @(ConversationType_DISCUSSION),
                                        @(ConversationType_CHATROOM),
                                        @(ConversationType_GROUP),
                                        @(ConversationType_APPSERVICE),
                                        @(ConversationType_SYSTEM)]];
    
    //聚合会话类型
    [self setCollectionConversationType:@[ @(ConversationType_SYSTEM) ]];
    
    
    
    // 网络不可用的时候，显示网络不可用
    self.isShowNetworkIndicatorView = YES;
}

/**
 设置外观
 */
- (void)setupAppearance {
    
    CGRect oldFrame = self.emptyConversationView.frame;
    oldFrame.origin.y = (self.view.bounds.size.height) / 2.0  - (oldFrame.size.height);
    self.emptyConversationView.frame = oldFrame;
    
    
    self.conversationListTableView.tableFooterView= [UIView new];
    
    // navigationBar right item
    CHMBarButtonItem *rightBtn = [[CHMBarButtonItem alloc] initContainImage:[UIImage imageNamed:@"add"]
                                                             imageViewFrame:CGRectMake(0, 0, 17, 17)
                                                                buttonTitle:nil
                                                                 titleColor:nil
                                                                 titleFrame:CGRectZero
                                                                buttonFrame:CGRectMake(0, 0, 44, 44)
                                                                     target:self
                                                                     action:@selector(showMenu:)];
    self.navigationItem.rightBarButtonItems = @[rightBtn];
}


/**
 右上角的弹出框
 
 @param sender 目标按钮，即右上角加号
 */
- (void)showMenu:(UIButton *)sender {
    NSArray *menuItems = @[
                           
                           [KxMenuItem menuItem:@"发起聊天"
                                          image:[UIImage imageNamed:@"startchat_icon"]
                                         target:self
                                         action:@selector(pushChat:)],
                           
                           [KxMenuItem menuItem:@"创建群组"
                                          image:[UIImage imageNamed:@"creategroup_icon"]
                                         target:self
                                         action:@selector(pushContactSelected:)],
                           
                           [KxMenuItem menuItem:@"添加好友"
                                          image:[UIImage imageNamed:@"addfriend_icon"]
                                         target:self
                                         action:@selector(pushAddFriend:)]
                           ];
    
    UIBarButtonItem *rightBarButton = self.navigationItem.rightBarButtonItems[0];
    CGRect targetFrame = rightBarButton.customView.frame;
    CGFloat offset = [UIApplication sharedApplication].statusBarFrame.size.height > 20 ?  24 : 0;
    targetFrame.origin.y = targetFrame.origin.y + offset;
    if (IOS_FSystenVersion >= 11.0) {
        targetFrame.origin.x = self.view.bounds.size.width - targetFrame.size.width - 17;
    }
    [KxMenu setTintColor:[UIColor chm_colorWithHexString:@"#000000" alpha:1.0]];
    [KxMenu setTitleFont:[UIFont systemFontOfSize:17]];
    [KxMenu showMenuInView:self.navigationController.navigationBar.superview
                  fromRect:targetFrame
                 menuItems:menuItems];
}

/**
 *  发起聊天
 *
 *  @param sender sender description
 */
- (void)pushChat:(id)sender {
    [self.tabBarController setSelectedIndex:1];
}

/**
 *  创建群组
 *
 *  @param sender sender description
 */
- (void)pushContactSelected:(id)sender {
    CHMSelectMemberController *selectMemberController = [CHMSelectMemberController new];
    selectMemberController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:selectMemberController animated:YES];
}

/**
 *  添加好友
 *
 *  @param sender sender description
 */
- (void)pushAddFriend:(id)sender {
    [self.navigationController pushViewController:[CHMSearchFriendController new] animated:YES];
}



// 点击cell，进入聊天界面
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath {
    
    //    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
    CHMConversationController *_conversationVC = [[CHMConversationController alloc] init];
    _conversationVC.conversationType = model.conversationType;
    _conversationVC.targetId = model.targetId;
    _conversationVC.title = model.conversationTitle;
    _conversationVC.unReadMessage = model.unreadMessageCount;
    _conversationVC.enableNewComingMessageIcon = YES; //开启消息提醒
    _conversationVC.enableUnreadMessageIcon = YES;
    
    if (model.conversationType == ConversationType_SYSTEM) {
        _conversationVC.title = @"系统消息";
    }
    if ([model.objectName isEqualToString:@"RC:ContactNtf"]) {
        RCDAddressBookViewController *addressBookVC = [RCDAddressBookViewController addressBookViewController];
        addressBookVC.needSyncFriendList = YES;
        
        [self.navigationController pushViewController:addressBookVC animated:YES];
        return;
    }
    
    
    
    // 从会话列表中拿出会话模型
    RCConversation *conversation =  self.conversationListDataSource[indexPath.row];
    
    //新建一个聊天会话View Controller对象,建议这样初始化
    CHMConversationController *chatController = [[CHMConversationController alloc] initWithConversationType:conversation.conversationType
                                                                                                   targetId:conversation.targetId];
    [chatController setHidesBottomBarWhenPushed:YES];
    
    //设置会话的类型，如单聊、讨论组、群聊、聊天室、客服、公众服务会话等
    chatController.conversationType = conversation.conversationType;
    //设置会话的目标会话ID。（单聊、客服、公众服务会话为对方的ID，讨论组、群聊、聊天室为会话的ID）
    chatController.targetId = conversation.targetId;
    
    //设置聊天会话界面要显示的标题
    chatController.title =[conversation.conversationTitle isEqualToString:@""] ? conversation.targetId : conversation.conversationTitle;
    //显示聊天会话界面
    [self.navigationController pushViewController:chatController animated:YES];
    //    }
}

#pragma mark - 自定义cell
//自定义cell
- (RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView
                                  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    
    __block NSString *userName = nil;
    __block NSString *portraitUri = nil;
    RCContactNotificationMessage *_contactNotificationMsg = nil;
    
    __weak typeof(self) weakSelf = self;
    //此处需要添加根据userid来获取用户信息的逻辑，extend字段不存在于DB中，当数据来自db时没有extend字段内容，只有userid
    if (nil == model.extend) {
        // Not finished yet, To Be Continue...
        if (model.conversationType == ConversationType_SYSTEM &&
            [model.lastestMessage isMemberOfClass:[RCContactNotificationMessage class]]) {
            _contactNotificationMsg = (RCContactNotificationMessage *)model.lastestMessage;
            if (_contactNotificationMsg.sourceUserId == nil) {
                RCDChatListCell *cell =
                [[RCDChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
                cell.lblDetail.text = @"好友请求";
                [cell.ivAva chm_imageViewWithURL:portraitUri placeholder:@"system_notice"];
                return cell;
            }
            NSDictionary *_cache_userinfo =
            [[NSUserDefaults standardUserDefaults] objectForKey:_contactNotificationMsg.sourceUserId];
            if (_cache_userinfo) {
                userName = _cache_userinfo[@"username"];
                portraitUri = _cache_userinfo[@"portraitUri"];
            } else {
                NSDictionary *emptyDic = @{};
                [[NSUserDefaults standardUserDefaults] setObject:emptyDic forKey:_contactNotificationMsg.sourceUserId];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [CHMHttpTool searchUserInfoWithUserId:_contactNotificationMsg.sourceUserId success:^(id response) {
                    NSNumber *codeId = response[@"Code"][@"CodeId"];
                    if (codeId.integerValue == 100) {
                        
                        NSString *userName = response[@"Value"][@"UserName"];
                        NSString *nickName = response[@"Value"][@"NickName"];
                        NSString *headimg = response[@"Value"][@"Headimg"];
                        
                        
                        nickName = ([nickName isKindOfClass:[NSNull class]] ? userName : nickName);
                        headimg = ([headimg isKindOfClass:[NSNull class] ] ? @"icon_person" : headimg);
                        
                        RCUserInfo *rcduserinfo_ = [RCUserInfo new];
                        rcduserinfo_.name = nickName;
                        rcduserinfo_.userId = userName;
                        rcduserinfo_.portraitUri = headimg;
                        
                        model.extend = rcduserinfo_;
                        
                        // local cache for userInfo
                        NSDictionary *userinfoDic =
                        @{@"username" : rcduserinfo_.name, @"portraitUri" : rcduserinfo_.portraitUri};
                        [[NSUserDefaults standardUserDefaults] setObject:userinfoDic
                                                                  forKey:_contactNotificationMsg.sourceUserId];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [weakSelf.conversationListTableView
                         reloadRowsAtIndexPaths:@[ indexPath ]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                } failure:^(NSError *error) {
                    
                }];
            }
        }
        
    } else {
        RCUserInfo *user = (RCUserInfo *)model.extend;
        userName = user.name;
        portraitUri = user.portraitUri;
    }
    
    RCDChatListCell *cell = [[RCDChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    NSString *operation = _contactNotificationMsg.operation;
    NSString *operationContent;
    if ([operation isEqualToString:@"Request"]) {
        operationContent = [NSString stringWithFormat:@"来自%@的好友请求", userName];
    } else if ([operation isEqualToString:@"AcceptResponse"]) {
        operationContent = [NSString stringWithFormat:@"%@通过了你的好友请求", userName];
    }
    cell.lblDetail.text = operationContent;
    [cell.ivAva chm_imageViewWithURL:portraitUri placeholder:@"system_notice"];
    cell.labelTime.text = [RCKitUtility ConvertMessageTime:model.sentTime / 1000];
    cell.model = model;
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
