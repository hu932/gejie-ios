#import "LoginViewController.h"
#import "GJTheme.h"
#import "APIClient.h"
#import "TaskViewController.h"

@interface LoginViewController ()
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIButton    *loginButton;
@property (nonatomic, strong) UILabel     *statusLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) CAGradientLayer *bgGradient;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBackground];
    [self setupUI];
    [self animateBackground];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _bgGradient.frame = self.view.bounds;
}

// ─────────────────────────────────────────────
// 动态渐变背景
// ─────────────────────────────────────────────
- (void)setupBackground {
    self.view.backgroundColor = GJ_BG_DARK;

    _bgGradient = [CAGradientLayer layer];
    _bgGradient.frame = self.view.bounds;
    _bgGradient.colors = @[
        (id)[UIColor colorWithRed:0.05 green:0.06 blue:0.15 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.08 green:0.05 blue:0.20 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.03 green:0.08 blue:0.18 alpha:1.0].CGColor,
    ];
    _bgGradient.locations = @[@0, @0.5, @1.0];
    _bgGradient.startPoint = CGPointMake(0, 0);
    _bgGradient.endPoint   = CGPointMake(1, 1);
    [self.view.layer insertSublayer:_bgGradient atIndex:0];

    // 装饰圆圈
    [self addGlowCircle:CGPointMake(self.view.bounds.size.width * 0.15, 120) radius:180 alpha:0.08];
    [self addGlowCircle:CGPointMake(self.view.bounds.size.width * 0.85, 350) radius:220 alpha:0.06];
}

- (void)addGlowCircle:(CGPoint)center radius:(CGFloat)r alpha:(CGFloat)a {
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, r*2, r*2)];
    circle.center = center;
    circle.layer.cornerRadius = r;
    circle.backgroundColor = [UIColor colorWithRed:0.25 green:0.40 blue:0.98 alpha:a];
    [self.view addSubview:circle];
}

- (void)animateBackground {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"colors"];
    anim.toValue = @[
        (id)[UIColor colorWithRed:0.06 green:0.08 blue:0.22 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.10 green:0.04 blue:0.18 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.04 green:0.10 blue:0.20 alpha:1.0].CGColor,
    ];
    anim.duration = 6.0;
    anim.autoreverses = YES;
    anim.repeatCount = INFINITY;
    [_bgGradient addAnimation:anim forKey:@"bgAnim"];
}

