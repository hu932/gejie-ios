#import "TaskViewController.h"
#import "GJTheme.h"
#import "APIClient.h"
#import "FloatWindowManager.h"
#import "TaskDetailViewController.h"

// ─────────────────────────────────────────────
// 任务状态枚举
// ─────────────────────────────────────────────
typedef NS_ENUM(NSInteger, GJTaskState) {
    GJTaskStateIdle,        // 空闲
    GJTaskStateFetching,    // 获取任务中
    GJTaskStateGotTask,     // 已获取任务
    GJTaskStateJumped,      // 已跳转App
    GJTaskStateFetchingProduct, // 获取商品中
    GJTaskStateSubmitting,  // 提交中
    GJTaskStateDone,        // 完成
};

@interface TaskViewController () <UITableViewDataSource, UITableViewDelegate>

// 状态
@property (nonatomic, assign) GJTaskState state;
@property (nonatomic, strong) NSDictionary *currentTask;
@property (nonatomic, strong) NSDictionary *currentProduct;
@property (nonatomic, strong) NSMutableArray *taskHistory;

// UI
@property (nonatomic, strong) UIView        *headerView;
@property (nonatomic, strong) UILabel       *countLabel;
@property (nonatomic, strong) UILabel       *stateLabel;
@property (nonatomic, strong) UIView        *taskCard;
@property (nonatomic, strong) UILabel       *taskTitleLabel;
@property (nonatomic, strong) UILabel       *taskURLLabel;
@property (nonatomic, strong) UILabel       *taskInfoLabel;
@property (nonatomic, strong) UIView        *productCard;
@property (nonatomic, strong) UILabel       *productNameLabel;
@property (nonatomic, strong) UILabel       *productPriceLabel;
@property (nonatomic, strong) UILabel       *productRatingLabel;
@property (nonatomic, strong) UIButton      *mainActionButton;
@property (nonatomic, strong) UIButton      *secondaryButton;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UITableView   *historyTable;
@property (nonatomic, strong) CAGradientLayer *btnGradient;

@end

@implementation TaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = GJ_BG_DARK;
    _taskHistory = [NSMutableArray array];
    [self setupBackground];
    [self setupUI];
    [self setupFloatWindow];
    [self updateStateUI:GJTaskStateIdle];
}

// ─────────────────────────────────────────────
// 背景
// ─────────────────────────────────────────────
- (void)setupBackground {
    CAGradientLayer *bg = [CAGradientLayer layer];
    bg.frame = self.view.bounds;
    bg.colors = @[
        (id)[UIColor colorWithRed:0.05 green:0.06 blue:0.12 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.07 green:0.05 blue:0.16 alpha:1.0].CGColor,
    ];
    bg.startPoint = CGPointMake(0, 0);
    bg.endPoint   = CGPointMake(1, 1);
    [self.view.layer insertSublayer:bg atIndex:0];
}

