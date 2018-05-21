//
//  CHMGroupBulletinController.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/18.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMGroupBulletinController.h"
#import "CHMGroupModel.h"

@interface CHMGroupBulletinController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property(nonatomic, strong) CHMBarButtonItem *rightBtn;

@property(nonatomic, strong) CHMBarButtonItem *leftBtn;

@property(nonatomic, copy) NSString *groupBulletin;

@end

@implementation CHMGroupBulletinController

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [self textFieldEditChanged];
}

#pragma mark - view life cycler
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
}

/**
 设置外观
 */
- (void)setupAppearance {
    
    [self setNavigationButton];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor chm_colorWithHexString:@"#f0f0f6" alpha:1.0];
    
    self.title = @"群公告";
    self.textView.text = _originalGroupBulletin;
    
    self.textView.delegate = self;
}

- (void)setNavigationButton {
    //    self.leftBtn = [[CHMBarButtonItem alloc] initWithLeftBarButton:@"返回" target:self action:@selector(clickBackBtn)];
    //    self.navigationItem.leftBarButtonItem = self.leftBtn;
    
    self.rightBtn = [[CHMBarButtonItem alloc] initWithbuttonTitle:@"保存"
                                                       titleColor:[UIColor chm_colorWithHexString:@"#9fcdfd" alpha:1.0]
                                                      buttonFrame:CGRectMake(0, 0, 50, 30)
                                                           target:self
                                                           action:@selector(saveUserName:)];
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[UIColor chm_colorWithHexString:@"#9fcdfd" alpha:1.0]
                      barButtonItem:self.rightBtn];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

#pragma mark 点击保存按钮
- (void)saveUserName:(id)sender {
    [self.view endEditing:YES];
    self.groupBulletin = self.textView.text;
    
    if (!_isGroupOwner) {
        [CHMProgressHUD showErrorWithInfo:@"只有群主才可以修改群公告"];
        return;
    }
    
    [self modifyGroupName];
}

/**
 修改群公告
 */
- (void)modifyGroupName {
    __weak typeof(self) weakSelf = self;

    [CHMProgressHUD showWithInfo:@"正在修改中..." isHaveMask:YES];

    [CHMHttpTool modifyGroupBulletin:_textView.text forGroup:_groupId success:^(id response) {
        NSLog(@"------------%@", response);
        NSNumber *codeId = response[@"Code"][@"CodeId"];
        if (codeId.integerValue == 100) {
            [CHMProgressHUD showSuccessWithInfo:@"修改成功"];
            CHMGroupModel *groupModel = [[CHMDataBaseManager shareManager] getGroupByGroupId:weakSelf.groupId];
            groupModel.Bulletin = weakSelf.groupBulletin;
            // 刷新数据库的名称
            [[CHMDataBaseManager shareManager] insertGroupToDB:groupModel];
            // 刷新群组详情的界面
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [CHMProgressHUD dismissHUD];
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        } else {
            [CHMProgressHUD showErrorWithInfo:response[@"InnerMessage"]];
        }
    } failure:^(NSError *error) {
        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"错误码--%ld",(long)error.code]];
    }];
}

/**
 保存按钮是否可以点击
 */
- (void)textFieldEditChanged {
    NSString *toBeString = _textView.text;
    if (![toBeString isEqualToString:self.originalGroupBulletin] && _isGroupOwner) {
        [self.rightBtn buttonIsCanClick:YES buttonColor:[UIColor whiteColor] barButtonItem:self.rightBtn];
    } else {
        [self.rightBtn buttonIsCanClick:NO
                            buttonColor:[UIColor chm_colorWithHexString:@"9fcdfd" alpha:1.0]
                          barButtonItem:self.rightBtn];
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
