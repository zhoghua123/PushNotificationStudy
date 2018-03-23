//
//  NotificationViewController.m
//  ContentExtension
//
//  Created by xyj on 2018/3/22.
//  Copyright © 2018年 xyj. All rights reserved.
//
/*
 操作
 1.开启当前target的Capability->Push Notification。
 2. 配置info.plist的NSExtensionAttributes
 UNNotificationExtensionCategory:
 必须设置
 1.如果你的应用互交类型只有一种,就不需要改类型了,直接输入你的Identifier
 2.否则,将类型修改为array,然后根据你在appdelete中设置的互交类型个数添加成员,如果没做这一步,就不会走这个contentExtension
 3. 变化情况,当下拉通知时,会看到之前内容框显示的是通知内容的附件:attchment,但是现在被MainInterface这个SB替换掉了
 UNNotificationExtensionDefaultContentHidden bool YES/NO
 可以不设置,默认为NO
 1. 作用: 控制系统的原消息是否显示,YES:只显示自定义的那块. NO: 自定义和系统原消息都显示
 UNNotificationExtensionOverridesDefaultTitle bool YES/NO
 可以不设置,默认为NO
 1. 功能: 是否覆盖默认的标题 YES:会使用NotificationViewController.title,但是不能在viewDidLoad中设置,要在didReceiveNotification中设置.
 NO: 默认是应用的名称
 
 */

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *bodyTitle;
@property (weak, nonatomic) IBOutlet UIImageView *contentImage;
@property (weak, nonatomic) IBOutlet UILabel *responseLabel;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _bodyTitle.numberOfLines = 0;
    _bodyTitle.preferredMaxLayoutWidth = 100;
    //添加子控件
    
}
    //调用时刻:扩展通知将要展示的时候,即下拉推送通知之前
- (void)didReceiveNotification:(UNNotification *)notification {
    //修改大标题
    self.title = @"我修改了通知标题";
    UNNotificationContent *content = notification.request.content;
    _titleLabel.text = content.title;
    _subtitleLabel.text = content.subtitle;
    _bodyTitle.text = content.body;
    //显示附件内容
    UNNotificationAttachment * attachment = notification.request.content.attachments.firstObject;
    if (attachment) {
        //开始访问pushStore的存储权限
        [attachment.URL startAccessingSecurityScopedResource];
        NSData * data = [NSData dataWithContentsOfFile:attachment.URL.path];
        [attachment.URL stopAccessingSecurityScopedResource];
        self.contentImage.image = [UIImage imageWithData:data];
    }
}
- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption option))completion{
    if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
        UNTextInputNotificationResponse * xxx =(UNTextInputNotificationResponse *)response;
        //处理提交文本的逻辑
        self.responseLabel.text = [NSString stringWithFormat:@"用户输入了:%@",xxx.userText];
    }
    if ([response.actionIdentifier isEqualToString:@"see1"]) {
        //处理按钮3
        self.responseLabel.text = @"用户点击了看一看";
        //不能直接调用,因为app项目和ContentExtension不公用一个主资源包
        //ContentExtension用的资源必须单独拖到这个target中,如图
        self.contentImage.image = [UIImage imageNamed:@"beautiful12.png"];
    }
    if ([response.actionIdentifier isEqualToString:@"see2"]) {
        //处理按钮2
        self.responseLabel.text = @"用户点击了忽略";
        self.contentImage.image = [UIImage imageNamed:@"image11.png"];
    }
    //可根据action的逻辑回调的时候传入不同的UNNotificationContentExtensionResponseOption
    /*
     UNNotificationContentExtensionResponseOptionDoNotDismiss:保持通知继续被显示
     UNNotificationContentExtensionResponseOptionDismiss: 直接解散这个通知
     UNNotificationContentExtensionResponseOptionDismissAndForwardAction:
     将通知的action继续传递给应用的UNUserNotificationCenterDelegate中的- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler函数继续处理。
     */
    completion(UNNotificationContentExtensionResponseOptionDismiss);
}

/*******多媒体相关*********/
// 返回默认样式的button
- (UNNotificationContentExtensionMediaPlayPauseButtonType)mediaPlayPauseButtonType{
    return UNNotificationContentExtensionMediaPlayPauseButtonTypeDefault;
}
// 返回button的frame
- (CGRect)mediaPlayPauseButtonFrame{
    return CGRectMake(100, 100, 100, 100);
}
// 返回button的颜色
- (UIColor *)mediaPlayPauseButtonTintColor{
    return [UIColor blueColor];
}
//- (void)mediaPlay{
//    NSLog(@"mediaPlay,开始播放");
//
//}
//- (void)mediaPause{
//    NSLog(@"mediaPause，暂停播放");
//}
- (void)mediaPlay{
    NSLog(@"mediaPlay,开始播放");
    // 点击播放按钮后，4s后暂停播放
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.extensionContext mediaPlayingPaused];
    });
}
- (void)mediaPause{
    NSLog(@"mediaPause，暂停播放");
    // 点击暂停按钮，10s后开始播放
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.extensionContext mediaPlayingStarted];
    });
}
@end