// ─────────────────────────────────────────────
// 主界面布局
// ─────────────────────────────────────────────
- (void)setupUI {
    CGFloat W = self.view.bounds.size.width;
    CGFloat safeTop = self.view.safeAreaInsets.top > 0 ? self.view.safeAreaInsets.top : 44;

    // ── 顶部导航栏
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, safeTop + 56)];
    navBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:navBar];

    // 毛玻璃
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
    UIVisualEffectView *blurV = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurV.frame = navBar.bounds;
    [navBar addSubview:blurV];

    // Logo
    UILabel *logo = [[UILabel alloc] initWithFrame:CGRectMake(20, safeTop + 12, 120, 30)];
    logo.text = @"格 界";
    NSMutableAttributedString *a = [[NSMutableAttributedString alloc] initWithString:@"格 界"];
    [a addAttribute:NSKernAttributeName value:@6 range:NSMakeRange(0, a.length)];
    [a addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20 weight:UIFontWeightBold]
              range:NSMakeRange(0, a.length)];
    [a addAttribute:NSForegroundColorAttributeName value:GJ_TEXT_PRIMARY range:NSMakeRange(0, a.length)];
    logo.attributedText = a;
    [navBar addSubview:logo];

    // 完成计数
    UIView *countBadge = [[UIView alloc] initWithFrame:CGRectMake(W-120, safeTop+10, 100, 34)];
    countBadge.layer.cornerRadius = 17;
    countBadge.backgroundColor = GJ_BG_CARD;
    countBadge.layer.borderWidth = 1;
    countBadge.layer.borderColor = GJ_BORDER.CGColor;
    [navBar addSubview:countBadge];

    UILabel *countIcon = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 24, 34)];
    countIcon.text = @"✓";
    countIcon.textAlignment = NSTextAlignmentCenter;
    countIcon.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    countIcon.textColor = GJ_SUCCESS;
    [countBadge addSubview:countIcon];

    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 62, 34)];
    _countLabel.text = @"已完成 0";
    _countLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    _countLabel.textColor = GJ_TEXT_PRIMARY;
    [countBadge addSubview:_countLabel];

    // 退出按钮
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    logoutBtn.frame = CGRectMake(W-46, safeTop+13, 26, 26);
    [logoutBtn setImage:[UIImage systemImageNamed:@"rectangle.portrait.and.arrow.right"]
               forState:UIControlStateNormal];
    logoutBtn.tintColor = GJ_TEXT_MUTED;
    [logoutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    // 注：这个位置留给将来调整

    // ── 滚动内容区
    CGFloat scrollTop = safeTop + 56 + 12;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, scrollTop, W, self.view.bounds.size.height - scrollTop - 200)];
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];

    CGFloat cw = W - 32;
    CGFloat cy = 0;

    // ── 状态横幅
    UIView *stateBanner = [[UIView alloc] initWithFrame:CGRectMake(16, cy, cw, 60)];
    stateBanner.backgroundColor = GJ_BG_CARD;
    stateBanner.layer.cornerRadius = GJ_RADIUS_MD;
    stateBanner.layer.borderWidth = 1;
    stateBanner.layer.borderColor = GJ_BORDER.CGColor;
    [_scrollView addSubview:stateBanner];

    _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, cw-32, 60)];
    _stateLabel.font = GJ_FONT_BODY;
    _stateLabel.textColor = GJ_TEXT_SECONDARY;
    _stateLabel.numberOfLines = 2;
    [stateBanner addSubview:_stateLabel];

    _spinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    _spinner.color = GJ_PRIMARY;
    _spinner.center = CGPointMake(cw - 30, 30);
    _spinner.hidesWhenStopped = YES;
    [stateBanner addSubview:_spinner];
    cy += 72;

    // ── 任务信息卡
    _taskCard = [self makeCard:CGRectMake(16, cy, cw, 120) title:@"任务信息" icon:@"📋"];
    _taskCard.hidden = YES;
    [_scrollView addSubview:_taskCard];

    _taskTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 52, cw-32, 20)];
    _taskTitleLabel.font = GJ_FONT_SUBTITLE;
    _taskTitleLabel.textColor = GJ_TEXT_PRIMARY;
    [_taskCard addSubview:_taskTitleLabel];

    _taskURLLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 76, cw-32, 16)];
    _taskURLLabel.font = GJ_FONT_SMALL;
    _taskURLLabel.textColor = GJ_ACCENT;
    _taskURLLabel.numberOfLines = 1;
    [_taskCard addSubview:_taskURLLabel];

    _taskInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 96, cw-32, 16)];
    _taskInfoLabel.font = GJ_FONT_CAPTION;
    _taskInfoLabel.textColor = GJ_TEXT_MUTED;
    [_taskCard addSubview:_taskInfoLabel];
    cy += 132;

    // ── 商品信息卡
    _productCard = [self makeCard:CGRectMake(16, cy, cw, 130) title:@"商品详情" icon:@"🛍"];
    _productCard.hidden = YES;
    [_scrollView addSubview:_productCard];

    _productNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 52, cw-32, 36)];
    _productNameLabel.font = GJ_FONT_BODY;
    _productNameLabel.textColor = GJ_TEXT_PRIMARY;
    _productNameLabel.numberOfLines = 2;
    [_productCard addSubview:_productNameLabel];

    _productPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 94, 150, 22)];
    _productPriceLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    _productPriceLabel.textColor = GJ_WARNING;
    [_productCard addSubview:_productPriceLabel];

    _productRatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(cw-130, 94, 114, 22)];
    _productRatingLabel.font = GJ_FONT_CAPTION;
    _productRatingLabel.textColor = GJ_TEXT_SECONDARY;
    _productRatingLabel.textAlignment = NSTextAlignmentRight;
    [_productCard addSubview:_productRatingLabel];
    cy += 142;

    // ── 历史记录
    UIView *histCard = [self makeCard:CGRectMake(16, cy, cw, 180) title:@"完成记录" icon:@"📊"];
    [_scrollView addSubview:histCard];

    _historyTable = [[UITableView alloc]
        initWithFrame:CGRectMake(0, 46, cw, 130) style:UITableViewStylePlain];
    _historyTable.backgroundColor = [UIColor clearColor];
    _historyTable.separatorColor = GJ_BORDER;
    _historyTable.dataSource = self;
    _historyTable.delegate = self;
    _historyTable.scrollEnabled = YES;
    [histCard addSubview:_historyTable];
    cy += 192;

    _scrollView.contentSize = CGSizeMake(W, cy + 20);

    // ── 底部操作区（固定）
    [self setupBottomActions];
}

