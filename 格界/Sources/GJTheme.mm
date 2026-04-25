#import "GJTheme.h"

@implementation GJTheme

+ (CAGradientLayer *)primaryGradientLayerWithFrame:(CGRect)frame {
    CAGradientLayer *g = [CAGradientLayer layer];
    g.frame = frame;
    g.colors = @[
        (id)[UIColor colorWithRed:0.18 green:0.38 blue:0.98 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.42 green:0.22 blue:0.95 alpha:1.0].CGColor,
    ];
    g.startPoint = CGPointMake(0, 0);
    g.endPoint   = CGPointMake(1, 1);
    return g;
}

+ (CAGradientLayer *)accentGradientLayerWithFrame:(CGRect)frame {
    CAGradientLayer *g = [CAGradientLayer layer];
    g.frame = frame;
    g.colors = @[
        (id)[UIColor colorWithRed:0.00 green:0.85 blue:0.83 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.18 green:0.38 blue:0.98 alpha:1.0].CGColor,
    ];
    g.startPoint = CGPointMake(0, 0);
    g.endPoint   = CGPointMake(1, 0);
    return g;
}

+ (void)applyPrimaryStyle:(UIButton *)button {
    button.layer.cornerRadius = GJ_RADIUS_MD;
    button.layer.masksToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    // 移除旧渐变
    for (CALayer *l in button.layer.sublayers) {
        if ([l isKindOfClass:[CAGradientLayer class]]) {
            [l removeFromSuperlayer];
            break;
        }
    }
    CAGradientLayer *g = [self primaryGradientLayerWithFrame:button.bounds];
    [button.layer insertSublayer:g atIndex:0];
}

+ (UIVisualEffectView *)blurCardWithFrame:(CGRect)frame radius:(CGFloat)radius {
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
    UIVisualEffectView *v = [[UIVisualEffectView alloc] initWithEffect:blur];
    v.frame = frame;
    v.layer.cornerRadius = radius;
    v.layer.masksToBounds = YES;
    v.layer.borderWidth = 0.5;
    v.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.12].CGColor;
    return v;
}

+ (void)styleTextField:(UITextField *)tf placeholder:(NSString *)placeholder {
    tf.backgroundColor = GJ_BG_INPUT;
    tf.textColor = GJ_TEXT_PRIMARY;
    tf.font = GJ_FONT_BODY;
    tf.layer.cornerRadius = GJ_RADIUS_SM;
    tf.layer.borderWidth = 1.0;
    tf.layer.borderColor = GJ_BORDER.CGColor;
    tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0,0,14,1)];
    tf.leftViewMode = UITextFieldViewModeAlways;

    NSAttributedString *ph = [[NSAttributedString alloc]
        initWithString:placeholder
        attributes:@{NSForegroundColorAttributeName: GJ_TEXT_MUTED,
                     NSFontAttributeName: GJ_FONT_BODY}];
    tf.attributedPlaceholder = ph;
    tf.keyboardAppearance = UIKeyboardAppearanceDark;
    tf.tintColor = GJ_PRIMARY;
}

@end
