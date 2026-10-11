# 架构规范

**状态：初稿，待评审。** 首版 iOS 原生（SwiftUI）。

## 分层与依赖方向

依赖只能向下，**不能反向，也不能跨层回跳**：

```
App          ← 组装、导航、依赖注入
  Features   ← 一个患者可感知的功能一个目录
    Domain   ← 纯逻辑：实体、值对象、规则、用例
      Core   ← 平台无关工具（时间、ID、序列化）
    Data     ← 持久化与导出实现
  DesignSystem ← 设计 token 与通用组件
```

- **Domain 不认识 UI，也不认识持久化。** 它不 import SwiftUI、不 import SwiftData。
- Feature 之间不得互相 import；共享的东西下沉到 Domain 或 DesignSystem。
- Data 依赖 Domain 定义的协议，不反过来。

## 为什么这样切

- Domain 纯逻辑 → 可以用最快的单元测试覆盖统计口径、完整性规则、日期窗口，这是本项目出错代价最高的地方。
- UI 与持久化可替换 → 首版本地存储，将来若要同步，不必重写规则层。

## 目录约定

```
IBDer/
  App/
  Features/
    ToiletEvent/
    DailyConfirmation/
    VisitSummary/
  Domain/
    Entities/
    Rules/
    UseCases/
  Data/
    Persistence/
    Export/
  DesignSystem/
    Tokens/
    Components/
IBDerTests/
IBDerUITests/
```

## 状态与数据流

- 单向数据流：View 发意图 → UseCase 改状态 → View 观察状态重绘。
- 不使用全局可变单例承载业务状态；依赖从 App 层注入。
- 日期与时间一律通过可注入的时钟获取，禁止在 Domain 里直接调用当前时间（这是可测试性的前提）。

## 持久化

- 首版本地存储；具体技术（SwiftData 或其他）在实现该 change 时决定并记录 ADR。
- **任何写入失败都不得让界面显示「已保存」。**

## 模块深度

- 优先「小接口 + 厚实现」。一个模块的对外接口应当窄到能用几句话说完。
- 不为了复用而过早抽象；出现第三个调用方时再提取。
