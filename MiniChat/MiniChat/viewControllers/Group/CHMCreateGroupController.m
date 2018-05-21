//
//  CHMCreateGroupController.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/4.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMCreateGroupController.h"
#import "RCUnderlineTextField.h"
#import "CHMFriendModel.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "CHMConversationController.h"
#import "CHMGroupModel.h"


@interface CHMCreateGroupController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *addImg;
@property (weak, nonatomic) IBOutlet RCUnderlineTextField *nameTextField;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@end

@implementation CHMCreateGroupController


/**
 点击群组头像
 
 @param sender 点击的手势
 */
- (IBAction)tapGroupImageView:(UITapGestureRecognizer *)sender {
    self.imagePickerController = [[UIImagePickerController alloc] init];
    // 可编辑
    self.imagePickerController.allowsEditing = YES;
    self.imagePickerController.delegate = self;
    
    UIAlertController *alertController = [[UIAlertController alloc] init];
    // 取消
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    }];
    // 拍照
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showCamera];
    }];
    // 从相册选择
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showImagePicker];
    }];
    [alertController addAction:cancleAction];
    [alertController addAction:cameraAction];
    [alertController addAction:albumAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


/**
 使用相机拍照
 */
- (void)showCamera {
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authorizationStatus == AVAuthorizationStatusRestricted || authorizationStatus == AVAuthorizationStatusDenied) {
        // 没有权限
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    } else {
        // 是否支持相机功能
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePickerController animated:YES completion:nil];
        } else {
            [CHMProgressHUD showErrorWithInfo:@"相机功能不可用"];
        }
    }
}
/**
 从相册选择
 */
- (void)showImagePicker {
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    if (authorizationStatus == PHAuthorizationStatusDenied || authorizationStatus == PHAuthorizationStatusRestricted) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    } else {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.imagePickerController animated:YES completion:nil];
        } else {
            [CHMProgressHUD showErrorWithInfo:@"相册功能不可用"];
        }
    }
}

#pragma mark - image Picker controller delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // 隐藏picker controller
    [self imagePickerControllerDidCancel:picker];
    // 获取选择的照片
    UIImage *selectedImage = nil;
    selectedImage = [picker allowsEditing] ? info[UIImagePickerControllerEditedImage] : info[UIImagePickerControllerOriginalImage];
    self.addImg.image = selectedImage;
}

/**
 点击创建群组按钮
 */
- (IBAction)createGroupButtonClick {
    if (_nameTextField.text.length <= 0 ) {
        [CHMProgressHUD showErrorWithInfo:@"群组名称不能为空"];
        return;
    }
    NSString *groupName = [_nameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([groupName isEqualToString:@""] || groupName.length <= 0) {
        [CHMProgressHUD showErrorWithInfo:@"群组名称不能为空"];
        return;
    }
    
    // 当前账号，为了设置群创建者
    NSString *currentAccount = [[NSUserDefaults standardUserDefaults] valueForKey:KAccount];
    
    [self.view endEditing:YES];
    [CHMProgressHUD showWithInfo:@"正在创建中..." isHaveMask:YES];
    NSArray *groupMemberArray = [self dealWithGroupMemberId];
    [CHMHttpTool createGroupWtihGroupName:_nameTextField.text
                             groupMembers:groupMemberArray
                            groupPortrait:_addImg.image
                                  success:^(id response) {
                                      [CHMProgressHUD dismissHUD];
                                      NSLog(@"---------%@", response);
                                      NSNumber *codeId = response[@"Code"][@"CodeId"];
                                      NSString *responseDescripton = response[@"Code"][@"Description"];
                                      if (codeId.integerValue == 100) {
                                          // 刷新群组信息
                                          NSString *groupId = [NSString stringWithFormat:@"%@",response[@"Value"][@"GroupId"]];
                                          NSString *groupPortrait = [NSString stringWithFormat:@"%@%@",BaseURL, response[@"Value"][@"GroupImage"]];
                                          NSString *groupName = response[@"Value"][@"GroupName"];
                                          RCGroup *groupInfo = [[RCGroup alloc] initWithGroupId:groupId groupName:groupName portraitUri:groupPortrait];
                                          [[RCIM sharedRCIM] refreshGroupInfoCache:groupInfo withGroupId:groupId];
                                          // push
                                          [self starGroupConversationWithGroupInfo:groupInfo];
                                          // 保存数据到本地
                                          CHMGroupModel *groupModel = [[CHMGroupModel alloc] initWithGroupId:groupId groupName:groupName groupPortrait:groupPortrait];
                                          groupModel.GroupOwner = currentAccount;
                                          
                                          [[CHMDataBaseManager shareManager] insertGroupToDB:groupModel];
                                      } else {
                                          [CHMProgressHUD showErrorWithInfo: responseDescripton];
                                      }
                        
                                  } failure:^(NSError *error) {
                                      [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"错误码--%ld", (long)error.code]];
                                  }];
}


/**
 开启群组会话
 */
- (void)starGroupConversationWithGroupInfo:(RCGroup *)group {
    //新建一个聊天会话View Controller对象,建议这样初始化
    CHMConversationController *chatController = [[CHMConversationController alloc] initWithConversationType:ConversationType_GROUP
                                                                                                   targetId:group.groupId];
    [chatController setHidesBottomBarWhenPushed:YES];
    
    //设置会话的类型，如单聊、讨论组、群聊、聊天室、客服、公众服务会话等
    chatController.conversationType = ConversationType_GROUP;
    //设置会话的目标会话ID。（单聊、客服、公众服务会话为对方的ID，讨论组、群聊、聊天室为会话的ID）
    chatController.targetId = group.groupId;
    
    //设置聊天会话界面要显示的标题
    chatController.title = group.groupName;
    //显示聊天会话界面
    UIViewController *rootViewController = self.navigationController.viewControllers.firstObject; //拿到根控制器
    [self.navigationController popToRootViewControllerAnimated:NO];
    [rootViewController.navigationController pushViewController:chatController animated:YES];
}


/**
 处理群组成员ID
 */
- (NSArray *)dealWithGroupMemberId {
    // 群组成员ID
    NSMutableArray *groupMemberArray = [NSMutableArray array];
    for (int i = 0; i < self.selectedMembersArray.count; i++) {
        CHMFriendModel *friendModel = self.selectedMembersArray[i];
        [groupMemberArray addObject:friendModel.UserName];
    }
    return [NSArray arrayWithArray:groupMemberArray];
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
    self.title = @"创建群组";
    
    _nameTextField.textColor = [UIColor whiteColor];
    _nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入群组名称" attributes:@{NSForegroundColorAttributeName: [UIColor chm_colorWithHexString:@"#999999" alpha:1.0]}];
    _nameTextField.textAlignment = NSTextAlignmentCenter;
    _nameTextField.textColor = [UIColor chm_colorWithHexString:@"#666666" alpha:1.0];
}


#pragma mark - touch 触摸事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
