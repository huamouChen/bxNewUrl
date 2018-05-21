//
//  CHMEditUserInfoController.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/10.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMEditUserInfoController.h"

@interface CHMEditUserInfoController ()
@property (weak, nonatomic) IBOutlet UITextField *editTextField;

@property(nonatomic, strong) CHMBarButtonItem *rightBtn;

@property(nonatomic, strong) CHMBarButtonItem *leftBtn;

@property(nonatomic, copy) NSString *nickName;
@property(nonatomic, copy) NSString *mobilePhone;

@end

@implementation CHMEditUserInfoController

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
    
    self.title = _isEditNickName ? @"昵称修改" : @"手机号修改";
    NSString *nickName = [[NSUserDefaults standardUserDefaults] valueForKey:KNickName];
    NSString *mobileString = [[NSUserDefaults standardUserDefaults] valueForKey:KPhoneNum];
    self.editTextField.text = _isEditNickName ? nickName : mobileString;
    
    [self.editTextField addTarget:self action:@selector(textFieldEditChanged) forControlEvents:UIControlEventEditingChanged];
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
    if (_isEditNickName) {
        [self changeNickName];
        self.nickName = self.editTextField.text;
    } else {
        [self changePhoneNumber];
        self.mobilePhone = self.editTextField.text;
    }
}


/**
 修改手机号码
 */
- (void)changePhoneNumber {
    __weak typeof(self) weakSelf = self;
    [CHMProgressHUD showWithInfo:@"正在修改中..." isHaveMask:YES];
    [CHMHttpTool bindMobilePhoneWithPhoneNumber:_editTextField.text success:^(id response) {
        NSLog(@"------------%@", response);
        NSNumber *codeId = response[@"Result"];
        if (codeId.integerValue == 1) {
            [CHMProgressHUD showSuccessWithInfo:@"修改成功"];
            // 更改沙盒包保存的数据
            [[NSUserDefaults standardUserDefaults] setObject:weakSelf.editTextField.text forKey:KPhoneNum];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [CHMProgressHUD dismissHUD];
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
             [CHMProgressHUD showErrorWithInfo:response[@"Error"]];
        }
    } failure:^(NSError *error) {
        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"错误码--%ld",(long)error.code]];
    }];
}


/**
 修改昵称
 */
- (void)changeNickName {
    __weak typeof(self) weakSelf = self;
    [CHMProgressHUD showWithInfo:@"正在修改中..." isHaveMask:YES];
    [CHMHttpTool setUserNickNameWithNickName:_editTextField.text success:^(id response) {
        NSLog(@"------------%@", response);
        NSNumber *codeId = response[@"Result"];
        if (codeId.integerValue == 1) {
            [CHMProgressHUD showSuccessWithInfo:@"修改成功"];
            // 更改沙盒包保存的数据
            [[NSUserDefaults standardUserDefaults] setObject:weakSelf.editTextField.text forKey:KNickName];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // 刷新IM缓存数据
            NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:KAccount];
            NSString *nickName = [[NSUserDefaults standardUserDefaults] valueForKey:KNickName];
            NSString *portrait = [[NSUserDefaults standardUserDefaults] valueForKey:KPortrait];
            RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:userId name:nickName portrait:portrait];
            [[CHMDataBaseManager shareManager] insertUserToDB:userInfo];
            [[CHMDataBaseManager shareManager] insertFriendToDB:userInfo];
            [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userId];
            // 发通知，更新其他地方的头像
            [[NSNotificationCenter defaultCenter] postNotificationName:KChangeUserInfoNotification object:portrait];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [CHMProgressHUD dismissHUD];
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            [CHMProgressHUD showErrorWithInfo:response[@"Error"]];
        }
    } failure:^(NSError *error) {
        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"错误码--%ld",(long)error.code]];
    }];
}

/**
 保存按钮是否可以点击
 */
- (void)textFieldEditChanged {
    NSString *toBeString = _editTextField.text;
    if (![toBeString isEqualToString:self.nickName]) {
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
