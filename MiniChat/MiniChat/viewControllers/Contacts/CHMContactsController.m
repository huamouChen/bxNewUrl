//
//  CHMContactsController.m
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMContactsController.h"
#import "CHMContactCell.h"
#import "CHMFriendModel.h"
#import "CHMSectionHeaderView.h"
#import "CHMUserDetailController.h"
#import "CHMContactHeaderView.h"
#import "CHMNewFriendsController.h"
#import "CHMGroupListController.h"
#import "RCDAddressBookViewController.h"
#import "KxMenu.h"
#import "CHMSelectMemberController.h"
#import "CHMSearchFriendController.h"

static NSString *const contactReuseId = @"CHMContactCell";
static int const rowHeight = 55;
static int const sectionHeaderHeight = 28;
static CGFloat const KIndexViewWidth = 55 / 2.0;



@interface CHMContactsController () <UITableViewDataSource, UITableViewDelegate>
/**
 数据数组
 */
@property (strong, nonatomic) NSMutableArray *dataArr;

/**
 tableView
 */
@property (strong, nonatomic) UITableView *tableView;

/**
 索引数组
 */
@property (strong, nonatomic) NSMutableArray *indexArr;

/**
 右边索引条容器视图
 */
@property (strong, nonatomic) UIView *indexContentView;

/**
 中间indexLabel
 */
@property (strong, nonatomic) UILabel *indexLabelCenter;

@end

@implementation CHMContactsController

#pragma mark - 获取数据
/**
 获取好友列表
 */
- (void)fetchFriendList {

    NSMutableArray *friendList = [NSMutableArray arrayWithArray:[[CHMDataBaseManager shareManager] getAllFriends]];
    if (friendList.count > 0) {
        // 分组排序
        [self.dataArr removeAllObjects];
        [self.dataArr addObject:[self addTopFriend]];
        [self.dataArr addObjectsFromArray:[self testSortWithArray:friendList]];
        [self.tableView reloadData];
        
    } else {
        __weak typeof(self) weakSelf = self;
        [CHMHttpTool getUserRelationShipListWithSuccess:^(id response) {
            NSLog(@"------------%@", response);
            NSNumber *codeId = response[@"Code"][@"CodeId"];
            if (codeId.integerValue == 100) {
                // 清空旧数据
//                [weakSelf.dataArr removeAllObjects];
//                [weakSelf.dataArr addObject:[weakSelf addTopFriend]];
                NSMutableArray *friendsArray = [CHMFriendModel mj_objectArrayWithKeyValuesArray:response[@"Value"]];
                // 处理没有昵称的问题
                NSMutableArray *filterArray = [self dealWithNickNameWithArray:friendsArray];
                // 把当前用户也作为一个好友添加进去
                // 从沙盒中取登录时保存的用户信息
                NSString *nickName = [[NSUserDefaults standardUserDefaults] valueForKey:KNickName];
                NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:KAccount];
                NSString *portrait = [[NSUserDefaults standardUserDefaults] valueForKey:KPortrait];
                CHMFriendModel *currentuser = [[CHMFriendModel alloc] initWithUserId:account nickName:nickName portrait:portrait];
                [filterArray addObject:currentuser];
                
                // 把数据保存到本地数据库
                NSMutableArray *resultArray = [NSMutableArray array];
                for (int i = 0; i < filterArray.count; i++) {
                    CHMFriendModel *friednModel = filterArray[i];
                    RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:friednModel.UserName name:friednModel.NickName portrait:friednModel.HeaderImage];
                    [resultArray addObject:userInfo];
                }
                
                // 用户信息表
                [[CHMDataBaseManager shareManager] insertUserListToDB:resultArray complete:^(BOOL isCompleted) { }];
                // 好友列表
                [[CHMDataBaseManager shareManager] insertFriendListToDB:resultArray complete:^(BOOL isCompleted) { }];
                
                
                // 分组排序
                [weakSelf.dataArr addObjectsFromArray:[weakSelf testSortWithArray:filterArray]];
                [weakSelf.tableView reloadData];
            } else {
                // 失败暂时不提醒
            }
        } failure:^(NSError *error) {
            [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"错误码--%ld", (long)error.code]];
        }];
    }
    
    
    
}


/**
 处理头像 或者昵称为空
 */
- (NSMutableArray *)dealWithNickNameWithArray:(NSArray *)array {
    NSMutableArray *resultArray = [NSMutableArray array];
    for (CHMFriendModel *itemModel in array) {
        if ([itemModel.NickName isKindOfClass:[NSNull class]] || [itemModel.NickName isEqualToString:@""]) {
            itemModel.NickName = itemModel.UserName;
        }
        if ([itemModel.HeaderImage isKindOfClass:[NSNull class]] || [itemModel.HeaderImage isEqualToString:@""]) {
            itemModel.HeaderImage = @"icon_person";
        } else {
            itemModel.HeaderImage = [NSString stringWithFormat:@"%@%@",BaseURL, itemModel.HeaderImage];
        }
        
        [resultArray addObject:itemModel];
    }
    return resultArray;
}

