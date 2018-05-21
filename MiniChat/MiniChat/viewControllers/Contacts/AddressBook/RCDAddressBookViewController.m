//
//  RCDAddressBookViewController.m
//  RongCloud
//
//  Created by Liv on 14/11/11.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDAddressBookViewController.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDNoFriendView.h"
#import "CHMDataBaseManager.h"
#import "CHMConversationController.h"
#import "CHMNewFriendCell.h"
#import "CHMFriendModel.h"

static NSString *const reuseId = @"CHMNewFriendCell";

static CGFloat const rowHeight = 65;

@interface RCDAddressBookViewController ()

//#字符索引对应的user object
@property(nonatomic, strong) NSMutableArray *tempOtherArr;
@property(nonatomic, strong) NSMutableArray *friends;
@property(nonatomic, strong) NSMutableDictionary *friendsDic;
@property(nonatomic, strong) RCDNoFriendView *noFriendView;

// 申请好友的消息数组
@property (nonatomic, strong) NSArray *applyArray;

// 当前点击的接受按钮下标
@property (nonatomic, assign) NSInteger currentIndex;


@end

@implementation RCDAddressBookViewController {
    NSInteger tag;
    BOOL isSyncFriends;
}

+ (instancetype)addressBookViewController {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"新的朋友";
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = rowHeight;
    
    _friendsDic = [[NSMutableDictionary alloc] init];
    
    tag = 0;
    isSyncFriends = NO;
    
    // register cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CHMNewFriendCell class]) bundle:nil] forCellReuseIdentifier:reuseId];
    
    self.tableView.rowHeight = rowHeight;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.currentIndex = -1;
    self.needSyncFriendList = YES;
    
    // IMLib 库获取会话列表
    NSArray *conversationList = [[RCIMClient sharedRCIMClient]
                                 getConversationList:@[
                                                       @(ConversationType_SYSTEM),
                                                       ]];
    
    self.applyArray = conversationList;
    
    if (_applyArray.count > 0) {
        self.hideSectionHeader = YES;
        self.friends = [self sortForFreindList:_friends];
        tag = 0;
        [self.tableView reloadData];
    } else {
        CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
        self.noFriendView = [[RCDNoFriendView alloc] initWithFrame:frame];
        self.noFriendView.displayLabel.text = @"暂无数据";
        [self.view addSubview:self.noFriendView];
        [self.view bringSubviewToFront:self.noFriendView];
    }
    
    for (RCConversation *conversation in conversationList) {
        NSLog(@"会话类型：%lu，目标会话ID：%@", (unsigned long)conversation.conversationType, conversation.targetId);
        
    }
    
    [self getAllData];
}

//删除已选中用户
- (void)removeSelectedUsers:(NSArray *)selectedUsers {
    for (RCUserInfo *user in selectedUsers) {
        __weak typeof(self) weakSelf = self;
        [_friends enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            RCUserInfo *userInfo = obj;
            if ([user.userId isEqualToString:userInfo.userId]) {
                [weakSelf.friends removeObject:obj];
            }
        }];
    }
}

/**
 *  initial data
 */
- (void)getAllData {
//    __weak typeof(self) weakSelf = self;
//    self.friends = [NSMutableArray arrayWithArray:[[CHMDataBaseManager shareManager] getAllFriends]];
//    if (_friends.count > 0) {
//        self.hideSectionHeader = YES;
//        weakSelf.friends = [self sortForFreindList:_friends];
//        tag = 0;
//        [weakSelf.tableView reloadData];
//    } else {
//        CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
//        self.noFriendView = [[RCDNoFriendView alloc] initWithFrame:frame];
//        self.noFriendView.displayLabel.text = @"暂无数据";
//        [self.view addSubview:self.noFriendView];
//        [self.view bringSubviewToFront:self.noFriendView];
//    }
//    if (isSyncFriends == NO) {
//        [[CHMInfoProvider shareInstance] syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId complete:^(NSMutableArray *friends) {
//            self->isSyncFriends = YES;
//            if (friends.count > 0 ) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (weakSelf.noFriendView != nil) {
//                        [weakSelf.noFriendView removeFromSuperview];
//                    }
//                });
//
//                [self getAllData];
//            }
//        }];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _applyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCConversation *conversation = _applyArray[indexPath.row];
    
    CHMNewFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    cell.indexPath = indexPath;
    // 是否是好友
    RCUserInfo *userInfo = [[CHMDataBaseManager shareManager] getFriendInfo:conversation.targetId];
    CHMFriendModel *friendModel = nil;
    if (userInfo) {
        friendModel = [[CHMFriendModel alloc] initWithUserId:userInfo.userId nickName:userInfo.name portrait:userInfo.portraitUri];
    } else {
        friendModel = [[CHMFriendModel alloc] initWithUserId:conversation.targetId nickName:conversation.targetId portrait:KDefaultPortrait];
    }
    // row 判断主要是为了防止数据刷新不及时
    friendModel.isCheck = (userInfo || self.currentIndex == indexPath.row) ? NO : YES;
    cell.friendModel = friendModel;
    cell.acceptButtonClickBlock = ^(NSIndexPath *selectedIndexPath) {
        [self acceptButtonClickWithIndexPath:selectedIndexPath];
    };
    // 设置选中效果为无
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - 点击接受按钮
/**
 点击接受按钮
 */
- (void)acceptButtonClickWithIndexPath:(NSIndexPath *)indexPath {
    
    [CHMProgressHUD showWithInfo:@"正在同意好友申请..." isHaveMask:YES];
    
    RCConversation *conversation = _applyArray[indexPath.row];
    
    RCContactNotificationMessage *contactMessage = nil;
    NSString *applyId = @"";
    if ([conversation.lastestMessage isKindOfClass:[RCContactNotificationMessage class]]) {
        contactMessage = (RCContactNotificationMessage *)conversation.lastestMessage;
    }
    
    if (contactMessage != nil) {
        NSString *extraString = contactMessage.extra;
        NSData *jsonData = [extraString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        if (dict) {
            applyId = [NSString stringWithFormat:@"%@", dict[@"ApplyId"]];
        }
    }
    __weak typeof(self) weakSelf = self;
    [CHMHttpTool agreeFriendWithApplyId:applyId success:^(id response) {
        NSLog(@"agreeFriendWithApplyId----------%@", response);
        NSNumber *codeId = response[@"Code"][@"CodeId"];
        if (codeId.integerValue == 100) {
            weakSelf.currentIndex = indexPath.row;
            // 就刷新好友列表数据
            NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:KAccount];
            [[CHMInfoProvider shareInstance] syncFriendList:account complete:^(NSMutableArray *friends) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KChangeUserInfoNotification object:nil];
            }];
            [weakSelf.tableView reloadData];
            [CHMProgressHUD showSuccessWithInfo:@"已经接受好友请求"];
            
        } else {
            [CHMProgressHUD showErrorWithInfo:response[@"Code"][@"Description"]];
        }
    } failure:^(NSError *error) {
        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"错误码--%zd", error.code]];
    }];
}


