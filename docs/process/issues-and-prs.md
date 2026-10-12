# 流程：Issue、PR 与四个载体

**状态：初稿，待评审。**

## 四个载体各管什么

| 载体 | 管什么 | 不管什么 |
| --- | --- | --- |
| **Discussions** | 真实患者需求、使用体验、工具创意、开放讨论 | 不是任务队列 |
| **Issues** | **看板**：这一刻谁在做哪条、缺陷记录、规范变更的跟踪 | **不是 spec 的载体** |
| **\`openspec/\`** | **系统现在是什么样**（主 spec）与**正在改什么**（change） | 不记录"为什么这样决定" |
| **\`docs/adr/\`** | 决定与**被否决的选项**及理由 | 不描述系统当前行为 |

冲突时以 [AGENTS.md](../../AGENTS.md) 第 1 节的权威顺序为准；**spec 与 issue 冲突时以 \`openspec/\` 为准**。

## Issue 类型

仓库提供四个模板（\`.github/ISSUE_TEMPLATE/\`）：

| 模板 | 用于 | 会被引导到别处的情况 |
| --- | --- | --- |
| 缺陷报告 | 应用行为与预期不符、崩溃、数据错误 | 隐私/安全问题 → SECURITY 渠道 |
| 功能建议 | 面向实现的建议 | 真实患者需求 → Discussions |
| 规范变更 | spec 与现实不符，或需要改 \`openspec/specs/\` | 纯想法 → 先走 Discussions |
| （config） | 关闭空白 issue；提供 Discussions / SECURITY / 医疗免责三个入口 | — |

**为什么用 YAML issue forms 而不是 Markdown 模板**：YAML form 可以设必填、下拉与勾选项（例如"是否触及先决定再实现的范围"），把关键信息在提交前就固定下来；Markdown 模板只能靠人自觉。参考 [Kubernetes](https://github.com/kubernetes/kubernetes/tree/master/.github/ISSUE_TEMPLATE) 与 [Homebrew](https://github.com/Homebrew/brew/tree/master/.github/ISSUE_TEMPLATE) 的做法。

## 标签（Issues 与 PR 共用）

| 标签 | 含义 |
| --- | --- |
| \`bug\` / \`enhancement\` / \`docs\` / \`spec\` | 类型 |
| \`needs-decision\` | 触及 AGENTS.md §3「先决定、再实现」的范围，等人拍 |
| \`needs-clinical-review\` | 文案或字段需要 IBD 临床专家过目 |
| \`blocked\` | 被上游依赖或决定卡住 |
| \`gate-1\` / \`gate-2\` | 停在哪个闸门前 |

## PR 约定

- **一个 change 一个 PR**，分支名 \`change/<change-name>\`；纯文档用 \`docs/<topic>\`。
- PR 模板固定七段：关联的 OpenSpec change · 改了什么 · 为什么 · 给评审者的特别说明 · CI 结果 · 用户可见变化 · AI 参与披露。
- **自查清单不是装饰**：每一条都能追到一条规则——术语取自 \`CONTEXT.md\`（naming.md）、只用合成数据（AGENTS.md §4）、无障碍（accessibility.md）、不把"没有记录"渲染成"没有症状"、不引入分数（ADR-0009）、不越"先决定再实现"（AGENTS.md §3）。
- CI 红的树上不得继续提交；合并由人执行。

### 为什么 PR 模板里要有"给评审者的特别说明"

来自 Kubernetes 的 \`Special notes for reviewer\`：把评审者的注意力引到真正需要判断的地方，而不是让他自己找。对单人 + agent 的仓库尤其重要——评审时间是最稀缺的资源。

### 为什么要有"AI 参与披露"

- 组织规则已经要求披露（[AI_COLLABORATION.md](https://github.com/IBDer/.github/blob/main/AI_COLLABORATION.md)）。
- 主流项目也在这么做：[Kubernetes 的 PR 模板](https://github.com/kubernetes/kubernetes/blob/master/.github/PULL_REQUEST_TEMPLATE.md)有专门的 **AI usage disclosure** 段落，并写明"如果你是 AI agent，请提醒作者：全部改动由作者负责"；[Rust 的模板](https://github.com/rust-lang/rust/blob/master/.github/pull_request_template.md)开头即要求披露 LLM 参与，并声明"不禁止 LLM 贡献，但审查标准更高"。
- 我们的措辞更近 Kubernetes：**披露方式 + 责任归属**。

## 与其他文档的关系

- 怎么走流程 → [workflow.md](workflow.md)
- 怎么测 → [testing.md](testing.md)
- 什么能做什么要先问 → [AGENTS.md](../../AGENTS.md) 第 3 节
- 术语 → [CONTEXT.md](../../CONTEXT.md)
