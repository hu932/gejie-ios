#pragma once
#import <UIKit/UIKit.h>

typedef void(^GJBubbleTapBlock)(void);
typedef void(^GJBubbleLongPressBlock)(void);

/// 可拖动悬浮气泡
@interface FloatBubbleView : UIView

@property (nonatomic, copy) GJBubbleTapBlock onTap;
@property (nonatomic, copy) GJBubbleLongPressBlock onLongPress;
@property (nonatomic, assign) NSInteger count;  ///< 完成数量徽标

- (void)updateCount:(NSInteger)count;
- (void)pulseAnimation;    ///< 任务完成时的脉冲动画
- (void)setBusy:(BOOL)busy; ///< 旋转加载状态

@end