- (UIView *)makeCard:(CGRect)frame title:(NSString *)title icon:(NSString *)icon {
    UIView *card = [[UIView alloc] initWithFrame:frame];
    card.backgroundColor = GJ_BG_CARD;
    card.layer.cornerRadius = GJ_RADIUS_MD;
    card.layer.borderWidth = 1;
    card.layer.borderColor = GJ_BORDER.CGColor;

    UILabel *hdr = [[UILabel alloc] initWithFrame:CGRectMake(16, 14, frame.size.width-32, 20)];
    hdr.text = [NSString stringWithFormat:@"%@  %@", icon, title];
    hdr.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    hdr.textColor = GJ_TEXT_MUTED;
    [card addSubview:hdr];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 38, frame.size.width-32, 0.5)];
    line.backgroundColor = GJ_BORDER;
    [card addSubview:line];

    return card;
}

// ─────────────────────────────────────────────
// 底部操作按钮
// ─────────────────────────────────────────────
- (void)setupBottomActions {
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;
    CGFloat safeBot = self.view.safeAreaInsets.bottom > 0 ? self.view.safeAreaInsets.bottom : 20;

    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, H-safeBot-130, W, safeBot+130)];
    bottomBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
    UIVisualEffectView *blurV = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurV.frame = bottomBar.bounds;
    [bottomBar addSubview:blurV];

    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, 0.5)];
    topLine.backgroundColor = GJ_BORDER;
    [bottomBar addSubview:topLine];

    [self.view addSubview:bottomBar];

    CGFloat bw = (W - 48) / 2;

    // 主操作按钮（大）
    _mainActionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _mainActionButton.frame = CGRectMake(16, 14, W-32, 52);
    _mainActionButton.layer.cornerRadius = GJ_RADIUS_MD;
    _mainActionButton.layer.masksToBounds = YES;
    [GJTheme applyPrimaryStyle:_mainActionButton];
    [_mainActionButton addTarget:self action:@selector(mainAction)
                forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:_mainActionButton];

    // 辅助按钮
    _secondaryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _secondaryButton.frame = CGRectMake(16, 74, W-32, 44);
    _secondaryButton.layer.cornerRadius = GJ_RADIUS_SM;
    _secondaryButton.backgroundColor = GJ_BG_CARD;
    _secondaryButton.layer.borderWidth = 1;
    _secondaryButton.layer.borderColor = GJ_BORDER.CGColor;
    [_secondaryButton setTitle:@"跳过此任务" forState:UIControlStateNormal];
    [_secondaryButton setTitleColor:GJ_TEXT_SECONDARY forState:UIControlStateNormal];
    _secondaryButton.titleLabel.font = GJ_FONT_BODY;
    _secondaryButton.hidden = YES;
    [_secondaryButton addTarget:self action:@selector(skipTask)
                forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:_secondaryButton];
}

