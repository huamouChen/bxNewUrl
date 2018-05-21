//
//  CHMGroupListController.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/5.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMGroupListController.h"
#import "CHMContactCell.h"
#import "CHMGroupModel.h"
#import "CHMConversationController.h"
#import "CHMGroupFooter.h"

static NSString *const groupCellReuseId = @"CHMContactCell";

@interface CHMGroupListController ()
// 群聊列表数组
@property (nonatomic, strong) NSMutableArray *groupArray;

@property (nonatomic, strong) CHMGroupFooter *footer;
@end

@implementation CHMGroupListController

#pragma mark - 获取数据
/**
 获取群组列表
 */
- (void)fetchGroupList {
    NSMutableArray *groupList = [[CHMDataBaseManager shareManager] getAllGroup];
    if (groupList.count > 0) {
        self.groupArray = [NSMutableArray arrayWithArray:groupList];
        // 刷新数据
        self.footer.footerTitleLabel.text = [NSString stringWithFormat:@"%ld个群聊",(long)self.groupArray.count];
        [self.tableView reloadData];
        return;
    }
    
    [CHMHttpTool getGroupListWithSuccess:^(id response) {
        NSLog(@"------------%@", response);
        __weak typeof(self) weakSelf = self;
        NSNumber *codeId = response[@"Code"][@"CodeId"];
        if (codeId.integerValue == 100) {
            NSArray *groupList = [CHMGroupModel mj_objectArrayWithKeyValuesArray:response[@"Value"]];
            weakSelf.groupArray = [NSMutableArray arrayWithArray:groupList];
            // 刷新数据
            weakSelf.footer.footerTitleLabel.text = [NSString stringWithFormat:@"%ld个群聊",(long)weakSelf.groupArray.count];
            [weakSelf.tableView reloadData];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"-------%zd", error.code);
    }];
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CHMGroupModel *groupModel = _groupArray[indexPath.row];
    //新建一个聊天会话View Controller对象,建议这样初始化
    CHMConversationController *chatController = [[CHMConversationController alloc] initWithConversationType:ConversationType_GROUP targetId:groupModel.GroupId];
    //设置聊天会话界面要显示的标题
    chatController.title = groupModel.GroupName;
    [chatController setHidesBottomBarWhenPushed:YES];
    //显示聊天会话界面
    [self.navigationController pushViewController:chatController animated:YES];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _groupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:groupCellReuseId];
    cell.groupModel = _groupArray[indexPath.row];
    return cell;
}

#pragma mark - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置外观
    [self setupAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchData];
}


/**
 获取数据
 */
- (void)fetchData {
    [self fetchGroupList];
}

/**
 设置外观
 */
- (void)setupAppearance {
    self.title = @"群聊";
    // register cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CHMContactCell class]) bundle:nil] forCellReuseIdentifier:groupCellReuseId];
    // table footer
    CHMGroupFooter *footer = [CHMGroupFooter footerWithTableView:self.tableView];
    self.tableView.tableFooterView = footer;
    self.footer = footer;
}

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
