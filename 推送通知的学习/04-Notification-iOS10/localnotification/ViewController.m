//
//  ViewController.m
//  localnotification
//
//  Created by xyj on 17/2/9.
//  Copyright © 2017年 xyj. All rights reserved.
//
#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
@interface ViewController ()
@property (nonatomic,assign) NSInteger number;
@end

@implementation ViewController


//延迟5秒发送本地通知
- (IBAction)locationNotificationAction:(id)sender {
    [self sendLocalNotification];
}

//推送本地通知：//使用UNNotification本地通知
-(void)sendLocalNotification{
    //1. 设置通知内容
    //需创建一个包含待通知内容的UNMutableNotificationContent对象，注意不是UNNotificationContent ,此对象为不可变对象。
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    //通知主标题
    content.title = @"主标题";
    //通知子标题
    content.subtitle = @"子标题";
    //设置通知的内容
    content.body = @"这是通知的内容????????????????????????";
    //或者也可以这样创建：
    //content.title = [NSString localizedUserNotificationStringForKey:@"主标题" arguments:nil];
    //content.body= [NSString localizedUserNotificationStringForKey:@"Hello_message_body" arguments:nil];
    //设置应用程序图标右上角的数字
    content.badge = @0;
    //设置有通知时的音效
    UNNotificationSound *sound = [UNNotificationSound defaultSound];
    content.sound = sound;
    
    //设置通知的附件:通知右边的图片
    //将本地图片的路径形成一个图片附件，加入到content中
    //视频
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"flv视频测试用例1" ofType:@"mp4"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"beautiful" ofType:@"png"];
    NSError *error = nil;
    UNNotificationAttachment *img_attachment = [UNNotificationAttachment attachmentWithIdentifier:@"att1" URL:[NSURL fileURLWithPath:path] options:nil error:&error];
    content.attachments = @[img_attachment];
    
    //设置为@""以后，进入app将没有启动页
    content.launchImageName = @"";
    
    //通知的互交类型,Identifier可不是乱写的而是,在注册通知时设置好的
    content.categoryIdentifier = @"seeCategory1";
    //设置额外信息(比如:告诉app点击通知时跳转到哪一个界面)
    content.userInfo = @{@"type" : @1 };
    
    //2. 设置通知触发机制
    //通知触发机制
    //UserNotifications提供了三种触发器：
    //UNTimeIntervalNotificationTrigger：一定时间后触发（若重复提醒，时间间隔要大于60s）
    //UNCalendarNotificationTrigger：在某月某日某时触发
    //UNLocationNotificationTrigger：在用户进入或是离开某个区域时触发
    //UNPushNotificationTrigger: 远程推送
    //设置通知发出的时间
    UNTimeIntervalNotificationTrigger *time_trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    
    //3.创建通知请求
    //创建UNNotificationRequest通知请求对象//创建一个发送请求
    //通知请求标识,便于管理该通知
    NSString *requestIdentifer = @"time interval request";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifer content:content trigger:time_trigger];
    
    //4.将通知请求添加到通知中心
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {}];
}

//常见的通知操作
+(void)operationNotifacation{
    //拿到通知中心
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];//①
    //-移除还未展示的通知
    [center removePendingNotificationRequestsWithIdentifiers: @[@"RequestIdentifier"]];
    //移除所有未展示的通知
    [center removeAllPendingNotificationRequests]; //- (void)cancelAllLocalNotifications；
    
    //-移除已经展示过的通知
    //这里的Identifiers就是你创建通知时设置的,便于管理改通知
    [center removeDeliveredNotificationsWithIdentifiers:@[@"RequestIdentifier"]];
    [center removeAllDeliveredNotifications];
    
    //-获取未展示的通知请求
    [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray * _Nonnull requests) {
        NSLog(@"%@",requests);
    }];
    
    //-获取展示过的通知
    [center getDeliveredNotificationsWithCompletionHandler:^(NSArray * _Nonnull notifications) {
        NSLog(@"%@",notifications);
    }];
}


@end