// ─────────────────────────────────────────────
// 悬浮窗
// ─────────────────────────────────────────────
- (void)setupFloatWindow {
    FloatWindowManager *mgr = [FloatWindowManager shared];
    [mgr show];

    __weak typeof(self) ws = self;
    mgr.onTap = ^{
        // 点击悬浮窗：快速执行当前流程下一步
        [ws mainAction];
    };
    mgr.onLongPress = ^{
        // 长按悬浮窗：显示快捷菜单
        [ws showFloatMenu];
    };
}

// ─────────────────────────────────────────────
// 状态机 UI 更新
// ─────────────────────────────────────────────
- (void)updateStateUI:(GJTaskState)newState {
    _state = newState;

    dispatch_async(dispatch_get_main_queue(), ^{
        switch (newState) {
            case GJTaskStateIdle:
                [self setMainBtn:@"🔍  获取任务" color:GJ_PRIMARY];
                _stateLabel.text = @"准备就绪，点击按钮获取新任务";
                _stateLabel.textColor = GJ_TEXT_SECONDARY;
                _taskCard.hidden = YES;
                _productCard.hidden = YES;
                _secondaryButton.hidden = YES;
                [_spinner stopAnimating];
                [[FloatWindowManager shared] setBusy:NO];
                break;

            case GJTaskStateFetching:
                [self setMainBtn:@"获取中..." color:GJ_TEXT_MUTED];
                _stateLabel.text = @"⏳  正在获取任务...";
                _stateLabel.textColor = GJ_TEXT_SECONDARY;
                [_spinner startAnimating];
                [[FloatWindowManager shared] setBusy:YES];
                break;

            case GJTaskStateGotTask:
                [self setMainBtn:@"🛍  跳转商品页面" color:GJ_ACCENT];
                _stateLabel.text = @"✅  任务已获取，请跳转到商品页面完成浏览";
                _stateLabel.textColor = GJ_SUCCESS;
                _taskCard.hidden = NO;
                _secondaryButton.hidden = NO;
                [_spinner stopAnimating];
                [[FloatWindowManager shared] setBusy:NO];
                break;

            case GJTaskStateJumped:
                [self setMainBtn:@"📦  获取商品详情" color:GJ_PRIMARY];
                _stateLabel.text = @"📱  已跳转，请返回格界获取商品详情";
                _stateLabel.textColor = GJ_WARNING;
                [_spinner stopAnimating];
                break;

            case GJTaskStateFetchingProduct:
                [self setMainBtn:@"获取中..." color:GJ_TEXT_MUTED];
                _stateLabel.text = @"⏳  正在获取商品详情...";
                [_spinner startAnimating];
                [[FloatWindowManager shared] setBusy:YES];
                break;

            case GJTaskStateSubmitting:
                [self setMainBtn:@"提交中..." color:GJ_TEXT_MUTED];
                _stateLabel.text = @"⏳  正在提交任务...";
                [_spinner startAnimating];
                [[FloatWindowManager shared] setBusy:YES];
                break;

            case GJTaskStateDone:
                [self setMainBtn:@"🔍  继续获取任务" color:GJ_PRIMARY];
                _stateLabel.text = [NSString stringWithFormat:
                    @"🎉  任务完成！累计完成 %ld 单",
                    (long)[APIClient shared].finishedCount];
                _stateLabel.textColor = GJ_SUCCESS;
                _secondaryButton.hidden = YES;
                [_spinner stopAnimating];
                [[FloatWindowManager shared] setBusy:NO];
                [[FloatWindowManager shared] successPulse];
                [[FloatWindowManager shared] updateCount:[APIClient shared].finishedCount];
                [self updateCountLabel];
                break;
        }
    });
}

