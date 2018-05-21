//
//  AppDelegate.m
//  MiniChat
//
//  Created by 陈华谋 on 29/04/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "AppDelegate.h"
#import <RongIMKit/RongIMKit.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "CHMLoginController.h"
#import "CHMMainController.h"
#import <UserNotifications/UserNotifications.h>
#import "CHMGroupTipMessage.h"


@interface AppDelegate () <UNUserNotificationCenterDelegate, RCIMReceiveMessageDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self setupBarAppearance];
    
    // 注册远程通知
    [self registerRemoteNotification];
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchRootViewController) name:KSwitchRootViewController object:nil];
    
    // 初始化融云
    [[RCIM sharedRCIM] initWithAppKey:RongCloudAppKey];
    // 注册自定义消息
    [[RCIM sharedRCIM] registerMessageType:[CHMGroupTipMessage class]];
    // 发送消息携带用户信息
    [self setIMInfoProvider];
    // 连接融云服务器
    [self connectToRongCloud];
    
    // IQKeyBoard 关闭toolBar
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [self switchRootViewController];
    
    return YES;
}

#pragma mark - RCIMReceiveMessageDelegate  收到消息
- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    NSLog(@"-------%@",message);
    // 好友信息
    RCContactNotificationMessage *contactNotificationMsg = nil;
    if ([message.objectName isEqualToString:@"RC:ContactNtf"]) {
        contactNotificationMsg = (RCContactNotificationMessage *)message.content;
        // 保存到数据库
        RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:contactNotificationMsg.targetUserId name:contactNotificationMsg.targetUserId portrait:KDefaultPortrait];
        [[CHMDataBaseManager shareManager] insertUserToDB:userInfo];
        [[CHMDataBaseManager shareManager] insertFriendToDB:userInfo];
        // 如果是同意好友申请的消息，就刷新好友列表数据
        NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:KAccount];
        [[CHMInfoProvider shareInstance] syncFriendList:account complete:^(NSMutableArray *friends) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KChangeUserInfoNotification object:nil];
        }];
    }
    
    // 把添加到群组的消息
    CHMGroupTipMessage *groupNotificationMsg = nil;
    //    RCGroupNotificationMessage
    if ([message.objectName isEqualToString:@"CHM:GtipMsg"]) {
        groupNotificationMsg = (CHMGroupTipMessage *)message.content;
        // 解散群组的操作
        if ([groupNotificationMsg.opeation isEqualToString:@"Dismiss"]) {
            [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_GROUP targetId:message.targetId];
            // 移除该条会话
            [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_GROUP targetId:message.targetId];
            // 删除本地数据中对应的群组
            [[CHMDataBaseManager shareManager] deleteGroupToDB:message.targetId];
        }  else {
            // 其他操作 刷新群组信息
            [[CHMInfoProvider shareInstance] syncGroupWithGroupId:message.targetId];
            [[CHMInfoProvider shareInstance] syncGroupMemberListWithGroupId:message.targetId];
        }
    }
}

/**
 连接融云服务器
 */
- (void)connectToRongCloud {
    NSString *rongCloudToken = [[NSUserDefaults standardUserDefaults] valueForKey:KRongCloudToken];
    [[RCIM sharedRCIM] connectWithToken:rongCloudToken success:^(NSString *userId) {
        NSLog(@"----连接成功%@",userId);
        [self setCurrentUserInfo];
        [RCIM sharedRCIM].receiveMessageDelegate = self;
        
    } error:^(RCConnectErrorCode status) {
        NSLog(@"----连接失败%ld",(long)status);
    } tokenIncorrect:^{
        NSLog(@"----连接token不正确");
    }];
}
/**
 设置当前用户的用户信息，用于SDK显示和发送。
 */
- (void)setCurrentUserInfo {
    // 从沙盒中取登录时保存的用户信息
    NSString *nickName = [[NSUserDefaults standardUserDefaults] valueForKey:KNickName];
    NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:KAccount];
    NSString *portrait = [[NSUserDefaults standardUserDefaults] valueForKey:KPortrait];
    [RCIM sharedRCIM].currentUserInfo = [[RCUserInfo alloc] initWithUserId:account name:nickName portrait:portrait];
}


#pragma mark - 注册远程通知 
- (void)registerRemoteNotification {
    // 设置代理
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    } else {
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

#pragma mark - 推送获取 token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#if TARGET_IPHONE_SIMULATOR
    // 模拟器不能使用远程推送
#else
    NSLog(@"获取DeviceToken失败！！！");
    NSLog(@"ERROR：%@", error);
#endif
}


#pragma mark - iOS10 之后收到推送
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)) API_AVAILABLE(ios(10.0)){
    NSLog(@"---------------ios10之后的推送");
    completionHandler();
}

#pragma ios10 之前收到推送
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"---------------ios10之前的推送");
    completionHandler(UIBackgroundFetchResultNewData);
}


#pragma mark - 信息提供者
- (void)setIMInfoProvider {
    // 从沙盒中取登录时保存的用户信息
    NSString *nickName = [[NSUserDefaults standardUserDefaults] valueForKey:KNickName];
    NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:KAccount];
    NSString *portrait = [[NSUserDefaults standardUserDefaults] valueForKey:KPortrait];
    if (account) {
        RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:account name:nickName portrait:portrait];
        [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:account];
        [RCIM sharedRCIM].currentUserInfo = userInfo;
    }
    
    
    //设置用户信息源和群组信息源
    [RCIM sharedRCIM].userInfoDataSource = [CHMInfoProvider shareInstance];
    [RCIM sharedRCIM].groupInfoDataSource = CHMIMDataSourece;
    //群成员数据源
    //    [RCIM sharedRCIM].groupMemberDataSource = CHMIMDataSourece;
}


/**
 设置跟控制器
 */
- (void)switchRootViewController {
    NSString *token =  [[NSUserDefaults standardUserDefaults] valueForKey:KRongCloudToken];
    if (token) {
        
        CHMMainController *mainController = (CHMMainController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"tabBarController"];
        [mainController preferredStatusBarStyle];
        self.window.rootViewController = mainController;
    } else {
        UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:[CHMLoginController new]];
        self.window.rootViewController = navCon;
    }
}


/**
 设置 navigationBar 和 tabBar 的样式
 */
- (void)setupBarAppearance {
    // navigationBar
    [[UINavigationBar appearance] setBarTintColor:[UIColor chm_colorWithHexString:KMainColor alpha:1.0]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:18]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    // tabBar
    [[UITabBar appearance] setTintColor:[UIColor chm_colorWithHexString:KMainColor alpha:1.0]];
    
    UIImage *tmpImage = [UIImage imageNamed:@"back"];
    
    CGSize newSize = CGSizeMake(12, 20);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
    [tmpImage drawInRect:CGRectMake(2, -2, newSize.width, newSize.height)];
    UIImage *backButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[UINavigationBar appearance] setBackIndicatorImage:backButtonImage];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backButtonImage];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
