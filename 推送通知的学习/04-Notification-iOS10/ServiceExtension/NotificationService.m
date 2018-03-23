//
//  NotificationService.m
//  ServiceExtension
//
//  Created by xyj on 2018/3/21.
//  Copyright © 2018年 xyj. All rights reserved.
//
/*
 使用注意:
 1. info.plist添加
 <key>NSAppTransportSecurity</key>
 <dict>
 <key>NSAllowsArbitraryLoads</key>
 <true/>
 </dict>
 2. 开启当前target的Capability->Push Notification。
 */
#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

/**
 你需要通过重写这个方法，来重写你的通知内容，也可以在这里下载附件内容
 如果在服务的时间过期之前没有调用该contentHandler，则将发送未修改的通知。
 @param request 拿到apns推送的请求
 @param contentHandler 交付修改后的推送内容
 */
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
     // copy发来的通知，开始做一些处理
    self.bestAttemptContent = [request.content mutableCopy];
    
    // 在这里修改通知的内容
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    // 重写一些东西
    self.bestAttemptContent.title = @"我是修改后的标题";
    self.bestAttemptContent.subtitle = @"我是修改后的子标题";
    self.bestAttemptContent.body = @"这里是修改后的推送内容";
    NSLog(@"----------------------");
    // 附件
    NSDictionary *dict =  self.bestAttemptContent.userInfo;
    NSDictionary *notiDict = dict[@"aps"];
    //拿到图片的url
    NSString *imgUrl = [NSString stringWithFormat:@"%@",notiDict[@"imageAbsoluteString"]];
    // 这里添加一些点击事件，可以在收到通知的时候，添加，也可以在拦截通知的这个扩展中添加
    self.bestAttemptContent.categoryIdentifier = @"seeCategory";
    //没有资源就结束
    if (!imgUrl.length) {
        self.contentHandler(self.bestAttemptContent);
    }
    //下载图片
    [self loadAttachmentForUrlString:imgUrl withType:@"image" completionHandle:^(UNNotificationAttachment *attach) {
        if (attach) {
            self.bestAttemptContent.attachments = [NSArray arrayWithObject:attach];
        }
        self.contentHandler(self.bestAttemptContent);
    }];
}

/**
 调用时刻: 扩展即将结束的时候调用
 bestAttemptContent是你修改后的通知内容,如果没有修改完毕,那么就回使用原始的推送.
 即: 如果处理时间太长，等不及处理了，就会把收到的apns直接展示出来
 也就是说等到一定的时间,上面的方法还没有调用contentHandler,那就执行这个方法
 */
- (void)serviceExtensionTimeWillExpire {
    self.contentHandler(self.bestAttemptContent);
}
     
//这是下载附件通知的方法:
- (void)loadAttachmentForUrlString:(NSString *)urlStr
                        withType:(NSString *)type
                completionHandle:(void(^)(UNNotificationAttachment *attach))completionHandler{
    
    
    __block UNNotificationAttachment *attachment = nil;
    NSURL *attachmentURL = [NSURL URLWithString:urlStr];
    NSString *fileExt = [self fileExtensionForMediaType:type];
    //根据url下载数据到本地
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session downloadTaskWithURL:attachmentURL
                completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
                    if (error != nil) {
                        NSLog(@"%@", error.localizedDescription);
                    } else {
                        //将下载的文件存储到本地
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
                        [fileManager moveItemAtURL:temporaryFileLocation toURL:localURL error:&error];
                        
                        NSError *attachmentError = nil;
                        //创建附件
                        attachment = [UNNotificationAttachment attachmentWithIdentifier:@"" URL:localURL options:nil error:&attachmentError];
                        if (attachmentError) {
                            NSLog(@"%@", attachmentError.localizedDescription);
                        }
                    }
                    //返回附件
                    completionHandler(attachment);
                }] resume];
}

//判断文件类型的方法(很多情况下是服务器发送数据类型)
- (NSString *)fileExtensionForMediaType:(NSString *)type {
    NSString *ext = type;
    if ([type isEqualToString:@"image"]) {
        ext = @"jpg";
    }
    if ([type isEqualToString:@"video"]) {
        ext = @"mp4";
    }
    if ([type isEqualToString:@"audio"]) {
        ext = @"mp3";
    }
    return [@"." stringByAppendingString:ext];
}

@end
