# IBDer App

面向克罗恩病（CD）与溃疡性结肠炎（UC）患者的自我管理工具：记录饮食、排便、用药、症状与诊疗事件，并把一段时间的事实整理成能带进诊室的复诊摘要。

> **当前状态：规范与需求定义阶段，尚未编写应用代码。**
> 先定规范，再定需求，最后才写代码。

## 阶段

| 阶段 | 状态 |
| --- | --- |
| 仓库规范 / 设计规范 / CI / 测试方式 | 评审中 |
| 需求与范围（第一个 OpenSpec change） | 未开始 |
| 应用代码 | 未开始 |

## 医疗边界

本项目**当前不预设**医疗安全红线——相关约束随功能逐个决定并记录成 ADR（见 [ADR-0008](docs/adr/0008-no-standing-red-lines.md)）。

但下列范围在实现前**必须先由人类维护者做出明确决定**，不得先做后问：

- 诊断、个体化治疗建议、远程问诊或紧急分诊
- 疾病活动度评分，以及「缓解 / 活动 / 复发」这类结论性输出
- 食物与症状之间的因果表述
- 患者社区 UGC
- 临床量表的名称、文字、图示与译本

数据方面始终成立：**不在**仓库、Issue、Discussion、日志、截图或测试数据中出现可识别的患者信息。

组织层公开规则以 [IBDer/.github](https://github.com/IBDer/.github) 与 [IBDer/research](https://github.com/IBDer/research) 中**已核验**的内容为准。

## 文档地图

| 想知道什么 | 看哪里 |
| --- | --- |
| Agent 怎么在这个仓库里工作 | [AGENTS.md](AGENTS.md) |
| 领域术语（中文 / 代码标识符） | [CONTEXT.md](CONTEXT.md) |
| 为什么这样决定 | [docs/adr/](docs/adr/) |
| 工程规范（架构 / 风格 / 命名 / 日志） | [docs/engineering/](docs/engineering/) |
| 设计规范（颜色 / 动效 / 无障碍） | [docs/design/](docs/design/) |
| 流程（OpenSpec / 评审 / 测试 / CI） | [docs/process/](docs/process/) |
| 系统当前行为（唯一真相源） | [openspec/specs/](openspec/specs/) |
| 进行中的变更 | [openspec/changes/](openspec/changes/) |

## 许可

软件代码采用 Apache-2.0，见 [LICENSE](LICENSE)。组织内的研究与文档采用 CC BY 4.0。
