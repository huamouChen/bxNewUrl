
//
//  CHMLoginController.m
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMLoginController.h"
#import "RCUnderlineTextField.h"
#import "CHMRegisterController.h"
#import <SAMKeychain/SAMKeychain.h>


static NSString *const IMServices = @"IMServices";


@interface CHMLoginController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *bgImg;
@property (weak, nonatomic) IBOutlet RCUnderlineTextField *accountTextField;
@property (weak, nonatomic) IBOutlet RCUnderlineTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

// 获取融云 token 的次数
@property(nonatomic, assign) int loginTimes;

// userId
@property(nonatomic, copy) NSString *userId;
// password
@property(nonatomic, copy) NSString *password;

// 融云 token
@property (nonatomic, copy) NSString *rongToken;

@end

@implementation CHMLoginController
#pragma mark - 点击事件
/**
 点击登录按钮
 */
- (IBAction)clickLoginButton {
    __weak typeof(self) weakSelf = self;
    if (_accountTextField.text.length <=0) {
        [CHMProgressHUD showErrorWithInfo:@"账号不能为空"];
        return;
    }
    if (_passwordTextField.text.length <= 0) {
        [CHMProgressHUD showErrorWithInfo:@"密码不能为空"];
        return;
    }
    [self.view endEditing:YES];
    [CHMProgressHUD showWithInfo:@"正在登录中..." isHaveMask:YES];
    
    [CHMHttpTool loginWithAccount:_accountTextField.text password:_passwordTextField.text success:^(id response) {
        NSLog(@"----------%@", response );
        NSString *loginToken = response[@"accessToken"];
        if ([loginToken isKindOfClass:[NSNull class]] || loginToken == nil || [loginToken isEqualToString:@""]) {
            [CHMProgressHUD showErrorWithInfo:@"登录出现错误"];
            return ;
        }
        weakSelf.userId = weakSelf.accountTextField.text;
        weakSelf.password = weakSelf.passwordTextField.text;
        [[NSUserDefaults standardUserDefaults] setObject:loginToken forKey:KLoginToken];
        [self getRongToken];
        
        
    } failure:^(id error) {
        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"%@",error]];
    }];
}


/**
 获取融云token
 */
- (void)getRongToken {
    __weak typeof(self) weakSelf = self;
    [CHMHttpTool getUserInfoWithUserId:_accountTextField.text success:^(id response) {
        NSLog(@"----------%@", response );
        NSString *nickName = response[@"userName"];
        NSString *headerImage = response[@"headerImage"];
        NSString *rongToken = response[@"rongToken"];
        NSString *moblieNumber = response[@"moblieNumber"];
        nickName = ([nickName isKindOfClass:[NSNull class]] || [nickName isEqualToString:@""] || nickName == nil) ? weakSelf.accountTextField.text : nickName;
        headerImage = ([headerImage isKindOfClass:[NSNull class]] || [headerImage isEqualToString:@""] || headerImage == nil) ? KDefaultPortrait : [NSString stringWithFormat:@"%@%@",BaseURL, headerImage];
        moblieNumber = ([moblieNumber isKindOfClass:[NSNull class]] || [moblieNumber isEqualToString:@""] || moblieNumber == nil) ? @"" : moblieNumber;
        
        
        // 连接融云服务器
        [[RCIM sharedRCIM] connectWithToken:rongToken success:^(NSString *userId) {
            
            // 保存融云Token
            [[NSUserDefaults standardUserDefaults] setObject:rongToken forKey:KRongCloudToken];
            
            // 保存用户信息
            [[NSUserDefaults standardUserDefaults] setObject:weakSelf.userId forKey:KAccount];
            [[NSUserDefaults standardUserDefaults] setObject:nickName forKey:KNickName];
            [[NSUserDefaults standardUserDefaults] setObject:headerImage forKey:KPortrait];
            [[NSUserDefaults standardUserDefaults] setObject:moblieNumber forKey:KPhoneNum];
            // 保存账号密码
            [SAMKeychain setPassword:weakSelf.password forService:IMServices account:weakSelf.userId];
            
            // 本地数据
            RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:weakSelf.userId name:nickName portrait:headerImage];
            [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:weakSelf.userId];
            [[CHMDataBaseManager shareManager] insertUserToDB:userInfo];
            
            //同步群组
            [[CHMInfoProvider shareInstance] syncGroups];
            // 同步好友
            [[CHMInfoProvider shareInstance] syncFriendList:weakSelf.userId complete:^(NSMutableArray *friends) {
                
            }];
            
            // 切换根控制器
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:KSwitchRootViewController object:nil];
            });
            
            
        } error:^(RCConnectErrorCode status) {
            [CHMProgressHUD showErrorWithInfo:@"连接服务器出错"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:KLoginToken];
        } tokenIncorrect:^{
            if (weakSelf.loginTimes >= 5) {
                [CHMProgressHUD showErrorWithInfo:@"连接失败，请稍后重试"];
                return;
            }
            weakSelf.loginTimes++;
            [self getRongToken];
        }];
    } failure:^(id error) {
        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"%@",error]];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:KLoginToken];
    }];
}


/**
 点击新用户按钮
 */
- (IBAction)clickRegisterButton {
    [self.navigationController pushViewController:[CHMRegisterController new] animated:YES];
}


#pragma mark -  view life cycler
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.view sendSubviewToBack:_bgImg];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initAppearance];
    
    // 从沙盒获取账号 密码
    NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:KAccount];
    self.accountTextField.text = account;
    // 密码
    NSString *password = [SAMKeychain passwordForService:IMServices account:account];
    self.passwordTextField.text = password;
    
}

- (void)initAppearance {
    [self.view sendSubviewToBack:self.bgImg];
    self.loginTimes = 0;
    _accountTextField.textColor = [UIColor whiteColor];
    _accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"账号" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [_accountTextField addTarget:self action:@selector(accountTextFiedTextIsChange) forControlEvents:UIControlEventEditingChanged];
    _accountTextField.delegate = self;
    _accountTextField.returnKeyType = UIReturnKeyNext;
    _passwordTextField.textColor = [UIColor whiteColor];
    _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [_passwordTextField setSecureTextEntry:YES];
    _passwordTextField.delegate = self;
    _accountTextField.returnKeyType = UIReturnKeyDone;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 1000) {
        [_accountTextField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    } else {
        [self.view endEditing:YES];
    }
    return false;
}


/**
 账户的值发生变化
 */
- (void)accountTextFiedTextIsChange {
    self.passwordTextField.text = @"";
    // 密码
    NSString *password = [SAMKeychain passwordForService:IMServices account:self.accountTextField.text];
    self.passwordTextField.text = password;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