#pragma mark - 排序
- (NSArray *)testSortWithArray:(NSArray *)array {
    // 获取当前位置索引
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    //1.获取获取section标题  ABCD
    NSArray *titleArr = collation.sectionTitles;
    
    //2.构建每个section数组  ABCD对应的下属数组
    NSMutableArray *sectionArr = [NSMutableArray arrayWithCapacity:titleArr.count];
    for (int i = 0; i < titleArr.count; i++) {
        // 即每个分组下的数组
        NSMutableArray *subArr = [NSMutableArray array];
        [sectionArr addObject:subArr];
    }
    
    //3.排序
    //3.1 按照将需要排序的对象放入到对应分区数组 即把首字母相同的放到一个数组中
    for (CHMFriendModel *friendModel in array) {
        NSInteger section = [collation sectionForObject:friendModel collationStringSelector:@selector(NickName)];
        NSMutableArray *subArr = sectionArr[section];
        [subArr addObject:friendModel];
    }
    
    //3.2 分别对分区进行排序  对同一组的再排序 tank taoBao
    for (NSMutableArray *subArr in sectionArr) {
        NSArray *sortArr = [collation sortedArrayFromArray:subArr collationStringSelector:@selector(NickName)];
        [subArr removeAllObjects];
        [subArr addObjectsFromArray:sortArr];
    }
    return [NSArray arrayWithArray:sectionArr];
}

#pragma mark - Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = self.dataArr[section];
    if (sectionArray) {
        return [self.dataArr[section] count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:contactReuseId];
    cell.friendModel = self.dataArr[indexPath.section][indexPath.row];
    return cell;
}

#pragma mark - Table View Delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    if (section > 0 && section < 28) {
        CHMSectionHeaderView *header = [CHMSectionHeaderView headerWithTableView:tableView];
        header.title = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section - 1];
        return header;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    if ([self.dataArr[section] count] > 0) {
        return sectionHeaderHeight;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CHMFriendModel *model = self.dataArr[indexPath.section][indexPath.row];
    // 新的朋友
    if ([model.UserName isEqualToString:KNewFriend]) {
        RCDAddressBookViewController *addressBookVC = [RCDAddressBookViewController addressBookViewController];
        addressBookVC.needSyncFriendList = YES;
        [self.navigationController pushViewController:addressBookVC animated:YES];
        return;
        
//        [self.navigationController pushViewController:[CHMNewFriendsController new] animated:YES];
//        return;
    }
    // 群组列表
    if ([model.UserName isEqualToString:KGroupList]) {
        [self.navigationController pushViewController:[CHMGroupListController new] animated:YES];
        return;
    }
    
    // 好友详情
    CHMUserDetailController *userDetailController = [CHMUserDetailController new];
    userDetailController.friendModel = model;
    userDetailController.isFriend = YES;
    [userDetailController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:userDetailController animated:YES];
}

#pragma mark - section 不停留
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//    }else if (scrollView.contentOffset.y >= sectionHeaderHeight){
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//    }
//}

#pragma mark - view life cycler
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 暂时没做本地保存，所以调用接口刷新数据
    [self fetchFriendList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取本地数据
    [self initLocalData];
    
    // 设置外观
    [self setupAppearance];
}

/**
 设置外观
 */
