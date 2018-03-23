//
//  README.m
//  ZHRemotePushDemo
//
//  Created by xyj on 2018/3/16.
//  Copyright © 2018年 xyj. All rights reserved.
//


//3. 配置证书
/*
 推送必备条件，必须告诉苹果
 1. 哪个应用(app)需要推送
 2. 在哪台电脑上调试(发布)推送服务
 3. 在哪台设备上调试推送服务
 即: 在哪台电脑上用哪台设备调试那个应用(app)
 
 1. 用你购买的开发者账号，登录苹果的开发者中心
 2. 进入证书中心
 1. 告诉苹果是哪个应用需要推送
 >注册一个appid:进入App IDs->添加->输入你的appid名字(随便起名,比如:ZhonghuaRemoteTest)和你的appID(即bundle identifier)->continue->register->done
 >给你刚才注册的app添加推送服务:进入App IDs->找到你刚才注册的app点击->会看到一个列表,这个列表展示了你的这个app都有哪些服务(通常默认的只有:Game Center和In-App-Purchase这两个服务,绿色表示可用,黄色/没选择表示不可用)->点解编辑(Edit)->勾选你想要的服务->Push Notifications->done
 2.  R: >告诉苹果哪台电脑需要调试这个app: 仍然回到上一步的Edit->找到Push Notifications->Development SSL Certificate->Create ...-> Continue->ChooseFile...
 >这里就是要拿到你的是那一台电脑,即你的电脑的唯一标志(CSR文件)
 >如何生成CSR文件:打开钥匙串-> 顶部工具栏中->钥匙串访问->证书助理->从证书颁发机构请求证书->邮件地址随便写/常用名(随便写)/勾选存储到磁盘-> 确定->保存到桌面即可
 回到第R步: 选择刚才保存的CSR文件-> continue->down即可->得到一个aps_development.cer
 >告诉苹果哪台电脑需要发布这个app:同理,重复第R步...Production SSL Certificate->...得到aps.cer
 3.告诉苹果哪台设备需要调试:
 > 注册设备: 点击加号,将设备添加进去(一般情况下只要你用这个开发者账号调试过真机,他就会自动注册到这里面了)
 > 生成描述文件:
 调试描述文件: 告诉苹果,在哪台电脑上用哪台设备调试那个应用(app)
 发布描述文件: 告诉苹果,在哪台电脑上可以发布哪个应用(app)
 打包测试描述文件ADHoc:(用于蒲公英上传打包使用) 告诉苹果,在哪台电脑上可以打包哪个应用(app),并且那些设备可以下载调试
 从上面的区别就可以看出: 生成调试/打包测试描述文件时,要选择你要调试的设备,生成发布描述文件时不需要选择设备
 调试: 点击provisioning Profiles中的All->添加-> 勾选iOS APP Development-> contuine-> 选择你的APP ID->continue->选着调试证书(注意:这里是调试证书,可不是调试推送证书哦)->选择设备(selectAll)->取一个名字->down即可.
 发布:点击provisioning Profiles中的All->添加-> 勾选 App Store ->contuine-> 选择你的APP ID->continue->选择发布证书(注意:这里是发布证书,可不是发布推送证书哦)->取一个名字->down即可.
 打包:点击provisioning Profiles中的All->添加-> 勾选Ad Hoc -> 选择你的APP ID->continue->选择发布证书(注意:这里是发布证书,可不是发布推送证书哦)->选择设备(selectAll)->取一个名字->down即可
 
 4. 双击安装上面的所有证书(除了CSR)
 5. iOS10 配置(注意啊!!!!!!!!)
 在工程Target中的Push Notifications 的开关要开启！否则死活获取不到token,打开后会发现项目中多了一个"项目名.entitlements"文件夹
 
 此时,应该有8个证书
 1. CSR: mac唯一标志
 2. ios_development.cer 调试证书
 3. ios_distribution.cer 发布证书
 4. aps_development.cer 调试推送证书
 5. aps.cer 发布推送证书
 6. 3个描述文件
 注意: 注意生成调试/发布证书的过程这里就不在多说
 */

