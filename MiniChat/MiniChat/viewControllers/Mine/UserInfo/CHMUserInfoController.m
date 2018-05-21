//
//  CHMUserInfoController.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/9.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMUserInfoController.h"
#import "CHMUserPortraitCell.h"
#import "CHMUserDetailCell.h"
#import "CHMEditUserInfoController.h"
#import <Photos/Photos.h>
#import "CHMPhotoBrowserController.h"


static NSString *const portraitCellReuseId = @"CHMUserPortraitCell";
static NSString *const detailCellReuseId = @"CHMUserDetailCell";

@interface CHMUserInfoController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, copy) NSString *portraitString;

@end

@implementation CHMUserInfoController

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self imagePickerControllerDidCancel:picker];
    UIImage *selectedImage = nil;
    selectedImage = picker.allowsEditing ? info[UIImagePickerControllerEditedImage] : info[UIImagePickerControllerOriginalImage];
    [self uploadPortraitWithImage:selectedImage];
}

/**
 上传头像
 */
- (void)uploadPortraitWithImage:(UIImage *)image {
    // 上传头像到服务器
    [CHMProgressHUD showWithInfo:@"正在上传中..." isHaveMask:YES];
    __weak typeof(self) weakSelf = self;
    [CHMHttpTool setUserPortraitWithImage:image success:^(id response) {
        NSLog(@"-------------%@",response);
        NSNumber *codeId = response[@"Result"];
        if (codeId.integerValue == 1) {
            [CHMProgressHUD dismissHUD];
            NSString *imageUrl = @"";
            NSString *headerImageString = response[@"Parameter"];
            NSData *jsonData = [headerImageString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
            if (dict) {
                imageUrl = [NSString stringWithFormat:@"%@%@", BaseURL,dict[@"HeaderImage"]];
            }
            [[NSUserDefaults standardUserDefaults] setObject:imageUrl forKey:KPortrait];
            [weakSelf initLocalData];
            [weakSelf.tableView reloadData];
            // 刷新IM缓存数据
            NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:KAccount];
            NSString *nickName = [[NSUserDefaults standardUserDefaults] valueForKey:KNickName];
            RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:userId name:nickName portrait:imageUrl];
            [[CHMDataBaseManager shareManager] insertUserToDB:userInfo];
            [[CHMDataBaseManager shareManager] insertFriendToDB:userInfo];
            [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userId];
            // 发通知，更新其他地方的头像
            [[NSNotificationCenter defaultCenter] postNotificationName:KChangeUserInfoNotification object:imageUrl];
        } else {
            [CHMProgressHUD showErrorWithInfo:response[@"Error"]];
        }
    } failure:^(NSError *error) {
        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"错误码--%ld",(long)error.code]];
    }];
}


/**
 拍照
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
 从相册选中照片
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

#pragma mark - view life cycler
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initLocalData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupAppearance];
}

/**
 初始化本地数据
 */
- (void)initLocalData {
    NSString *portraitString = [[NSUserDefaults standardUserDefaults] valueForKey:KPortrait];
    self.portraitString = portraitString;
    NSString *nickName = [[NSUserDefaults standardUserDefaults] valueForKey:KNickName];
    NSString *mobileString = [[NSUserDefaults standardUserDefaults] valueForKey:KPhoneNum];
    
    self.dataArray = @[@{KItemName: @"头像", KItemValue: portraitString},
                       @{KItemName: @"昵称", KItemValue: nickName},
                       @{KItemName: @"手机", KItemValue: mobileString}];
    
    [self.tableView reloadData];
}

/**
 设置外观
 */
- (void)setupAppearance {
    self.title = @"个人信息";
    
    // table footer
    self.tableView.tableFooterView = [UIView new];
    // regsiter cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CHMUserPortraitCell class]) bundle:nil] forCellReuseIdentifier:portraitCellReuseId];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CHMUserDetailCell class]) bundle:nil] forCellReuseIdentifier:detailCellReuseId];
    // row height
    self.tableView.estimatedRowHeight = 60;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        CHMUserPortraitCell *cell = [tableView dequeueReusableCellWithIdentifier:portraitCellReuseId];
        cell.infoDict = _dataArray[indexPath.row];
        return cell;
    }
    
    CHMUserDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:detailCellReuseId];
    cell.infoDict = _dataArray[indexPath.row];
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: // 头像
            [self portraitClick];
            break;
        case 1: // 昵称
            [self nickNameClick];
            break;
        case 2:  //手机号
            [self mobileClcick];
            break;
        default:
            break;
    }
}


/**
 点击头像
 */
- (void)portraitClick {
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
    // 查看大图
    __weak typeof(self) weakSelf = self;
    UIAlertAction *scaleAction = [UIAlertAction actionWithTitle:@"大图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CHMPhotoBrowserController *vc = [[CHMPhotoBrowserController alloc] initWithPhotosArray:@[weakSelf.portraitString] currentIndex:0 transitionStyle:CHMPhotoBrowserTransitionPresent];
        vc.isShowPageLabel = YES;
        [self presentViewController:vc animated:YES completion:nil];
    }];
    
    [alertController addAction:cancleAction];
    [alertController addAction:cameraAction];
    [alertController addAction:albumAction];
    [alertController addAction:scaleAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


/**
 点击昵称
 */
- (void)nickNameClick {
    CHMEditUserInfoController *editController = [CHMEditUserInfoController new];
    editController.isEditNickName = YES;
    [self.navigationController pushViewController:editController animated:YES];
}


/**
 点击手机号码
 */
- (void)mobileClcick {
    CHMEditUserInfoController *editController = [CHMEditUserInfoController new];
    editController.isEditNickName = NO;
    [self.navigationController pushViewController:editController animated:YES];
}


- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}


@end