// ─────────────────────────────────────────────
// UI 布局
// ─────────────────────────────────────────────
- (void)setupUI {
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;
    CGFloat cx = W / 2;

    // ── Logo 区域
    UIView *logoWrap = [[UIView alloc] initWithFrame:CGRectMake(0, H*0.12, W, 100)];
    [self.view addSubview:logoWrap];

    // 图标背景圆
    UIView *iconBg = [[UIView alloc] initWithFrame:CGRectMake(cx-32, 0, 64, 64)];
    iconBg.layer.cornerRadius = 32;
    iconBg.layer.masksToBounds = YES;
    CAGradientLayer *iconGrad = [GJTheme primaryGradientLayerWithFrame:iconBg.bounds];
    [iconBg.layer addSublayer:iconGrad];
    [logoWrap addSubview:iconBg];

    UILabel *iconLabel = [[UILabel alloc] initWithFrame:iconBg.bounds];
    iconLabel.text = @"格";
    iconLabel.textAlignment = NSTextAlignmentCenter;
    iconLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    iconLabel.textColor = [UIColor whiteColor];
    [iconBg addSubview:iconLabel];

    UILabel *appName = [[UILabel alloc] initWithFrame:CGRectMake(0, 72, W, 28)];
    appName.text = @"格 界";
    appName.textAlignment = NSTextAlignmentCenter;
    appName.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    appName.textColor = GJ_TEXT_PRIMARY;
    // 字间距
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"格 界"];
    [attr addAttribute:NSKernAttributeName value:@8 range:NSMakeRange(0, attr.length)];
    appName.attributedText = attr;
    [logoWrap addSubview:appName];

    UILabel *slogan = [[UILabel alloc] initWithFrame:CGRectMake(0, 106, W, 20)];
    slogan.text = @"智能任务助手";
    slogan.textAlignment = NSTextAlignmentCenter;
    slogan.font = GJ_FONT_SMALL;
    slogan.textColor = GJ_TEXT_MUTED;
    [logoWrap addSubview:slogan];

    // ── 登录卡片（毛玻璃）
    CGFloat cardW = MIN(W - 40, 360);
    CGFloat cardX = (W - cardW) / 2;
    CGFloat cardY = H * 0.38;

    UIVisualEffectView *card = [GJTheme blurCardWithFrame:CGRectMake(cardX, cardY, cardW, 280)
                                                   radius:GJ_RADIUS_XL];
    [self.view addSubview:card];

    CGFloat pw = cardW - 40;
    CGFloat px = 20;

    // 卡片标题
    UILabel *cardTitle = [[UILabel alloc] initWithFrame:CGRectMake(px, 24, pw, 24)];
    cardTitle.text = @"账号登录";
    cardTitle.font = GJ_FONT_SUBTITLE;
    cardTitle.textColor = GJ_TEXT_PRIMARY;
    [card.contentView addSubview:cardTitle];

    UIView *titleLine = [[UIView alloc] initWithFrame:CGRectMake(px, 52, 32, 2)];
    titleLine.layer.cornerRadius = 1;
    titleLine.backgroundColor = GJ_PRIMARY;
    CAGradientLayer *lineGrad = [GJTheme accentGradientLayerWithFrame:titleLine.bounds];
    [titleLine.layer addSublayer:lineGrad];
    [card.contentView addSubview:titleLine];

    // 用户名输入框
    _usernameField = [[UITextField alloc] initWithFrame:CGRectMake(px, 72, pw, 48)];
    [GJTheme styleTextField:_usernameField placeholder:@"  用户名 / 账号"];
    _usernameField.returnKeyType = UIReturnKeyNext;
    _usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    _usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    // 前置图标
    [self addIconToField:_usernameField iconText:@"👤"];
    // 恢复上次用户名
    NSString *saved = [[NSUserDefaults standardUserDefaults] objectForKey:kUsernameKey];
    if (saved.length > 0) _usernameField.text = saved;
    [card.contentView addSubview:_usernameField];

    // 密码输入框
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(px, 132, pw, 48)];
    [GJTheme styleTextField:_passwordField placeholder:@"  密码"];
    _passwordField.secureTextEntry = YES;
    _passwordField.returnKeyType = UIReturnKeyDone;
    [self addIconToField:_passwordField iconText:@"🔒"];
    [card.contentView addSubview:_passwordField];

    // 登录按钮
    _loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _loginButton.frame = CGRectMake(px, 200, pw, 50);
    [GJTheme applyPrimaryStyle:_loginButton];
    [_loginButton setTitle:@"登  录" forState:UIControlStateNormal];
    NSMutableAttributedString *btnAttr = [[NSMutableAttributedString alloc]
        initWithString:@"登  录"
        attributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold],
            NSForegroundColorAttributeName: [UIColor whiteColor],
            NSKernAttributeName: @4,
        }];
    [_loginButton setAttributedTitle:btnAttr forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];
    [card.contentView addSubview:_loginButton];

    // 加载转圈
    _spinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    _spinner.color = [UIColor whiteColor];
    _spinner.center = CGPointMake(cardW/2, 225);
    _spinner.hidesWhenStopped = YES;
    [card.contentView addSubview:_spinner];

    // 状态文字
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(px, 256, pw, 20)];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    _statusLabel.font = GJ_FONT_SMALL;
    _statusLabel.textColor = GJ_DANGER;
    [card.contentView addSubview:_statusLabel];

    // ── 底部版本
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(0, H-50, W, 20)];
    version.text = @"格界 v1.0.0  •  智能任务平台";
    version.textAlignment = NSTextAlignmentCenter;
    version.font = GJ_FONT_CAPTION;
    version.textColor = GJ_TEXT_MUTED;
    [self.view addSubview:version];

    // 点击空白收键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)addIconToField:(UITextField *)tf iconText:(NSString *)icon {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 42, 48)];
    lbl.text = icon;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font = [UIFont systemFontOfSize:16];
    tf.leftView = lbl;
    tf.leftViewMode = UITextFieldViewModeAlways;
}

// ─────────────────────────────────────────────
// 登录操作
// ─────────────────────────────────────────────
- (void)doLogin {
    NSString *user = [_usernameField.text stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceCharacterSet]];
    NSString *pass = [_passwordField.text stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceCharacterSet]];

    if (user.length == 0 || pass.length == 0) {
        [self showStatus:@"请输入用户名和密码" color:GJ_WARNING];
        return;
    }

    [self setLoading:YES];
    _statusLabel.text = @"";

    [[APIClient shared] loginWithUsername:user password:pass completion:^(NSString *token, NSString *error) {
        [self setLoading:NO];
        if (token) {
            [self showStatus:@"✓ 登录成功" color:GJ_SUCCESS];
            [self performSelector:@selector(goToMain) withObject:nil afterDelay:0.5];
        } else {
            [self showStatus:error ?: @"登录失败" color:GJ_DANGER];
            // 抖动动画
            [self shakeView:self->_passwordField];
        }
    }];
}

- (void)goToMain {
    TaskViewController *vc = [TaskViewController new];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)setLoading:(BOOL)loading {
    _loginButton.hidden = loading;
    loading ? [_spinner startAnimating] : [_spinner stopAnimating];
    _usernameField.enabled = !loading;
    _passwordField.enabled = !loading;
}

- (void)showStatus:(NSString *)msg color:(UIColor *)color {
    _statusLabel.text = msg;
    _statusLabel.textColor = color;
}

- (void)shakeView:(UIView *)view {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    anim.duration = 0.5;
    anim.values = @[@(-10), @(10), @(-8), @(8), @(-5), @(5), @0];
    [view.layer addAnimation:anim forKey:@"shake"];
}

- (void)dismissKeyboard { [self.view endEditing:YES]; }

@end