- (void)setMainBtn:(NSString *)title color:(UIColor *)color {
    [_mainActionButton setTitle:title forState:UIControlStateNormal];
    [_mainActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _mainActionButton.alpha = (color == GJ_TEXT_MUTED) ? 0.5 : 1.0;
    _mainActionButton.enabled = (color != GJ_TEXT_MUTED);
}

// ─────────────────────────────────────────────
// 主操作流程
// ─────────────────────────────────────────────
- (void)mainAction {
    switch (_state) {
        case GJTaskStateIdle:
        case GJTaskStateDone:
            [self fetchTask];
            break;
        case GJTaskStateGotTask:
            [self jumpToProduct];
            break;
        case GJTaskStateJumped:
            [self fetchProductDetail];
            break;
        case GJTaskStateFetchingProduct:
            // 等待中，忽略
            break;
        default:
            break;
    }
}

// ── Step 1: 获取任务
- (void)fetchTask {
    [self updateStateUI:GJTaskStateFetching];

    [[APIClient shared] getTaskWithCompletion:^(NSDictionary *taskData, NSString *error) {
        if (taskData) {
            self->_currentTask = taskData;
            [self updateTaskCard:taskData];
            [self updateStateUI:GJTaskStateGotTask];
        } else {
            [self updateStateUI:GJTaskStateIdle];
            [self showToast:error ?: @"暂无任务" color:GJ_WARNING];
        }
    }];
}

// ── Step 2: 跳转商品 App
- (void)jumpToProduct {
    NSString *taskURL = _currentTask[@"taskUrl"] ?: _currentTask[@"url"];
    if (!taskURL.length) {
        [self showToast:@"任务 URL 为空" color:GJ_DANGER]; return;
    }

    // 判断平台类型
    BOOL isShopee = [taskURL containsString:@"shopee"];
    BOOL isApple  = [taskURL containsString:@"apple.com"] || [taskURL containsString:@"apps.apple.com"];

    NSURL *openURL = nil;
    if (isShopee) {
        // 尝试打开 Shopee App（若未安装则打开网页）
        NSString *shopeeScheme = [taskURL stringByReplacingOccurrencesOfString:@"https://"
                                                                     withString:@"shopee://"];
        openURL = [NSURL URLWithString:shopeeScheme];
        if (![[UIApplication sharedApplication] canOpenURL:openURL]) {
            openURL = [NSURL URLWithString:taskURL];
        }
    } else if (isApple) {
        openURL = [NSURL URLWithString:taskURL];
    } else {
        openURL = [NSURL URLWithString:taskURL];
    }

    [[UIApplication sharedApplication] openURL:openURL
                                       options:@{}
                             completionHandler:^(BOOL success) {
        [self updateStateUI:GJTaskStateJumped];
        [self showToast:success ? @"已跳转，浏览完成后返回" : @"无法打开 App，请手动访问"
                  color:success ? GJ_SUCCESS : GJ_WARNING];
    }];
}

// ── Step 3: 获取商品详情
- (void)fetchProductDetail {
    NSString *taskURL = _currentTask[@"taskUrl"] ?: _currentTask[@"url"];
    [self updateStateUI:GJTaskStateFetchingProduct];

    [[APIClient shared] fetchShopeeProductFromURL:taskURL completion:^(NSDictionary *product, NSString *error) {
        if (product) {
            self->_currentProduct = product;
            [self updateProductCard:product];
            [self updateStateUI:GJTaskStateSubmitting]; // 直接提交
            [self submitTask];
        } else {
            // 商品详情获取失败，直接提交基础信息
            self->_currentProduct = @{@"url": taskURL ?: @"", @"error": error ?: @""};
            [self updateStateUI:GJTaskStateSubmitting];
            [self submitTask];
        }
    }];
}

// ── Step 4: 提交任务
- (void)submitTask {
    NSString *submitURL = _currentTask[@"taskUrl"] ?: _currentTask[@"url"] ?: @"";

    [[APIClient shared] submitTask:_currentTask
                         submitURL:submitURL
                            result:_currentProduct ?: @{}
                        completion:^(BOOL success, NSString *error) {
        if (success) {
            [[APIClient shared] incrementCount];
            [self addHistoryRecord];
            [self updateStateUI:GJTaskStateDone];
        } else {
            [self updateStateUI:GJTaskStateGotTask];
            [self showToast:[NSString stringWithFormat:@"提交失败：%@", error ?: @"未知错误"]
                     color:GJ_DANGER];
        }
    }];
}

// ── 跳过任务
- (void)skipTask {
    _currentTask = nil;
    _currentProduct = nil;
    [self updateStateUI:GJTaskStateIdle];
    [self showToast:@"已跳过，重新获取任务" color:GJ_TEXT_MUTED];
}

// ─────────────────────────────────────────────
// 更新任务卡片内容
// ─────────────────────────────────────────────
- (void)updateTaskCard:(NSDictionary *)task {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 任务标题
        NSString *title = task[@"taskTitle"] ?: task[@"title"] ?: @"商品浏览任务";
        self->_taskTitleLabel.text = title;

        // URL（截断显示）
        NSString *url = task[@"taskUrl"] ?: task[@"url"] ?: @"";
        self->_taskURLLabel.text = url.length > 50
            ? [NSString stringWithFormat:@"%@...", [url substringToIndex:50]]
            : url;

        // 附加信息
        NSString *reward = task[@"reward"] ?: task[@"commission"] ?: @"";
        NSString *deadline = task[@"deadline"] ?: @"";
        self->_taskInfoLabel.text = [NSString stringWithFormat:@"佣金：%@  |  截止：%@",
                               reward.length ? reward : @"—",
                               deadline.length ? deadline : @"—"];
    });
}

