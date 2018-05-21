//
//  CHMBettingController.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/4.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMBettingController.h"
#import "CHMPalyCell.h"
#import "CHMPlayItemModel.h"
#import "CHMPlayHeaderView.h"

static NSString *const playCellReuseId = @"CHMPalyCell";
static NSString *const headerReuseId = @"CHMPlayHeaderView";

@interface CHMBettingController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UITextField *moneyTextField;
@property (weak, nonatomic) IBOutlet UICollectionView *playCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

// 玩法数组
@property (strong, nonatomic) NSMutableArray *playArray;
// 上一个选中的玩法item
@property (nonatomic, strong) NSIndexPath *preIndexpath;

// 上一个选中的固定金额按钮
@property (nonatomic, strong) UIButton *preButton;
@property (weak, nonatomic) IBOutlet UIButton *button10;
@property (weak, nonatomic) IBOutlet UIButton *button100;
@property (weak, nonatomic) IBOutlet UIButton *button500;
@property (weak, nonatomic) IBOutlet UIButton *button1000;
// 下注金额
@property (nonatomic, copy) NSString *bettingMoneyString;
// 玩法选择
@property (nonatomic, copy) NSString *playItemString;
@end

@implementation CHMBettingController

#pragma mark - 点击事件 collection view data sourece
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _playArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CHMPalyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:playCellReuseId forIndexPath:indexPath];
    cell.playItemModel = self.playArray[indexPath.item];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    CHMPlayHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerReuseId forIndexPath:indexPath];
    
    return header;
}

#pragma mark - collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 如果有上一个，就把上一个选为未选中
    if (_preIndexpath) {
        CHMPlayItemModel *selectedModel = self.playArray[_preIndexpath.item];
        selectedModel.isCheck = NO;
        [self.playArray replaceObjectAtIndex:_preIndexpath.item withObject:selectedModel];
    }
    // 替换原来的数据
    CHMPlayItemModel *selectedModel = self.playArray[indexPath.item];
    selectedModel.isCheck = !selectedModel.isCheck;
    [self.playArray replaceObjectAtIndex:indexPath.item withObject:selectedModel];
    // 刷新数据
    [collectionView reloadData];
    // 玩法
    CHMPlayItemModel *playItemModel = self.playArray[indexPath.item];
    self.playItemString = playItemModel.playName;
    
    _preIndexpath = indexPath;
}



/**
 点击固定金额按钮
 
 @param sender 固定金额按钮
 */
- (IBAction)fixedMoneyButtonClick:(UIButton *)sender {
    // 清空输入框
    _moneyTextField.text = @"";
    // 取消上一个按钮选中状态
    if (_preButton) {
        [_preButton setSelected:NO];
        _preButton.layer.borderColor =  [UIColor chm_colorWithHexString:KSeparatorColor alpha:1.0].CGColor;
    }
    // 选中状态取反
    [sender setSelected:!sender.isSelected];
    sender.layer.borderColor = sender.isSelected ? [UIColor chm_colorWithHexString:KMainColor alpha:1.0].CGColor : [UIColor chm_colorWithHexString:KSeparatorColor alpha:1.0].CGColor;
    // 下注金额
    self.bettingMoneyString = [sender.titleLabel.text substringToIndex:sender.titleLabel.text.length - 1];
    _preButton = sender;
}

/**
 点击遮罩视图
 
 @param sender tap 手势
 */
- (IBAction)tapMaskView:(id)sender {
    if ([self.moneyTextField isEditing]) {
        [self.view endEditing:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


/**
 点击确定按钮
 */
- (IBAction)comfirmButtonClick {
    
    if (!_playItemString || [_playItemString isEqualToString:@""]) {
        [CHMProgressHUD showErrorWithInfo:@"玩法不能为空"];
        return;
    }
    
    if (!_bettingMoneyString || [_bettingMoneyString isEqualToString:@""]) {
        [CHMProgressHUD showErrorWithInfo:@"金额不能为空"];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"玩法----%@------金额%@",_playItemString, _bettingMoneyString);
    NSString *bettingMsg = [NSString stringWithFormat:@"%@%@",_playItemString, _bettingMoneyString];
    [CHMHttpTool postTxtMessageToServiceWithMessage:bettingMsg groupId:_targetId success:^(id response) {
        NSLog(@"------%@",response);
    } failure:^(NSError *error) {
        NSLog(@"------%zd",error.code);
    }];
    
    // 发送一条文本消息
    RCTextMessage *txtMsg = [RCTextMessage messageWithContent:bettingMsg];
    [[RCIM sharedRCIM] sendMessage:_conversationType targetId:_targetId content:txtMsg pushContent:@"您有一条新的消息" pushData:@"您有一条新的消息" success:^(long messageId) {
        NSLog(@"------------%lu", messageId);
    } error:^(RCErrorCode nErrorCode, long messageId) {
        NSLog(@"------------%lu----%zd", messageId, nErrorCode);
    }];
}


#pragma mark - view life cycler
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initLocalData];
    
    [self setupAppearance];
    


}

/**
 初始化本地数据
 */
- (void)initLocalData {
    NSArray *playItemNameArray = @[@"极大", @"极小", @"大双", @"小双", @"大单", @"小单", @"大", @"小", @"双", @"单", @"豹子", @"蓝波", @"绿波", @"红波",];
    self.playArray = [NSMutableArray array];
    for (int i = 0; i < playItemNameArray.count; i++) {
        CHMPlayItemModel *playModel = [[CHMPlayItemModel alloc] initWithPlayName:playItemNameArray[i] isCheck:NO];
        [self.playArray addObject:playModel];
    }
    
    [self.playCollectionView reloadData];
}

/**
 设置外观
 */
- (void)setupAppearance {
    self.navigationController.navigationBar.translucent = NO;
    
    
    // register cell
    [self.playCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CHMPalyCell class]) bundle:nil] forCellWithReuseIdentifier:playCellReuseId];
    // register header
    [self.playCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CHMPlayHeaderView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerReuseId];
    self.flowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 44);
    
    // 每个item的大小
    self.flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH / 4.0, 41.0);
    self.flowLayout.minimumLineSpacing = 0.0;
    self.flowLayout.minimumInteritemSpacing = 0.0;
    
    [self.moneyTextField addTarget:self action:@selector(textDidChangeForTextField:) forControlEvents:UIControlEventEditingChanged];
    
    _button10.layer.borderColor = [UIColor chm_colorWithHexString:KSeparatorColor alpha:1.0].CGColor;
    _button100.layer.borderColor = [UIColor chm_colorWithHexString:KSeparatorColor alpha:1.0].CGColor;
    _button500.layer.borderColor = [UIColor chm_colorWithHexString:KSeparatorColor alpha:1.0].CGColor;
    _button1000.layer.borderColor = [UIColor chm_colorWithHexString:KSeparatorColor alpha:1.0].CGColor;
}


/**
 输入金额输入框变化监听
 
 @param textField 输入金额输入框
 */
- (void)textDidChangeForTextField:(UITextField *)textField {
    self.bettingMoneyString = textField.text;
    [_preButton setSelected:NO];
    _preButton.layer.borderColor =  [UIColor chm_colorWithHexString:KSeparatorColor alpha:1.0].CGColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    self.maskView.backgroundColor = [UIColor chm_colorWithHexString:@"#000000" alpha:0.4];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
