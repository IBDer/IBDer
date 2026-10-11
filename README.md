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

## 边界（不可越线）

- 不诊断、不给个体化治疗建议、不提供远程问诊或紧急服务。
- **不自动计算或展示疾病活动度评分**（不出现 HBI / SCCAI / Mayo / CDAI / PRO2 的分数或「缓解 / 活动 / 复发」结论）。
- 不宣称食物与症状之间的因果关系。
- 不在仓库、Issue、Discussion、测试数据中出现可识别的患者信息。
- 不使用未完成权利核验的临床量表名称、图示或译本。

完整公开规则以 [IBDer/.github](https://github.com/IBDer/.github) 与 [IBDer/research](https://github.com/IBDer/research) 为准。

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
