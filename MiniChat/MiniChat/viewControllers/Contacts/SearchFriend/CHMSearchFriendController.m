//
//  CHMSearchFriendController.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/7.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMSearchFriendController.h"
#import "CHMMineDetailCell.h"
#import "CHMFriendModel.h"
#import "CHMUserDetailController.h"

static NSString *const cellReuseId = @"CHMMineDetailCell";

@interface CHMSearchFriendController () <UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSMutableArray *searchResult;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation CHMSearchFriendController


#pragma mark - 查询用户信息
- (void)searchUserInfoWithUserId:(NSString *)userId {
    __weak typeof(self) weakSelf = self;
    [CHMProgressHUD showWithInfo:@"正在搜索..." isHaveMask:YES];
    [CHMHttpTool searchUserInfoWithUserId:userId success:^(id response) {
        NSLog(@"-----------%@",response);
        NSNumber *codeId = response[@"Code"][@"CodeId"];
        if (codeId.integerValue == 100) {
            NSNumber *isExist = response[@"Value"][@"Exist"];
            if (isExist.integerValue == 0) { // 不存在此用户
                [CHMProgressHUD showErrorWithInfo:@"不存在此用户"];
                // 清空旧的数据
                [weakSelf.searchResult removeAllObjects];
                [weakSelf.tableView reloadData];
            }
            if (isExist.integerValue == 1) {
                // 清空旧的数据
                [weakSelf.searchResult removeAllObjects];
                [CHMProgressHUD dismissHUD];
                NSString *userName = response[@"Value"][@"UserName"];
                NSString *nickName = response[@"Value"][@"NickName"];
                NSString *headimg = response[@"Value"][@"Headimg"];
                NSNumber *relationCode = response[@"Value"][@"Relation"];
                
                nickName = [nickName isKindOfClass:[NSNull class]] || nickName == nil || [nickName isEqualToString:@""]  ? userName : nickName;
                headimg = ([headimg isKindOfClass:[NSNull class] ] || headimg == nil || [headimg isEqualToString:@""]  ? KDefaultPortrait : headimg);
                CHMFriendModel *friendModel = [[CHMFriendModel alloc] initWithUserId:userName nickName:nickName portrait:headimg];
                // 用来标记是否是好友
                friendModel.isCheck = relationCode.integerValue == 1 ? YES : NO;
                [weakSelf.searchResult addObject:friendModel];
                [weakSelf.tableView reloadData];
            }
            
        } else {
            [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"%@", response[@"Code"][@"Description"]]];
        }
    } failure:^(NSError *error) {
        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"%ld", (long)error.code]];
    }];
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchUserInfoWithUserId:searchBar.text];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppeanrance];
}

/**
 设置外观
 */
- (void)setupAppeanrance {
    self.title = @"添加好友";
    
    self.searchResult = [NSMutableArray array];
    
    // register cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CHMMineDetailCell class]) bundle:nil] forCellReuseIdentifier:cellReuseId];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 取出模型
    CHMFriendModel *friendModel =_searchResult[indexPath.row];
    // 跳到用户详情页面
    CHMUserDetailController *userDetailVC = [CHMUserDetailController new];
    userDetailVC.isFriend = friendModel.isCheck;
    userDetailVC.friendModel = friendModel;
    if (self.searchController.isActive) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.navigationController pushViewController:userDetailVC animated:YES];
        }];
    } else {
        [self.navigationController pushViewController:userDetailVC animated:YES];
    }
    
    
}

#pragma mark - table view data soure
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHMMineDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseId];
    cell.friendModel = _searchResult[indexPath.row];
    return cell;
}

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
