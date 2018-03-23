//
//  AppDelegate.m
//  localnotification
//
//  Created by xyj on 17/2/9.
//  Copyright © 2017年 xyj. All rights reserved.
//

#import "AppDelegate.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 1、获取应用的通知管理中心UNUserNotificationCenter,来管理推送通知
    UNUserNotificationCenter* center = [UNUserNotificationCenter   currentNotificationCenter];
    //2. 设置推送通知中心的代理,实现代理方法,监听通知的推送
    //注意：UNUserNotificationCenter的delegate必须在application:willFinishLaunchingWithOptions: or application:didFinishLaunchingWithOptions:方法中实现；
    center.delegate = self;
    
    //3. 设置预设好的交互类型，NSSet里面是设置好的UNNotificationCategory
    //就是当接收到通知时,拖拽向下,会看到互交控件:是按钮点击/还是文本输入,不设置没有按钮
    [center setNotificationCategories:[self createNotificationCategoryActions]];
    
    //4、请求用户授权
    //请求授权选项：
    // UNAuthorizationOption Badge= 1 (1 << 0),
    // UNAuthorizationOption Sound= 2 (1 << 1),
    // UNAuthorizationOption Alert= 4 (1 << 2),
    // UNAuthorizationOption CarPlay = 8 (1 << 3),
    //请求获取通知权限（角标，声音，弹框）
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //获取用户是否同意开启通知
            NSLog(@"request authorization successed!");
        }
    }];
    
    // 5、补充：获取当前的通知设置，UNNotificationSettings是只读对象，不能直接修改，只能通过以下方法获取
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        
        // UNAuthorizationStatus NotDetermined :没有做出选择
        // UNAuthorizationStatus Denied :用户未授权
        // UNAuthorizationStatus Authorized：用户已授权
        //进行判断做出相应的处理
        if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined)
        {
            NSLog(@"未选择");
        }else if (settings.authorizationStatus ==     UNAuthorizationStatusDenied){
            NSLog(@"未授权");
        }else if (settings.authorizationStatus ==    UNAuthorizationStatusAuthorized){
            NSLog(@"已授权");
        }
    }];
    //6. 获取到当前用户推送中心所有设置的互交类型
    [center getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> * _Nonnull categories) {
        
    }];
    //7.注册远程通知(调用该方法就是向苹果的apns服务器发送该设备的udid和bundle id,返回deviceToken)如果获取不到deviceToken，Xcode8下要注意开启Capability->Push Notification。
    [application registerForRemoteNotifications];
    return YES;
}

-(NSSet *)createNotificationCategoryActions{
    //1.设置交互类型1:seeCategory 2个按钮
    //1.1 定义按钮的交互button action
    //Identifier:互交的标识,当用户点击时可以再用户点击方法中查看点击是哪个btn
    //title:标题
    UNNotificationAction * likeButton = [UNNotificationAction actionWithIdentifier:@"see1" title:@"看一看" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground];
    UNNotificationAction * dislikeButton = [UNNotificationAction actionWithIdentifier:@"see2" title:@"忽略" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground];
    //1.2 将这些action带入category
    //Identifier:创建通知时会使用到这个,根据这个查看到底选择哪种互交方式
    UNNotificationCategory * choseCategory = [UNNotificationCategory categoryWithIdentifier:@"seeCategory" actions:@[likeButton,dislikeButton] intentIdentifiers:@[@"see1",@"see2"] options:UNNotificationCategoryOptionNone];
    
    //2. 设置交互类型2:seeCategory1  文本框输入类型
    //2.1 创建textAction
    UNTextInputNotificationAction * text = [UNTextInputNotificationAction actionWithIdentifier:@"text" title:@"回复" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground];
    //2.2 将action加入UNNotificationCategory
    UNNotificationCategory * comment = [UNNotificationCategory categoryWithIdentifier:@"seeCategory1" actions:@[text] intentIdentifiers:@[@"text"] options:UNNotificationCategoryOptionNone];
    
    //3. 将交互类型插入NSSet中,然后给整个app应用设置
    return [NSSet setWithObjects:choseCategory,comment,nil];
}


