# AttentionOS v0.1 (SwiftUI + SwiftData)

这是 AttentionOS v0.1 的可运行 SwiftUI + SwiftData 项目骨架，面向 iOS 17 / Xcode 15+。

## 功能覆盖
- 数据模型：`InboxItem` / `Case` / `Attempt`，包含 `importance/urgency/state/decision/benefit/friction/nextReview/notifyEnabled/manual` 等字段。
- 基础导航与三 Tab：Capture / Review / Cases，冷启动默认进入 Review。
- Capture：两输入框（想法必填、为什么可选），保存后清空并停留在页。
- Review：列表分段（Due / Inbox / Do Now / Schedule），包含示例过滤逻辑（基于字段）。
- Cases：Case 列表与详情页占位。

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
    CaseDetailView.swift
    Components/
      InboxItemRow.swift
      CaseRow.swift
```

## 运行与构建
- 打开 `AttentionOS.xcodeproj`，选择 iOS 17+ 模拟器即可运行。
- CLI 构建命令（示例）：
  ```
  xcodebuild -project AttentionOS.xcodeproj -scheme AttentionOS -destination 'platform=iOS Simulator,name=iPhone 15' build
  ```
  本环境未安装完整 Xcode（仅 Command Line Tools），因此未能实际执行该命令。

## 下一步建议
- 在 Review 页面引入更完整的决策流转（state/decision 自动更新）。
- 为 Case 与 Attempt 增加编辑表单与关系管理。
- 加入通知调度（基于 `nextReview` + `notifyEnabled`）。
- 引入数据迁移策略与测试数据种子。
