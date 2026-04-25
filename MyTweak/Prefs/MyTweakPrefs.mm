/*
 * MyTweakPrefs.mm
 * 设置页控制器（PreferenceLoader 使用）
 * 在 Tweak.x 中通过 NSUserDefaults 读取这里保存的设置
 */

#import <Preferences/Preferences.h>

// 设置存储路径
static NSString * const kPrefPath =
    @"/var/mobile/Library/Preferences/com.yourname.mytweak.plist";

// 监听设置变更的通知名
static NSString * const kNotifChanged =
    @"com.yourname.mytweak/settingsChanged";

@interface MyTweakListController : PSListController
@end

@implementation MyTweakListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        // 从 Resources/prefs/Root.plist 加载
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

// 设置存储路径（覆盖父类方法）
- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:kPrefPath];
    id value = prefs[specifier.properties[@"key"]];
    return value ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefPath]
                                  ?: [NSMutableDictionary dictionary];
    prefs[specifier.properties[@"key"]] = value;
    [prefs writeToFile:kPrefPath atomically:YES];

    // 发出通知，让 Tweak 实时响应设置变更
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        (CFStringRef)kNotifChanged,
        NULL, NULL, YES
    );
}

@end
