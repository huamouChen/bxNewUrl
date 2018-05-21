//
//  CHMChangePasswordController.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/11.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMChangePasswordController.h"

@interface CHMChangePasswordController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *nPwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *comfirmTextField;

@property(nonatomic, strong) CHMBarButtonItem *rightBtn;
@end

@implementation CHMChangePasswordController

#pragma mark - view life cycler
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
}

/**
 设置外观
 */
- (void)setupAppearance {
    self.title = @"修改密码";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.oldPasswordTextField addTarget:self action:@selector(textHadChange) forControlEvents:UIControlEventEditingChanged];
    [self.nPwdTextField addTarget:self action:@selector(textHadChange) forControlEvents:UIControlEventEditingChanged];
    [self.comfirmTextField addTarget:self action:@selector(textHadChange) forControlEvents:UIControlEventEditingChanged];
    
    [self setNavigationButton];
}

- (void)setNavigationButton {
    self.rightBtn = [[CHMBarButtonItem alloc] initWithbuttonTitle:@"确定"
                                                       titleColor:[UIColor chm_colorWithHexString:@"#9fcdfd" alpha:1.0]
                                                      buttonFrame:CGRectMake(0, 0, 50, 30)
                                                           target:self
                                                           action:@selector(setNewPassword)];
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[UIColor chm_colorWithHexString:@"#9fcdfd" alpha:1.0]
                      barButtonItem:self.rightBtn];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}


/**
 设置新的密码
 */
- (void)setNewPassword {
    [self.view endEditing:YES];
    
    if (![_nPwdTextField.text isEqualToString:_comfirmTextField.text]) {
        [CHMProgressHUD showErrorWithInfo:@"两次密码输入不一致"];
        return;
    }
    
    [CHMProgressHUD showWithInfo:@"正在修改中..." isHaveMask:YES];
    [CHMHttpTool changePasswordWithOldPassword:_oldPasswordTextField.text newPassword:_nPwdTextField.text success:^(id response) {
        
        NSLog(@"---------%@", response);
        NSNumber *codeId = response[@"Code"][@"CodeId"];
        if (codeId.integerValue == 100) {
            [CHMProgressHUD showSuccessWithInfo:@"修改成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
 输入框的值发生变化
 */
- (void)textHadChange {
    if (_oldPasswordTextField.text.length > 0 && _nPwdTextField.text.length > 0 && _comfirmTextField.text.length > 0) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
