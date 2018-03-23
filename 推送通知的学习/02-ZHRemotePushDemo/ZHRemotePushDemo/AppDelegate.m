//
//  AppDelegate.m
//  ZHRemotePushDemo
//
//  Created by xyj on 2018/3/15.
//  Copyright © 2018年 xyj. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //1. 在程序启动那一刻向苹果的APNS服务器获取devicetoken
    //1.1 判断iOS版本,iOS8.0以上版本需要的到用户的许可
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        //申请用户许可
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
        //1.2 注册远程通知(调用该方法就是向苹果的apns服务器发送该设备的udid和bundle id,返回deviceToken)
        [application registerForRemoteNotifications];
    }else{//iOS7不需要请示用户,直接注册
        [application registerForRemoteNotificationTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound];
    }
   // 5.1 当程序杀死状态,点击本地通知调用
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        //跳转
        //获得本地通知
        UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        //有type可以判断跳转到哪一个界面
        UILabel *redView = [[UILabel alloc] init];
        redView.frame = CGRectMake(0, 0, 200, 300);
        redView.numberOfLines  = 0;
        redView.font = [UIFont systemFontOfSize:12.0];
        redView.backgroundColor = [UIColor redColor];
        redView.text = [NSString stringWithFormat:@"%@",notification];
        [self.window.rootViewController.view addSubview:redView];
    }
    
    return YES;
}
//2. 监听苹果返回devicetoken
/*
 注意: 仅仅通过第一步是拿不到devicetoken的.
 要不然苹果的APNS服务器都爆了,那么多设备都可以访问了.
 因此,苹果需要你买开发者账号,然后配置证书
 3. 配置证书
 */
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    //4.将DeviceToken传给服务器
    NSLog(@"%@", deviceToken.description);
}
//向apns请求失败
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"===请求devicetoken失败==%@",error);
}
//5. 接收远程推送
//前后台点击进入时调用
//iOS7之前用这个方法(<iOS7)
/*
 调用时刻:
 点击通知:前后台都会调用,杀死不会调用,只会调用1
 推送的消息中包含content-available字段: 后台时,不点击也会调用
 */
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
     NSLog(@"------调用了99999999");
    if (application.applicationState == UIApplicationStateBackground) {
        //进行界面的跳转
        //通知的额外信息可以再这里获得userInfo
        UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(150, 0, 100, 100)];
        redView.backgroundColor = [UIColor blueColor];
        [self.window.rootViewController.view addSubview:redView];
    }
}
/*
 是在iOS 7之后新增的方法，可以说是2的升级版本，如果app最低支持iOS 7的话可以不用添加 2了。
 如果实现了该方法,2方法不会调用
 点击应用程序图标无法获取推送消息,只有点击通知才会得到
 
 使用条件
 1.打开后台模式-> capablititles->background Modes->打开->勾选Remote notifications
 2.告诉系统是否有新的更新->completionHandler(UIBackgroundFetchResultNewData);
 
 调用时刻:
 点击通知:前后台都会调用,杀死也会调用,先调用1,在调用3
 推送的消息中包含content-available字段: 后台时,不点击也会调用

 */
//iOS7之后用这个方法(>iOS7)
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    //可以在这个方法中做些数据下载操作，争取在用户点击通知前，就将数据下载完毕
    //进行界面的跳转
    //通知的额外信息可以再这里获得userInfo
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(150, 0, 100, 100)];
    redView.backgroundColor = [UIColor blueColor];
    [self.window.rootViewController.view addSubview:redView];
    NSLog(@"------调用了");
    //下载完毕要调用completionHandler这个block，告知下载完毕
    completionHandler(UIBackgroundFetchResultNewData);
}
@end