// ─────────────────────────────────────────────
// 更新商品卡片内容
// ─────────────────────────────────────────────
- (void)updateProductCard:(NSDictionary *)product {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_productCard.hidden = NO;
        self->_productNameLabel.text = product[@"name"] ?: @"商品名称获取中";

        NSNumber *price = product[@"price"];
        if (price) {
            double p = price.doubleValue / 100000.0; // Shopee 价格单位
            self->_productPriceLabel.text = [NSString stringWithFormat:@"NT$ %.0f", p];
        }

        NSNumber *rating = product[@"rating"];
        NSNumber *stock  = product[@"stock"];
        self->_productRatingLabel.text = [NSString stringWithFormat:@"⭐ %.1f  库存 %@",
                                    rating ? rating.doubleValue : 0.0,
                                    stock ?: @"—"];
    });
}

// ─────────────────────────────────────────────
// 历史记录
// ─────────────────────────────────────────────
- (void)addHistoryRecord {
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"HH:mm:ss";
    NSString *timeStr = [fmt stringFromDate:[NSDate date]];
    NSString *taskTitle = _currentTask[@"taskTitle"] ?: _currentTask[@"title"] ?: @"商品任务";
    [_taskHistory insertObject:@{@"time": timeStr, @"title": taskTitle} atIndex:0];
    if (_taskHistory.count > 50) [_taskHistory removeLastObject];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_historyTable reloadData];
    });
}

- (void)updateCountLabel {
    _countLabel.text = [NSString stringWithFormat:@"已完成 %ld",
                        (long)[APIClient shared].finishedCount];
}

