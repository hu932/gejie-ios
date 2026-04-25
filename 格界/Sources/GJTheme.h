#pragma once
#import <UIKit/UIKit.h>

// ─────────────────────────────────────────────
// 格界 全局主题
// ─────────────────────────────────────────────

// 主色调 - 深邃科技蓝紫渐变
#define GJ_PRIMARY       [UIColor colorWithRed:0.18 green:0.38 blue:0.98 alpha:1.0]
#define GJ_SECONDARY     [UIColor colorWithRed:0.42 green:0.22 blue:0.95 alpha:1.0]
#define GJ_ACCENT        [UIColor colorWithRed:0.00 green:0.85 blue:0.83 alpha:1.0]

// 背景色
#define GJ_BG_DARK       [UIColor colorWithRed:0.05 green:0.06 blue:0.12 alpha:1.0]
#define GJ_BG_CARD       [UIColor colorWithRed:0.10 green:0.12 blue:0.20 alpha:1.0]
#define GJ_BG_SECONDARY  GJ_BG_CARD
#define GJ_BG_INPUT      [UIColor colorWithRed:0.13 green:0.15 blue:0.24 alpha:1.0]

// 文字色
#define GJ_TEXT_PRIMARY    [UIColor colorWithWhite:0.95 alpha:1.0]
#define GJ_TEXT_SEC        [UIColor colorWithWhite:0.60 alpha:1.0]
#define GJ_TEXT_SECONDARY  GJ_TEXT_SEC
#define GJ_TEXT_MUTED      [UIColor colorWithWhite:0.35 alpha:1.0]

// 状态色
#define GJ_SUCCESS       [UIColor colorWithRed:0.18 green:0.84 blue:0.44 alpha:1.0]
#define GJ_WARNING       [UIColor colorWithRed:1.00 green:0.76 blue:0.03 alpha:1.0]
#define GJ_DANGER        [UIColor colorWithRed:0.96 green:0.26 blue:0.21 alpha:1.0]

// 边框
#define GJ_BORDER        [UIColor colorWithWhite:1.0 alpha:0.08]
#define GJ_BORDER_ACTIVE [UIColor colorWithRed:0.18 green:0.38 blue:0.98 alpha:0.8]

// 字体
#define GJ_FONT_TITLE    [UIFont systemFontOfSize:22 weight:UIFontWeightBold]
#define GJ_FONT_SUBTITLE [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold]
#define GJ_FONT_BODY     [UIFont systemFontOfSize:14 weight:UIFontWeightRegular]
#define GJ_FONT_SMALL    [UIFont systemFontOfSize:12 weight:UIFontWeightRegular]
#define GJ_FONT_CAPTION  [UIFont systemFontOfSize:11 weight:UIFontWeightMedium]
#define GJ_FONT_MONO     [UIFont monospacedDigitSystemFontOfSize:13 weight:UIFontWeightMedium]

// 圆角
#define GJ_RADIUS_SM   8.0f
#define GJ_RADIUS_MD  12.0f
#define GJ_RADIUS_LG  18.0f
#define GJ_RADIUS_XL  24.0f

@interface GJTheme : NSObject

/// 生成主渐变图层 (蓝→紫)
+ (CAGradientLayer *)primaryGradientLayerWithFrame:(CGRect)frame;

/// 生成强调渐变图层 (青→蓝)
+ (CAGradientLayer *)accentGradientLayerWithFrame:(CGRect)frame;

/// 带渐变背景的按钮样式
+ (void)applyPrimaryStyle:(UIButton *)button;

/// 通用毛玻璃卡片
+ (UIVisualEffectView *)blurCardWithFrame:(CGRect)frame radius:(CGFloat)radius;

/// 标准输入框样式
+ (void)styleTextField:(UITextField *)tf placeholder:(NSString *)placeholder;

@end
