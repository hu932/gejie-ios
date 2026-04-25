#import "AppDelegate.h"
#import "GJTheme.h"
#import "APIClient.h"
#import "LoginViewController.h"
#import "TaskViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // ── 全局外观
    [self applyGlobalAppearance];

    // ── 窗口
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = GJ_BG_DARK;

    // ── 判断是否已登录
    BOOL hasToken = [[APIClient shared] loadSavedCredentials];
    UIViewController *rootVC;

    if (hasToken) {
        rootVC = [TaskViewController new];
    } else {
        rootVC = [LoginViewController new];
    }

    // ── 启动加载（Logo 动画）
    UIViewController *splash = [self makeSplashVC:rootVC];
    self.window.rootViewController = splash;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applyGlobalAppearance {
    // NavigationBar
    UINavigationBarAppearance *navApp = [UINavigationBarAppearance new];
    [navApp configureWithOpaqueBackground];
    navApp.backgroundColor = GJ_BG_CARD;
    navApp.titleTextAttributes = @{
        NSForegroundColorAttributeName: GJ_TEXT_PRIMARY,
        NSFontAttributeName: GJ_FONT_SUBTITLE,
    };
    navApp.largeTitleTextAttributes = @{
        NSForegroundColorAttributeName: GJ_TEXT_PRIMARY,
    };
    UINavigationBar.appearance.standardAppearance = navApp;
    UINavigationBar.appearance.scrollEdgeAppearance = navApp;
    UINavigationBar.appearance.tintColor = GJ_PRIMARY;

    // StatusBar
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

// 启动画面
- (UIViewController *)makeSplashVC:(UIViewController *)nextVC {
    UIViewController *splash = [UIViewController new];
    splash.view.backgroundColor = GJ_BG_DARK;

    CGFloat W = [UIScreen mainScreen].bounds.size.width;
    CGFloat H = [UIScreen mainScreen].bounds.size.height;

    // 背景渐变
    CAGradientLayer *bg = [GJTheme primaryGradientLayerWithFrame:CGRectMake(0,0,W,H)];
    bg.colors = @[
        (id)[UIColor colorWithRed:0.04 green:0.05 blue:0.12 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.08 green:0.04 blue:0.18 alpha:1.0].CGColor,
    ];
    [splash.view.layer addSublayer:bg];

    // 图标
    UIView *iconBg = [[UIView alloc] initWithFrame:CGRectMake(W/2-48, H/2-80, 96, 96)];
    iconBg.layer.cornerRadius = 24;
    iconBg.layer.masksToBounds = YES;
    CAGradientLayer *iconG = [GJTheme primaryGradientLayerWithFrame:iconBg.bounds];
    [iconBg.layer addSublayer:iconG];
    [splash.view addSubview:iconBg];

    UILabel *icon = [[UILabel alloc] initWithFrame:iconBg.bounds];
    icon.text = @"格";
    icon.textAlignment = NSTextAlignmentCenter;
    icon.font = [UIFont systemFontOfSize:44 weight:UIFontWeightBold];
    icon.textColor = [UIColor whiteColor];
    [iconBg addSubview:icon];

    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, H/2+28, W, 36)];
    NSMutableAttributedString *a = [[NSMutableAttributedString alloc] initWithString:@"格 界"];
    [a addAttribute:NSKernAttributeName value:@10 range:NSMakeRange(0, a.length)];
    [a addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:28 weight:UIFontWeightBold]
              range:NSMakeRange(0, a.length)];
    [a addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]
              range:NSMakeRange(0, a.length)];
    name.attributedText = a;
    name.textAlignment = NSTextAlignmentCenter;
    [splash.view addSubview:name];

    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(0, H/2+68, W, 20)];
    sub.text = @"智能任务助手";
    sub.textAlignment = NSTextAlignmentCenter;
    sub.font = GJ_FONT_SMALL;
    sub.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    [splash.view addSubview:sub];

    // 1.5秒后切换
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.window
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
            self.window.rootViewController = nextVC;
        } completion:nil];
    });

    return splash;
}

- (UIApplication *)application { return [UIApplication sharedApplication]; }

@end
