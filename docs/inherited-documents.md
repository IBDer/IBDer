# 继承来的文档：来源与核验状态

本项目开始之前，组织里已经存在一批文档。它们由账号 `Zachary-wW` 在 2026-10-08 至 10-10 提交，但**尚未经过人类逐份核验**。

**规则：状态不是「已核验」的文档只能当线索，不能当依据。**（见 [AGENTS.md](../AGENTS.md) 第 1 节）

## 清单

| 文档 | 仓库 | 引入提交 | 日期 | 状态 | 现在被用在什么地方 |
| --- | --- | --- | --- | --- | --- |
| `SAFETY.md` | IBDer/.github | 92907297 | 10-09 | **未核验** | AGENTS.md 第 3 节的四条红线（待确认） |
| `AI_COLLABORATION.md` | IBDer/.github | 92907297 | 10-09 | **未核验** | AGENTS.md 第 9 节的 AI 披露 |
| `PRIVACY.md` | IBDer/.github | 92907297 | 10-09 | **未核验** | 只用合成测试数据 |
| `GOVERNANCE.md` `ROADMAP.md` `CONTRIBUTING.md` `RESEARCH_POLICY.md` | IBDer/.github | 9ada592f / 92907297 | 10-08/09 | **未核验** | 未使用 |
| `decisions/project-direction.md` | project-context（私有） | 48637080 | 10-08 | **未核验** | 初版曾当既定约束，现降级为线索 |
| `decisions/community-direction.md` | project-context（私有） | — | 10-09 | **未核验** | 未使用 |
| `decisions/brand-direction.md` | project-context（私有） | — | 10-08 | **未核验** | 设计 token 的暖色方向参考 |
| `product/rebuild-brief.md` | project-context（私有） | 48637080 | 10-08 | **未核验** | 「先定问题与规范，再选技术栈」 |
| `product/legacy-domain-language.md` | project-context（私有） | 48637080 | 10-08 | **未核验** | **CONTEXT.md 词汇表的全部来源** |
| `product/legacy-product-learnings.md` | project-context（私有） | — | 10-08 | **未核验** | 「不继承旧决定」的清单 |
| `research/`（私有，5 份长文） | project-context（私有） | — | 10-08/09 | **未核验** | 领域与合规的背景输入 |
| `research/`（公开） | IBDer/research | 3 个提交 | 10-08/09 | **未核验** | 未使用 |

> 提交身份说明：`Zachary-wW <zhihaowei1117@gmail.com>` 是本地 git 客户端；`Zachary WEI <124166324+Zachary-wW@users.noreply.github.com>` 是 GitHub 网页编辑器或 API 写入。**git 无法区分「人写的」与「agent 代为写的」**，因此本表只记录事实，不判断作者。

## 核验方式

对每一份，人类维护者给出三种结论之一：

- **核验**：内容可接受，可作为依据（状态列改为「已核验 + 日期」）。
- **修改**：指出要改的地方，改完再核验。
- **废弃**：不作为依据；依赖它的仓库内容同步删除或改写。

## 依赖关系（核验结果出来前不要动的东西）

| 如果这份被废弃或改写 | 需要一起改 |
| --- | --- |
| `SAFETY.md` 的四条红线 | 已按 [ADR-0008](adr/0008-no-standing-red-lines.md) 决定**不预设**；将来逐条决定时再引用 |
| `legacy-domain-language.md` | [CONTEXT.md](../CONTEXT.md) 全部术语、[naming.md](engineering/naming.md) 的后缀表与禁用词 |
| `brand-direction.md` | [design-tokens.md](design/design-tokens.md) 的配色方向 |
| `rebuild-brief.md` 的 Planning standard | [workflow.md](process/workflow.md) 的闸门 1 |
