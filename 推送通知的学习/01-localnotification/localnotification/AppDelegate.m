//
//  AppDelegate.m
//  localnotification
//
//  Created by xyj on 17/2/9.
//  Copyright © 2017年 xyj. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //设置程序右上角的数字
    [application setApplicationIconBadgeNumber:0];
    //判断iOS版本,iOS8.0以上版本需要的到用户的许可
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert |UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    //launchOptions 点击本地/远程/URL(应用间跳转)等通知时,当程序在后台或者在前台进入时,该值都为null,但是程序又杀死状态进入时,有值,该值就是发出的通知
    //launchOptions 常用的key
   // UIApplicationLaunchOptionsLocalNotificationKey,通过本地通知把我打开,该值就是本地通知的值
   // UIApplicationLaunchOptionsRemoteNotificationKey,远程通知
   // UIApplicationLaunchOptionsURLKey ,URL应用建跳转
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        //获得本地通知
        UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
//        NSNumber *type = notification.userInfo[@"type"];
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
//应用程序从前台或者后台进入都会调用该方法
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    //针对应用程序在后台的时候进行跳转
    //UIApplicationStateActive,应用程序在前台
//    UIApplicationStateInactive,应用程序由后台进入前台
//    UIApplicationStateBackground应用程序在后台
    if (application.applicationState == UIApplicationStateInactive) {
        //进行界面的跳转:跳转到指定的界面
        //通知的额外信息可以再这里获得
        UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        redView.backgroundColor = [UIColor redColor];
        [self.window.rootViewController.view addSubview:redView];
    }
}
@end
