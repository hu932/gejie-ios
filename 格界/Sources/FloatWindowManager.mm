#import "FloatWindowManager.h"

@interface FloatWindowManager ()
@property (nonatomic, strong) UIWindow          *floatWindow;
@property (nonatomic, strong) FloatBubbleView   *bubble;
@property (nonatomic, assign) BOOL               visible;
@end

@implementation FloatWindowManager

+ (instancetype)shared {
    static FloatWindowManager *ins;
    static dispatch_once_t t;
    dispatch_once(&t, ^{ ins = [self new]; });
    return ins;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupWindow];
        // 监听计数变更
        [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(onCountUpdated:)
            name:@"GJCountUpdated" object:nil];
    }
    return self;
}

- (void)setupWindow {
    // 独立 UIWindow，使用最高 WindowLevel 保证悬浮在所有 App 之上
    CGRect screen = [UIScreen mainScreen].bounds;

    if (@available(iOS 13.0, *)) {
        // iOS 13+ 需要 windowScene
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                _floatWindow = [[UIWindow alloc] initWithWindowScene:scene];
                break;
            }
        }
    }
    if (!_floatWindow) {
        _floatWindow = [[UIWindow alloc] initWithFrame:screen];
    }

    _floatWindow.windowLevel = UIWindowLevelAlert + 1000;
    _floatWindow.backgroundColor = [UIColor clearColor];
    _floatWindow.userInteractionEnabled = YES;
    _floatWindow.hidden = YES;

    // 需要一个 rootViewController（透明）
    UIViewController *rootVC = [UIViewController new];
    rootVC.view.backgroundColor = [UIColor clearColor];
    rootVC.view.userInteractionEnabled = NO;
    _floatWindow.rootViewController = rootVC;

    // 气泡初始位置：右侧中部
    CGFloat bx = screen.size.width - 60 - 10;
    CGFloat by = screen.size.height * 0.45;
    _bubble = [[FloatBubbleView alloc] initWithFrame:CGRectMake(bx, by, 60, 60)];

    __weak typeof(self) ws = self;
    _bubble.onTap = ^{
        if (ws.onTap) ws.onTap();
    };
    _bubble.onLongPress = ^{
        if (ws.onLongPress) ws.onLongPress();
    };

    [_floatWindow.rootViewController.view addSubview:_bubble];
    _floatWindow.rootViewController.view.userInteractionEnabled = YES;
}

// ─────────────────────────────────────────────
// 公开接口
// ─────────────────────────────────────────────
- (void)show {
    _visible = YES;
    _floatWindow.hidden = NO;
    [_floatWindow makeKeyAndVisible];
    _bubble.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self->_bubble.alpha = 1;
    }];
}

- (void)hide {
    _visible = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self->_bubble.alpha = 0;
    } completion:^(BOOL f) {
        self->_floatWindow.hidden = YES;
    }];
}

- (void)toggle {
    _visible ? [self hide] : [self show];
}

- (void)updateCount:(NSInteger)count {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_bubble updateCount:count];
    });
}

- (void)successPulse {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_bubble pulseAnimation];
    });
}

- (void)setBusy:(BOOL)busy {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_bubble setBusy:busy];
    });
}

- (void)onCountUpdated:(NSNotification *)n {
    NSInteger count = [n.userInfo[@"count"] integerValue];
    [self updateCount:count];
    [self successPulse];
}

@end
