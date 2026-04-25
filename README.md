# 格界 (GeJie) - iOS 插件

基于 Theos 构建的 iOS 越狱插件，提供任务管理与悬浮气泡等功能。

---

## 项目结构

```
ios/
├── 格界/
│   └── Sources/          # Objective-C 源码
│       ├── APIClient.h/.mm       # 网络请求封装
│       ├── AppDelegate.mm        # 应用入口
│       ├── GJTheme.h             # 主题色/宏定义
│       ├── FloatBubbleView.mm    # 悬浮气泡视图
│       ├── TaskViewController.mm # 任务列表页
│       └── ...
├── Makefile              # Theos 构建配置
└── README.md
```

---

## 构建说明

本项目通过 **GitHub Actions** 自动触发编译，构建环境由 CI 统一管理，无需本地配置 Theos。

每次推送到 `main` 分支后，Actions 会自动执行编译并输出结果。

---

## 代码推送流程

由于网络限制，推送需在 **PowerShell** 中逐条执行以下命令（不能用 `&&` 连接）：

```powershell
# 1. 进入项目目录
cd C:\Users\Administrator\Desktop\ios

# 2. 查看当前修改状态
git status

# 3. 暂存所有修改
git add .

# 4. 提交（修改引号内的提交信息）
git commit -m "fix: 修复编译错误"

# 5. 推送到远程 main 分支
git push origin main
```

> **注意**：PowerShell 不支持 `&&` 连接多条命令，必须逐条执行。

---

## 常见问题

### 推送冲突

若推送时提示冲突，执行以下步骤：

```powershell
# 拉取远程最新代码
git fetch origin

# 对冲突文件采用远程版本（以 .github/workflows/build.yml 为例）
git checkout --theirs .github/workflows/build.yml

# 重新暂存并提交
git add .
git commit -m "resolve: 解决合并冲突"
git push origin main
```

### 推送被拒绝（non-fast-forward）

```powershell
git pull --rebase origin main
git push origin main
```

---

## 编译错误记录

| 错误类型 | 文件 | 修复方案 |
|---------|------|---------|
| nullability 缺失 | `APIClient.h` | 添加 `_Nonnull` / `nonnull` 修饰符 |
| 宏未定义 `GJ_BG_SECONDARY` | `AppDelegate.mm` | `GJTheme.h` 添加别名宏 |
| 宏未定义 `GJ_TEXT_SECONDARY` | `GJTheme.h` | 添加 `#define GJ_TEXT_SECONDARY GJ_TEXT_SEC` |
| 废弃 API `statusBarStyle` | `AppDelegate.mm` | 删除该行（iOS 13+ 不支持） |
| 未使用变量 `bw` | `TaskViewController.mm` | 删除该变量声明 |
| Spring 动画方法找不到 | `FloatBubbleView.mm` | 改用 `UIViewPropertyAnimator` |

---

## 依赖

- Theos（由 CI 环境提供）
- iOS SDK 14.0+
- ARC（自动引用计数）已启用：`-fobjc-arc`