// 监听苹果返回devicetoken
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    //4.将DeviceToken传给服务器
    NSLog(@"%@", deviceToken.description);
}
//向apns请求失败
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"===请求devicetoken失败==%@",error);
}

#pragma mark - UNUserNotificationCenterDelegate
//这两个方法对本地远程都适用,不必使用UIApplicationDelegate代理方法本地远程分开接收了,而且在iOS10那些方法已经过期了.
/**
 特点: 如果该方法没有实现或者没有回调用completionHandler则前台通知将不会呈现,也接收不到
 作用: 在展示通知前进行处理，即有机会在展示通知前再修改通知内容。
 代用时刻: 应用程序在前台台时调用(通知即将展示,还没有展示时)(后台/杀死都不会调用),即不点击通知就会调用
 应用程序可以通过completionHandler()回调,选择怎样呈现这个通知: 只有角标变化的通知/只有声音提示/只有弹框提示或者3种的组合
 */
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    // 原始请求
    UNNotificationRequest *request = notification.request;
    // 获取请求的额外信息
    NSDictionary * userInfo = notification.request.content.userInfo;//userInfo数据
    // 请求的内容
    UNNotificationContent *content = request.content; // 原始内容
    NSString *title = content.title;  // 标题
    NSString *subtitle = content.subtitle;  // 副标题
    NSNumber *badge = content.badge;  // 角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 指定的声音
    //本地通知的判断:notification.request.trigger类型判断是远程还是本地推送
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10代理方法一的远程通知:%@",[notification description]);
        
    }else{
        NSLog(@"iOS10代理方法一的本地通知:%@",[notification description]);
    }
    //有type可以判断跳转到哪一个界面
    UILabel *redView = [[UILabel alloc] init];
    redView.frame = CGRectMake(0, 0, 200, 300);
    redView.numberOfLines  = 0;
    redView.font = [UIFont systemFontOfSize:12.0];
    redView.backgroundColor = [UIColor redColor];
    redView.text = [NSString stringWithFormat:@"%@",notification];
    [self.window.rootViewController.view addSubview:redView];
    //设置怎样接收通知:只有角标变化的通知/只有声音提示/只有弹框提示/3中的组合
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}

/**
 1. 调用时刻(应用程序在后台/杀死状态下都会调用)
     1. 用户点击通知打开app
     2. 下拉通知,选择一个互交动作:点击互交按钮/文本输入后点击发送
     3. 跟后台发送content-available没任何关系,必须操作才会调用
 
 用户与通知进行交互后的response，比如说用户直接点开通知打开App、用户点击通知的按钮或者进行输入文本框的文本
 */
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    
    //1.获取到通知详情
    UNNotificationRequest *request = response.notification.request; // 原始请求
    NSDictionary * userInfo = request.content.userInfo;//userInfo数据
    UNNotificationContent *content = request.content; // 原始内容
    //2.判断通知的种类
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"代理方法二的远程通知");
    }else{
        NSLog(@"代理方法二的本地通知");
    }
    
    //3.根据response的种类判断用户的互交类型
    //可根据actionIdentifier来做业务逻辑
    if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
        //交互类型为文本输入
        UNTextInputNotificationResponse * textResponse = (UNTextInputNotificationResponse*)response;
        //拿到用户交互的内容
        NSLog(@"用户输入的内容为: %@",textResponse.userText);
    }else{ //交互类型为点击按钮
        //点击第一个交互按钮
        if ([response.actionIdentifier isEqualToString:@"see1"]) {
            //I love it~😘的处理
            NSLog(@"用户点击的按钮为see1");
        }
        //点击第二个交互按钮
        if ([response.actionIdentifier isEqualToString:@"see2"]) {
            //删除已经推动过的推送需求
            NSLog(@"用户点击的按钮为see2");
            //I don't care~😳
            [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[response.notification.request.identifier]];
        }
    }
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(150, 0, 100, 100)];
    redView.backgroundColor = [UIColor blueColor];
    [self.window.rootViewController.view addSubview:redView];
    
    completionHandler();
}


@end
