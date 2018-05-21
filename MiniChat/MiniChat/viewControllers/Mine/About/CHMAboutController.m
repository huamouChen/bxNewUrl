//
//  CHMAboutController.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/9.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMAboutController.h"
#import "CHMAboutCell.h"
#import "CHMAboutHeaderView.h"
#import "CHMFunctionController.h"

static NSString *const reuseId = @"CHMAboutCell";
static CGFloat const headerHeight = 180;

@interface CHMAboutController ()
@property (nonatomic, strong) NSArray *itemArray;
@end

@implementation CHMAboutController

#pragma mark - view life cyler
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
}

/**
 设置外观
 */
- (void)setupAppearance {
    self.title = @"关于博信";
    
    // 数据
    NSString *SealTalkVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.itemArray = @[@{@"item":@"功能介绍", @"subItem": @""}, @{@"item":  @"当前版本", @"subItem": SealTalkVersion}];
    
    self.tableView.backgroundColor = [UIColor chm_colorWithHexString:@"f0f0f6" alpha:1.f];
    
    
    
    self.tableView.tableFooterView = [UIView new];
    
    // register cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CHMAboutCell class]) bundle:nil] forCellReuseIdentifier:reuseId];
    
    // header view
    CHMAboutHeaderView *tableHeader = [[CHMAboutHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, headerHeight)];
    self.tableView.tableHeaderView = tableHeader;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHMAboutCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    cell.infoDict = _itemArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:[CHMFunctionController new] animated:YES];
    }
}

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

@end
