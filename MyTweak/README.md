# MyTweak — iOS Tweak 开发模板

## 项目结构

```
MyTweak/
├── Tweak.x              # 主逻辑（Logos 语法，Hook 代码写这里）
├── Makefile             # 编译配置
├── control              # deb 包元信息（包名、版本、作者等）
├── MyTweak.plist        # 注入进程过滤规则
├── setup_wsl.sh         # WSL 一键安装 Theos 脚本
├── Prefs/
│   └── MyTweakPrefs.mm  # 设置页控制器（可选）
└── Resources/
    └── prefs/
        └── Root.plist   # 设置页 UI 配置（可选）
```

---

## 第一步：WSL 安装 Theos

打开 Windows Terminal，进入 WSL：

```bash
# 复制脚本到 WSL 可访问路径，然后执行
bash setup_wsl.sh

# 重启终端后验证
theos --version
```

---

## 第二步：编译

```bash
cd MyTweak

# 编译（生成 .deb）
make package

# 编译 + 清理
make clean && make package

# 生成的 deb 在：
# packages/com.yourname.mytweak_1.0.0_iphoneos-arm.deb
```

---

## 第三步：安装到设备

### 方式一：直接通过 SSH 安装（设备与电脑同一 Wi-Fi）

```bash
# 设置设备 IP（在 Makefile 中也可以写死）
export THEOS_DEVICE_IP=192.168.1.xxx

# 一键编译并安装
make install
```

### 方式二：手动传输安装

```bash
# 把 deb 文件传到手机
scp packages/*.deb mobile@192.168.1.xxx:/var/mobile/

# SSH 进设备安装
ssh root@192.168.1.xxx
dpkg -i /var/mobile/*.deb
killall -9 SpringBoard
```

### 方式三：用 Filza / Sileo 安装

把 `.deb` 文件传到手机后，用 **Filza** 点击安装，或加入本地源用 **Sileo/Cydia** 安装。

---

## Logos 语法速查

```objc
// Hook 一个类
%hook ClassName
- (void)method {
    %orig;              // 调用原方法
}
- (NSString *)getText {
    NSString *orig = %orig;
    return [orig stringByAppendingString:@" ✦"];
}
%end

// 添加新方法
%hook UIViewController
%new
- (void)myNewMethod {
    NSLog(@"新方法");
}
%end

// 分组（按条件激活）
%group iPhone
%hook SomeClass
- (void)method { %orig; }
%end
%end

// 构造函数
%ctor {
    %init;              // 初始化所有默认 hook
    %init(iPhone);      // 初始化指定分组
}
```

---

## 常用 Hook 目标进程

| Bundle ID | 说明 |
|-----------|------|
| `com.apple.springboard` | 桌面/SpringBoard |
| `com.apple.UIKit` | 全局 UIKit |
| `com.apple.MobileSMS` | 短信 |
| `com.apple.mobilephone` | 电话 |
| `com.apple.mobilesafari` | Safari |
| `com.tencent.xin` | 微信 |
| `com.tencent.qq` | QQ |

---

## 读取设置（Tweak.x 中使用）

```objc
// 在 Tweak.x 顶部添加
static BOOL tweakEnabled = YES;

static void loadPrefs() {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:
        @"/var/mobile/Library/Preferences/com.yourname.mytweak.plist"];
    tweakEnabled = prefs[@"enabled"] ? [prefs[@"enabled"] boolValue] : YES;
}

%ctor {
    loadPrefs();
    // 监听设置变更
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        (CFNotificationCallback)loadPrefs,
        CFSTR("com.yourname.mytweak/settingsChanged"),
        NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately
    );
    %init;
}
```