- (void)setupAppearance {
    // footer view
    self.tableView.tableFooterView = [UIView new];
    // register cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CHMContactCell class]) bundle:nil] forCellReuseIdentifier:contactReuseId];
    // row height
    self.tableView.rowHeight = rowHeight;
    [self.view addSubview:self.tableView];
    
    // 添加索引中心提醒Label
    self.indexLabelCenter.center = self.tableView.center;
    [self.view addSubview:self.indexLabelCenter];
    // 创建索引视图
    [self creatIndexView];
    
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

/**
 初始化本地写死的数据
 */
- (void)initLocalData {
}

#pragma mark - 创建索引条
- (void)creatIndexView {
    // 高度
    CGFloat labelHeight = self.indexContentView.bounds.size.height / self.indexArr.count;
    
    for (int i = 0; i < self.indexArr.count; i++) {
        NSString *str = self.indexArr[i];
        UILabel *indexLabel = [UILabel initWithString:str fontSize:12 textColor:[UIColor chm_colorWithHexString:KColor7 alpha:1.0]];
        indexLabel.textAlignment = NSTextAlignmentCenter;
        // 计算frame
        indexLabel.frame = CGRectMake(0, i * labelHeight, KIndexViewWidth, labelHeight);
        [self.indexContentView addSubview:indexLabel];
    }
    [self.view addSubview:self.indexContentView];
}

#pragma mark - touch方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 没有数据， 防止崩溃
    if (self.dataArr.count <= 0) {
        return;
    }
    [self myTouch:touches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 没有数据， 防止崩溃
    if (self.dataArr.count <= 0) {
        return;
    }
    
    [self myTouch:touches];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 设置透明度为 0
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.75 animations:^{
        weakSelf.indexLabelCenter.alpha = 0;
    }];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - 点击索引视图回调
-(void)myTouch:(NSSet *)touches{
    __weak typeof(self) weakSelf = self;
    //    让中间的索引view出现
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.indexLabelCenter.alpha = 1;
    }];
    //    获取点击的区域
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_indexContentView];
    
    CGFloat navigationBarHeight = KISIphoneX ? KNavigationBar88 : KNavigationBar64;
    CGFloat tabBarHeight = KISIphoneX ? KTouchBarHeight + KTabBar49 : KTabBar49;
    int index = (int)((point.y / (SCREEN_HEIGHT - navigationBarHeight - tabBarHeight)) * self.indexArr.count);
    if (index > 26 || index < 0)return;
    //    给显示的view赋标题
    _indexLabelCenter.text= _indexArr[index];
    //    跳到tableview指定的区
    NSIndexPath *indpath=[NSIndexPath indexPathForRow:0 inSection:index];
    
    // 如果存在元素
    if (self.dataArr) {
        BOOL isHaveElement = [self.dataArr[index] count] > 0;
        if (isHaveElement) {
            [_tableView  scrollToRowAtIndexPath:indpath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
    
}


#pragma mark - setter && getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KNavigationBar64) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (NSArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        // 新的朋友
        CHMFriendModel *newFriendModel = [[CHMFriendModel alloc] initWithUserId:KNewFriend nickName:@"新的朋友" portrait:@"newFriend"];
        // 群聊
        CHMFriendModel *groupFriendModel = [[CHMFriendModel alloc] initWithUserId:KGroupList nickName:@"群聊" portrait:@"defaultGroup"];
        NSArray *headerArray = @[newFriendModel, groupFriendModel];
        [_dataArr addObject:headerArray];
    }
    return _dataArr;
}


/**
 顶部固定的数组  新的朋友 群聊
 
 @return 顶部固定的数组
 */
- (NSArray *)addTopFriend {
    // 新的朋友
    CHMFriendModel *newFriendModel = [[CHMFriendModel alloc] initWithUserId:KNewFriend nickName:@"新的朋友" portrait:@"newFriend"];
    // 群聊
    CHMFriendModel *groupFriendModel = [[CHMFriendModel alloc] initWithUserId:KGroupList nickName:@"群聊" portrait:@"defaultGroup"];
    NSArray *headerArray = @[newFriendModel, groupFriendModel];
    return headerArray;
}

/**
 [[UILocalizedIndexedCollation currentCollation] sectionTitles]  即可生成 26个字母 + #
 */
- (NSMutableArray *)indexArr {
    if (!_indexArr) {
        _indexArr = [NSMutableArray array];
        // 添加26个字母
        for (int i = 0; i < 26; i++) {
            NSString *str = [NSString stringWithFormat:@"%c",i+65];
            [_indexArr addObject:str];
        }
        // 添加 # 号
        [_indexArr addObject:@"#"];
    }
    return _indexArr;
}

- (UILabel *)indexLabelCenter {
    if (!_indexLabelCenter) {
        _indexLabelCenter = [UILabel initWithString:@"" fontSize:24 textColor:[UIColor whiteColor]];
        _indexLabelCenter.frame = CGRectMake(0, 0, 55, 55);
        _indexLabelCenter.layer.cornerRadius = 5;
        _indexLabelCenter.layer.masksToBounds = YES;
        // 背景颜色
        _indexLabelCenter.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _indexLabelCenter.textAlignment = NSTextAlignmentCenter;
        _indexLabelCenter.alpha = 0;
    }
    return _indexLabelCenter;
}

- (UIView *)indexContentView {
    if (!_indexContentView) {
        CGFloat navigationBarHeight = KISIphoneX ? KNavigationBar88 : KNavigationBar64;
        CGFloat tabBarHeight = KISIphoneX ? KTouchBarHeight + KTabBar49 : KTabBar49;
        _indexContentView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - KIndexViewWidth, navigationBarHeight, KIndexViewWidth, SCREEN_HEIGHT - navigationBarHeight - tabBarHeight)];
    }
    return _indexContentView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
