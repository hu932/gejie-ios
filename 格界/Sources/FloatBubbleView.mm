#import "FloatBubbleView.h"
#import "GJTheme.h"
#import <UIKit/UIKit.h>

@interface FloatBubbleView ()
@property (nonatomic, strong) UILabel              *iconLabel;
@property (nonatomic, strong) UILabel              *badgeLabel;
@property (nonatomic, strong) UIView               *badgeView;
@property (nonatomic, strong) CAGradientLayer      *gradientLayer;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, assign) CGPoint              lastPoint;
@end

static const CGFloat kBubbleSize = 60.0;

@implementation FloatBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, kBubbleSize, kBubbleSize)];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.layer.cornerRadius = kBubbleSize / 2;
    self.layer.masksToBounds = NO;

    self.layer.shadowColor   = [UIColor colorWithRed:0.18 green:0.38 blue:0.98 alpha:0.7].CGColor;
    self.layer.shadowOffset  = CGSizeMake(0, 4);
    self.layer.shadowRadius  = 14;
    self.layer.shadowOpacity = 0.9;

    _gradientLayer = [GJTheme primaryGradientLayerWithFrame:self.bounds];
    _gradientLayer.cornerRadius = kBubbleSize / 2;
    [self.layer addSublayer:_gradientLayer];

    CALayer *border = [CALayer layer];
    border.frame = CGRectInset(self.bounds, -1.5, -1.5);
    border.cornerRadius = (kBubbleSize + 3) / 2;
    border.borderWidth = 1.5;
    border.borderColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
    [self.layer addSublayer:border];

    _iconLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _iconLabel.text = @"格";
    _iconLabel.textAlignment = NSTextAlignmentCenter;
    _iconLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    _iconLabel.textColor = [UIColor whiteColor];
    [self addSubview:_iconLabel];

    _spinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    _spinner.color = [UIColor whiteColor];
    _spinner.center = CGPointMake(kBubbleSize/2, kBubbleSize/2);
    _spinner.hidesWhenStopped = YES;
    [self addSubview:_spinner];

    _badgeView = [[UIView alloc] initWithFrame:CGRectMake(38, 0, 24, 20)];
    _badgeView.backgroundColor = GJ_DANGER;
    _badgeView.layer.cornerRadius = 10;
    _badgeView.hidden = YES;
    [self addSubview:_badgeView];

    _badgeLabel = [[UILabel alloc] initWithFrame:_badgeView.bounds];
    _badgeLabel.textAlignment = NSTextAlignmentCenter;
    _badgeLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
    _badgeLabel.textColor = [UIColor whiteColor];
    [_badgeView addSubview:_badgeLabel];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
        initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:self action:@selector(handleTap)];
    [self addGestureRecognizer:tap];

    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc]
        initWithTarget:self action:@selector(handleLongPress:)];
    lp.minimumPressDuration = 0.6;
    [self addGestureRecognizer:lp];

    // 入场动画
    self.alpha = 0;
    self.transform = CGAffineTransformMakeScale(0.3, 0.3);
    UIViewPropertyAnimator *entry = [[UIViewPropertyAnimator alloc]
        initWithDuration:0.4 dampingRatio:0.6 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    }];
    [entry startAnimationAfterDelay:0.3];
}

// ─────────────────────────────────────────────
// 公开接口
// ─────────────────────────────────────────────
- (void)updateCount:(NSInteger)count {
    _count = count;
    if (count > 0) {
        _badgeView.hidden = NO;
        _badgeLabel.text = count > 99 ? @"99+" : [NSString stringWithFormat:@"%ld", (long)count];
        _badgeView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        UIViewPropertyAnimator *anim = [[UIViewPropertyAnimator alloc]
            initWithDuration:0.3 dampingRatio:0.5 animations:^{
            self->_badgeView.transform = CGAffineTransformIdentity;
        }];
        [anim startAnimation];
    } else {
        _badgeView.hidden = YES;
    }
}

- (void)pulseAnimation {
    UIView *pulse = [[UIView alloc] initWithFrame:self.bounds];
    pulse.layer.cornerRadius = kBubbleSize / 2;
    pulse.backgroundColor = [UIColor colorWithRed:0.18 green:0.84 blue:0.44 alpha:0.6];
    [self insertSubview:pulse atIndex:0];

    [UIView animateWithDuration:0.8 animations:^{
        pulse.transform = CGAffineTransformMakeScale(2.0, 2.0);
        pulse.alpha = 0;
    } completion:^(BOOL fin) {
        [pulse removeFromSuperview];
    }];

    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = @[@(-0.15), @(0.15), @(-0.10), @(0.10), @0];
    anim.duration = 0.5;
    [self.layer addAnimation:anim forKey:@"pulse"];
}

- (void)setBusy:(BOOL)busy {
    if (busy) {
        _iconLabel.hidden = YES;
        [_spinner startAnimating];
        CABasicAnimation *rot = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rot.byValue = @(M_PI * 2);
        rot.duration = 2.0;
        rot.repeatCount = INFINITY;
        [_gradientLayer addAnimation:rot forKey:@"gradRot"];
    } else {
        _iconLabel.hidden = NO;
        [_spinner stopAnimating];
        [_gradientLayer removeAnimationForKey:@"gradRot"];
    }
}

// ─────────────────────────────────────────────
// 手势处理
// ─────────────────────────────────────────────
- (void)handlePan:(UIPanGestureRecognizer *)g {
    UIView *parent = self.superview;
    if (!parent) return;

    CGPoint trans = [g translationInView:parent];
    CGPoint newCenter = CGPointMake(self.center.x + trans.x, self.center.y + trans.y);

    CGFloat r = kBubbleSize / 2;
    newCenter.x = MAX(r + 10, MIN(parent.bounds.size.width  - r - 10, newCenter.x));
    newCenter.y = MAX(r + 60, MIN(parent.bounds.size.height - r - 30, newCenter.y));

    self.center = newCenter;
    [g setTranslation:CGPointZero inView:parent];

    if (g.state == UIGestureRecognizerStateEnded) {
        [self snapToEdge];
    }
}

- (void)snapToEdge {
    UIView *parent = self.superview;
    CGFloat W = parent.bounds.size.width;
    CGFloat targetX = self.center.x < W / 2 ? (kBubbleSize/2 + 10) : (W - kBubbleSize/2 - 10);
    CGFloat targetY = self.center.y;

    UIViewPropertyAnimator *snap = [[UIViewPropertyAnimator alloc]
        initWithDuration:0.35 dampingRatio:0.7 animations:^{
        self.center = CGPointMake(targetX, targetY);
    }];
    [snap startAnimation];
}

- (void)handleTap {
    [UIView animateWithDuration:0.1 animations:^{
        self.transform = CGAffineTransformMakeScale(0.88, 0.88);
    } completion:^(BOOL f) {
        UIViewPropertyAnimator *bounce = [[UIViewPropertyAnimator alloc]
            initWithDuration:0.2 dampingRatio:0.5 animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
        [bounce startAnimation];
    }];
    if (self.onTap) self.onTap();
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)g {
    if (g.state == UIGestureRecognizerStateBegan) {
        if (self.onLongPress) self.onLongPress();
    }
}

@end
