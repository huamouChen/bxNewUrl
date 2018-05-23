//
//  CHMRegisterController.m
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMRegisterController.h"
#import "RCUnderlineTextField.h"

@interface CHMRegisterController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet RCUnderlineTextField *accountTextField;
@property (weak, nonatomic) IBOutlet RCUnderlineTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet RCUnderlineTextField *comfirmTextField;

@end

@implementation CHMRegisterController


/**
 点击注册按钮
 */
- (IBAction)registerButtonClick {
    [self.view endEditing:YES];
    if ([_accountTextField.text isEqualToString:@""]) {
        [CHMProgressHUD showErrorWithInfo:@"账号不能为空"];
        return;
    }
    if ([_passwordTextField.text isEqualToString:@""] || [_comfirmTextField.text isEqualToString:@""]) {
        [CHMProgressHUD showErrorWithInfo:@"密码不能为空"];
        return;
    }
    if (![_passwordTextField.text isEqualToString:_comfirmTextField.text]) {
        [CHMProgressHUD showErrorWithInfo:@"密码输入不一致"];
        return;
    }
    [CHMProgressHUD showWithInfo:@"正在注册中..." isHaveMask:YES];
    // 注册
    [CHMHttpTool registerWithAccount:_accountTextField.text password:_passwordTextField.text bounds:@"0.7" userType:@"0" success:^(id response) {
        NSLog(@"----------%@",response);
        [CHMProgressHUD showSuccessWithInfo:@"注册成功"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [CHMProgressHUD dismissHUD];
            [self.navigationController popViewControllerAnimated:YES];
        });
        
    } failure:^(id error) {
        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"%@",error]];
    }];
}


/**
 返回登录界面
 */
- (IBAction)loginButtonClick {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _accountTextField.textColor = [UIColor whiteColor];
    _accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"账号" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    _accountTextField.delegate = self;
    _accountTextField.returnKeyType = UIReturnKeyNext;
    _passwordTextField.textColor = [UIColor whiteColor];
    _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [_passwordTextField setSecureTextEntry:YES];
    _passwordTextField.delegate = self;
    _passwordTextField.returnKeyType = UIReturnKeyNext;
    _comfirmTextField.textColor = [UIColor whiteColor];
    _comfirmTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"确认密码" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [_comfirmTextField setSecureTextEntry:YES];
    _comfirmTextField.delegate = self;
    _comfirmTextField.returnKeyType = UIReturnKeyDone;
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == 1000) {
        [_accountTextField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    } else if (textField.tag == 2000) {
        [_passwordTextField resignFirstResponder];
        [_comfirmTextField becomeFirstResponder];
    } else {
        [self.view endEditing:YES];
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