// ─────────────────────────────────────────────
// TableView - 历史记录
// ─────────────────────────────────────────────
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    return _taskHistory.count == 0 ? 1 : _taskHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"hist"]
        ?: [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:@"hist"];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = GJ_TEXT_PRIMARY;
    cell.textLabel.font = GJ_FONT_SMALL;
    cell.detailTextLabel.textColor = GJ_TEXT_MUTED;
    cell.detailTextLabel.font = GJ_FONT_CAPTION;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (_taskHistory.count == 0) {
        cell.textLabel.text = @"暂无完成记录";
        cell.textLabel.textColor = GJ_TEXT_MUTED;
        cell.detailTextLabel.text = @"";
    } else {
        NSDictionary *item = _taskHistory[ip.row];
        cell.textLabel.text = item[@"title"];
        cell.detailTextLabel.text = item[@"time"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)ip {
    return 38;
}

// ─────────────────────────────────────────────
// 悬浮窗长按菜单
// ─────────────────────────────────────────────
- (void)showFloatMenu {
    UIAlertController *menu = [UIAlertController
        alertControllerWithTitle:@"格界 快捷操作"
        message:nil
        preferredStyle:UIAlertControllerStyleActionSheet];

    [menu addAction:[UIAlertAction actionWithTitle:@"🔍 获取新任务"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *a) { [self fetchTask]; }]];

    [menu addAction:[UIAlertAction actionWithTitle:@"📊 查看完成记录"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *a) {
            [self->_scrollView scrollRectToVisible:self->_historyTable.frame animated:YES];
        }]];

    [menu addAction:[UIAlertAction actionWithTitle:@"⚙️ 设置服务器地址"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *a) { [self showServerConfig]; }]];

    [menu addAction:[UIAlertAction actionWithTitle:@"🚪 退出登录"
        style:UIAlertActionStyleDestructive
        handler:^(UIAlertAction *a) { [self logout]; }]];

    [menu addAction:[UIAlertAction actionWithTitle:@"取消"
        style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:menu animated:YES completion:nil];
}

// ─────────────────────────────────────────────
// 服务器地址配置
// ─────────────────────────────────────────────
- (void)showServerConfig {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"服务器地址"
        message:@"修改 API 服务器地址"
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.text = [APIClient shared].serverURL;
        tf.keyboardType = UIKeyboardTypeURL;
        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"保存"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *a) {
            NSString *url = alert.textFields.firstObject.text;
            if (url.length > 0) {
                [APIClient shared].serverURL = url;
                [[NSUserDefaults standardUserDefaults] setObject:url forKey:@"GJ_SERVER"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self showToast:@"服务器地址已保存" color:GJ_SUCCESS];
            }
        }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
        style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

// ─────────────────────────────────────────────
// 退出登录
// ─────────────────────────────────────────────
- (void)logout {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [APIClient shared].token = nil;
    [[FloatWindowManager shared] hide];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ─────────────────────────────────────────────
// Toast 提示
// ─────────────────────────────────────────────
- (void)showToast:(NSString *)msg color:(UIColor *)color {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat W = self.view.bounds.size.width;
        UILabel *toast = [[UILabel alloc] initWithFrame:CGRectMake(20, -60, W-40, 48)];
        toast.text = msg;
        toast.textAlignment = NSTextAlignmentCenter;
        toast.font = GJ_FONT_BODY;
        toast.textColor = [UIColor whiteColor];
        toast.backgroundColor = [color colorWithAlphaComponent:0.92];
        toast.layer.cornerRadius = GJ_RADIUS_MD;
        toast.layer.masksToBounds = YES;
        [self.view addSubview:toast];

        CGFloat safeTop = self.view.safeAreaInsets.top + 70;
        [UIView animateWithDuration:0.3 animations:^{
            toast.frame = CGRectMake(20, safeTop, W-40, 48);
        } completion:^(BOOL f) {
            [UIView animateWithDuration:0.3 delay:2.0 options:0 animations:^{
                toast.alpha = 0;
            } completion:^(BOOL f2) { [toast removeFromSuperview]; }];
        }];
    });
}

@end
