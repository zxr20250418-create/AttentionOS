# AttentionOS v0.1 (SwiftUI + SwiftData)

这是 AttentionOS v0.1 的可运行 SwiftUI + SwiftData 项目骨架，面向 iOS 17 / Xcode 15+。

## 功能覆盖
- 数据模型：`InboxItem` / `Case` / `Attempt`，包含 `importance/urgency/state/decision/benefit/friction/nextReview/notifyEnabled/manual` 等字段。
- 基础导航与四 Tab：Capture / Review / Cases / Settings，冷启动默认进入 Review。
- Capture：两输入框（想法必填、为什么可选），保存后清空并停留在页。
- Review：列表分段（Due / Inbox / Do Now / Schedule），包含示例过滤逻辑（基于字段）。
- Cases：Case 列表、详情、编辑与尝试记录。
- 本地通知：`nextReview` + `notifyEnabled` 自动排程，支持单条更新与全局开关。
- Obsidian 导出：在 Settings 选择导出目录（安全书签），支持一键导出全部 Case 为 Markdown。

## 项目结构
```
AttentionOS/
  AttentionOSApp.swift         # App 入口 + Tab 导航
  Info.plist
  Assets.xcassets/
  Models/
    Enums.swift
    InboxItem.swift
    Case.swift
    Attempt.swift
    PreviewContainer.swift
  Views/
    CaptureView.swift
    ReviewView.swift
    CasesView.swift
    SettingsView.swift
    CaseDetailView.swift
    Components/
      InboxItemRow.swift
      CaseRow.swift
  NotificationManager.swift
```

## 运行与构建
- 打开 `AttentionOS.xcodeproj`，选择 iOS 17+ 模拟器即可运行。
- CLI 构建命令（示例）：
  ```
  xcodebuild -project AttentionOS.xcodeproj -scheme AttentionOS -destination 'platform=iOS Simulator,name=iPhone 15' build
  ```
  本环境未安装完整 Xcode（仅 Command Line Tools），因此未能实际执行该命令。

## 下一步建议
- 将 Review 决策流转扩展到 Case 与 Attempt（含分段筛选）。
- 将 Attempt 的 importance/urgency/outcome 纳入 Review 分段逻辑与展示。
- 引入数据迁移策略与测试数据种子。
