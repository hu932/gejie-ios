/*
 * MyTweak - 示例 Tweak 插件
 * 功能：在状态栏显示自定义文字 + Hook SpringBoard
 *
 * Logos 语法说明：
 *   %hook  ClassName   - Hook 某个类
 *   %orig              - 调用原始方法
 *   %new               - 添加新方法
 *   %end               - 结束 hook 块
 *   %ctor              - 构造函数（加载时执行）
 *   %dtor              - 析构函数（卸载时执行）
 */

#import <UIKit/UIKit.h>
#import <substrate.h>

// ─────────────────────────────────────────────
// 示例1：Hook SpringBoard 锁屏时弹出提示
// ─────────────────────────────────────────────
%hook SpringBoard

- (void)lockDevice {
    // 先执行原方法
    %orig;

    // 执行完锁屏后弹出提示（示例）
    NSLog(@"[MyTweak] 设备已锁屏");
}

%end


// ─────────────────────────────────────────────
// 示例2：Hook UIApplication，监听进入后台
// ─────────────────────────────────────────────
%hook UIApplication

- (void)applicationDidEnterBackground:(UIApplication *)application {
    %orig;
    NSLog(@"[MyTweak] App 进入后台");
}

%end


// ─────────────────────────────────────────────
// 示例3：Hook 某个 App（以微信为例）
// 修改导航栏标题文字
// ─────────────────────────────────────────────

// 先用 %group 把针对特定 App 的 Hook 分组
%group WeChat

%hook UINavigationItem

- (void)setTitle:(NSString *)title {
    // 在原标题后加标记（仅演示）
    if (title && title.length > 0) {
        NSString *newTitle = [NSString stringWithFormat:@"%@ ✦", title];
        %orig(newTitle);
    } else {
        %orig;
    }
}

%end

%end // group WeChat


// ─────────────────────────────────────────────
// 示例4：%new 添加新方法到已有类
// ─────────────────────────────────────────────
%hook UIViewController

// 给 UIViewController 添加一个全新的方法
%new
- (void)myTweak_showBanner:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"MyTweak"
            message:message
            preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *ok = [UIAlertAction
            actionWithTitle:@"OK"
            style:UIAlertActionStyleDefault
            handler:nil];

        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

%end


// ─────────────────────────────────────────────
// 构造函数：Tweak 加载时执行
// ─────────────────────────────────────────────
%ctor {
    NSLog(@"[MyTweak] ✅ Tweak 已加载");

    // 根据当前进程名决定是否激活分组
    NSString *processName = [NSProcessInfo processInfo].processName;

    if ([processName isEqualToString:@"WeChat"]) {
        NSLog(@"[MyTweak] 激活微信专属 Hook");
        %init(WeChat);
    }

    // 全局 Hook 直接 init
    %init;
}

%dtor {
    NSLog(@"[MyTweak] Tweak 已卸载");
}
