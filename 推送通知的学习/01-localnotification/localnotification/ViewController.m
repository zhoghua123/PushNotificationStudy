//
//  ViewController.m
//  localnotification
//
//  Created by xyj on 17/2/9.
//  Copyright © 2017年 xyj. All rights reserved.
//
#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,assign) NSInteger number;
@end

@implementation ViewController


//延迟5秒发送本地通知
- (IBAction)locationNotificationAction:(id)sender {
    //1.创建本地通知
    UILocalNotification * localNote = [[UILocalNotification alloc] init];
    //2.设置本地通知内容
    //2.1设置通知发出的时间
    localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:5.0];
    //2.2 设置通知的内容
    localNote.alertBody = @"吃饭了吗???";
    //2.3 设置滑块的文字
    localNote.alertAction = @"快点";
    //2.4 决定alertAction是否生效
    localNote.hasAction = YES;
    //2.5 设置点击通知的启动图片(随便写)
    localNote.alertLaunchImage = @"随便写";
    //2.6 设置alertTitle
    localNote.alertTitle = @"777777777777";
    //2.7 设置有通知时的音效
//    localNote.soundName = @"buyao.wav";
    //也可以用系统自带的
    localNote.soundName = UILocalNotificationDefaultSoundName;
    //2.8 设置应用程序图标右上角的数字
    localNote.applicationIconBadgeNumber = self.number++;
    //2.9 设置额外信息(比如:告诉app点击通知时跳转到哪一个界面)
    localNote.userInfo = @{@"type" : @1 };
    
    //3.调用本地通知
    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
}

@end
