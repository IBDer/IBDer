# 命名规范

**状态：初稿，待评审。** 核心规则：**代码里的领域名词只能来自 [CONTEXT.md](../../CONTEXT.md)。**

## 为什么

多个 agent 接力开发时，最大的隐性损耗是**同一个概念被起了三个名字**（或一个名字指三件事）。词汇表把这件事变成可检查的规则。

## 规则

1. 新增领域概念 → 先提 PR 改 CONTEXT.md → 再写代码。
2. 代码标识符用英文，必须是词汇表右列的原文（如 `ToiletEvent`，不是 `BowelMovement`）。
3. 禁止同义词：一个概念只允许一个标识符。
4. 类型后缀含义固定：

| 后缀 | 含义 |
| --- | --- |
| `Plan` | 计划意图（未来） |
| `Task` / `Appointment` | 待办实例 |
| `Record` / `Event` | 实际事实（已发生） |
| `Confirmation` | 患者对某段时间的补充确认 |
| `Summary` | 汇总输出，不含结论 |
| `Trend` | 客观趋势展示 |

5. **禁用词**（出现在标识符、界面文案、注释里都算违规）：
   疾病活动度、缓解、复发、加重、评分、风险预测、trigger（作因果结论时）。
   对应英文：`diseaseActivity`、`remission`、`flare`、`severityScore`、`riskPrediction`、`trigger`。

## 文件名与目录名

- 类型名与文件名一致：`ToiletEvent.swift`。
- 目录名用复数表示集合：`Features/ToiletEvents/`。
