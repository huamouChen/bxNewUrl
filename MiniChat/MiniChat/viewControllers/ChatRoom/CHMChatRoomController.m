//
//  CHMChatRoomController.m
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMChatRoomController.h"
#import "CHMChatRoomCell.h"
#import "CHMChatRoomModel.h"
#import "CHMConversationController.h"

static NSString *const chatRoomReuseableId = @"CHMChatRoomCell";

static int const KSectionViewHeight = 35;

static NSString *const sectionViewBackgroundColor = @"0xf0f0f6";

@interface CHMChatRoomController ()
@property (nonatomic, strong) NSMutableArray *chatroomLists;
@end

@implementation CHMChatRoomController

#pragma mark - view life cycler
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
    
    // 从服务器获取聊天室列表
    [self fetchChatroomList];
}


/**
 从服务器获取聊天室列表
 */
- (void)fetchChatroomList {
    __weak typeof(self) weakSelf = self;
    [CHMHttpTool getChatRoomListsWithSuccess:^(id response) {
        NSLog(@"---------%@", response);
        NSNumber *codeId = response[@"Code"][@"CodeId"];
        if (codeId.integerValue == 100) { // 成功
            weakSelf.chatroomLists = [CHMChatRoomModel mj_objectArrayWithKeyValuesArray:response[@"Value"]];
            [weakSelf.tableView reloadData];
        } else { // 失败
            [CHMProgressHUD showErrorWithInfo:response[@"Code"][@"Description"]];
        }
    } failure:^(NSError *error) {
        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"错误码--%zd", error.code]];
    }];
}


/**
 设置控件样式
 */
- (void)setupAppearance {
    
    self.tableView.backgroundColor = [UIColor chm_colorWithHexString:sectionViewBackgroundColor alpha:1.0];
    
    self.tableView.tableFooterView = [UIView new];
    
    // register cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CHMChatRoomCell class]) bundle:nil] forCellReuseIdentifier:chatRoomReuseableId];
    
    // table view section height
    self.tableView.sectionHeaderHeight = KSectionViewHeight;
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatroomLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHMChatRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:chatRoomReuseableId];
    cell.chatRoomModel = self.chatroomLists[indexPath.row];
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 开启聊天室会话
    CHMChatRoomModel *chatroom = _chatroomLists[indexPath.row];
    CHMConversationController *conversationVC = [[CHMConversationController alloc]init];
    conversationVC.conversationType = ConversationType_CHATROOM;
    conversationVC.targetId = chatroom.GroupId;
    conversationVC.title = chatroom.GroupName;
    conversationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:conversationVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *contengView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, KSectionViewHeight)];
    contengView.backgroundColor = [UIColor chm_colorWithHexString:sectionViewBackgroundColor alpha:1.0];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, KSectionViewHeight)];
    titleLabel.text = @"聊天室";
    titleLabel.textColor = [UIColor chm_colorWithHexString:@"0x333333" alpha:1.0];
    [contengView addSubview:titleLabel];
    return contengView;
}


#pragma mark - lazy loaded
- (NSMutableArray *)chatroomLists {
    if (!_chatroomLists) {
        _chatroomLists = [NSMutableArray array];
    }
    return _chatroomLists;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
