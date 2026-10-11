# Swift 代码风格

**状态：初稿，待评审。** 原则：**靠工具强制，不靠人记。**

## 强制工具

| 工具 | 作用 | 何时跑 |
| --- | --- | --- |
| SwiftFormat | 格式化（缩进、换行、排序） | 保存时 + CI |
| SwiftLint | 规则检查（禁止 force unwrap 等） | 保存时 + CI |

配置随首个 Xcode 工程一起加入，配置本身也要 review。

## 规则

- 遵循 [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)。
- 4 空格缩进，行宽 120。
- **禁止 `!` 强制解包**（测试与 `@IBOutlet` 除外）；用 `guard let` 提前返回。
- 优先 `let`；类型推断与显式类型以可读性为准，公开 API 显式标注类型。
- 错误用 `throws` + 具体错误类型表达，不用 `Optional` 表示失败原因。
- 并发：Swift 6 严格并发；跨 actor 传递的类型必须 `Sendable`；UI 状态在主 actor。
- 不写「将来可能有用」的参数与分支。
- 注释写**为什么**，不写**是什么**；注释用英文。

## 命名

见 [naming.md](naming.md)。标识符必须取自 [CONTEXT.md](../../CONTEXT.md)。

## 本地化

- 界面字符串一律走 String Catalog，不硬编码。
- 首版中文；代码里不出现中文字符串字面量（测试断言除外）。