/**
 接受了好友之后，进入聊天界面
 */
- (void)startChat {
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    RCUserInfo *user = _friends[indexPath.row];
//    RCUserInfo *friend = [[CHMDataBaseManager shareManager] getFriendInfo:user.userId];
//    if (!friend) {
//        return;
//    }
//    RCUserInfo *userInfo = [RCUserInfo new];
//    userInfo.userId = friend.userId;
//    userInfo.portraitUri = friend.portraitUri;
//    userInfo.name = friend.name;
//
//    CHMConversationController *chatViewController = [[CHMConversationController alloc] init];
//    chatViewController.conversationType = ConversationType_PRIVATE;
//    chatViewController.targetId = userInfo.userId;
//    chatViewController.title = userInfo.name;
//    chatViewController.displayUserNameInCell = NO;
//    //        chatViewController.needPopToRootView = YES;
//    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (NSMutableArray *)sortForFreindList:(NSMutableArray *)friendList {
    NSMutableDictionary *tempFrinedsDic = [NSMutableDictionary new];
    NSMutableArray *updatedAtList = [NSMutableArray new];
    //    for (RCUserInfo *friend in _friends) {
    //        NSString *key = friend.updatedAt;
    //        if (key == nil) {
    //            NSLog([NSString stringWithFormat:@"%@'s updatedAt is nil", friend.userId], nil);
    //            return nil;
    //        } else {
    //            [tempFrinedsDic setObject:friend forKey:key];
    //            [updatedAtList addObject:key];
    //        }
    //    }
    updatedAtList = [self sortForUpdateAt:updatedAtList];
    NSMutableArray *result = [NSMutableArray new];
    for (NSString *key in updatedAtList) {
        for (NSString *k in [tempFrinedsDic allKeys]) {
            if ([key isEqualToString:k]) {
                [result addObject:[tempFrinedsDic objectForKey:k]];
            }
        }
    }
    return result;
}

- (NSMutableArray *)sortForUpdateAt:(NSMutableArray *)updatedAtList {
    NSMutableArray *sortedList = [NSMutableArray new];
    NSMutableDictionary *tempDic = [NSMutableDictionary new];
    for (NSString *updateAt in updatedAtList) {
        NSString *str1 = [updateAt stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        NSString *str2 = [str1 stringByReplacingOccurrencesOfString:@"T" withString:@"/"];
        NSString *str3 = [str2 stringByReplacingOccurrencesOfString:@":" withString:@"/"];
        NSMutableString *str = [[NSMutableString alloc] initWithString:str3];
        NSString *point = @".";
        if ([str rangeOfString:point].location != NSNotFound) {
            NSRange rang = [updateAt rangeOfString:point];
            [str deleteCharactersInRange:NSMakeRange(rang.location, str.length - rang.location)];
            [sortedList addObject:str];
            [tempDic setObject:updateAt forKey:str];
        }
    }
    sortedList = (NSMutableArray *)[sortedList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd/hh/mm/ss"];
        if (obj1 == [NSNull null]) {
            obj1 = @"0000/00/00/00/00/00";
        }
        if (obj2 == [NSNull null]) {
            obj2 = @"0000/00/00/00/00/00";
        }
        NSDate *date1 = [formatter dateFromString:obj1];
        NSDate *date2 = [formatter dateFromString:obj2];
        NSComparisonResult result = [date1 compare:date2];
        return result == NSOrderedAscending;
    }];
    NSMutableArray *result = [NSMutableArray new];
    for (NSString *key in sortedList) {
        for (NSString *k in [tempDic allKeys]) {
            if ([key isEqualToString:k]) {
                [result addObject:[tempDic objectForKey:k]];
            }
        }
    }
    
    return result;
}

@end
