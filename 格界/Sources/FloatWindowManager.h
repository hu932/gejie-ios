#pragma once
#import <UIKit/UIKit.h>
#import "FloatBubbleView.h"

/// 全局悬浮窗管理器，使用独立 UIWindow 实现常驻显示
@interface FloatWindowManager : NSObject

+ (instancetype)shared;

/// 显示悬浮气泡
- (void)show;
/// 隐藏悬浮气泡
- (void)hide;
/// 切换显示/隐藏
- (void)toggle;

/// 更新完成计数徽标
- (void)updateCount:(NSInteger)count;
/// 任务完成脉冲动画
- (void)successPulse;
/// 设置忙碌状态
- (void)setBusy:(BOOL)busy;

/// 点击气泡时的回调
@property (nonatomic, copy) dispatch_block_t onTap;
/// 长按气泡时的回调（显示菜单）
@property (nonatomic, copy) dispatch_block_t onLongPress;

@end
