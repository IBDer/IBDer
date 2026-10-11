# 流程：CI 与交付

**状态：初稿，待评审。**

## 现状

- **没有付费 Apple Developer 账号**，因此首版不做真机分发与 TestFlight。
- 开发与验证在本地 macOS 上完成：可构建 iOS 模拟器目标，也可以「Designed for iPad」形式直接在 Mac 上运行，无需签名。

## CI 目标（GitHub Actions，macOS runner）

1. 检出代码。
2. 检测是否存在 Xcode 工程：没有则跳过构建步骤（骨架期保持绿灯）。
3. 有工程后：`xcodebuild build` + `xcodebuild test`（模拟器目标，不需要签名）。
4. SwiftFormat / SwiftLint 检查。

## 分支保护

- `main` 需要 PR 才能合并，且 CI 必须绿。
- agent 不自行合并。

## 交付节奏

- 每个归档的 change 由人类打一个 tag。
- 未来若引入 TestFlight，需要先决定：谁持有开发者账号、证书与描述文件如何管理、是否公开测试。**这是一个独立决定，不在首版范围。**

## 密钥

- 仓库内不得出现证书、描述文件、API key。
- 需要密钥时用 GitHub Actions secrets，并在文档里记录用途。
