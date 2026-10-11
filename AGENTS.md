# Agent 工作约定

本文件是这个仓库里所有 AI agent 的入口。**动手前先读完本文件。**

## 1. 权威顺序

冲突时，序号小的赢：

1. 用户的当前指令
2. [IBDer/.github](https://github.com/IBDer/.github) 与 [IBDer/research](https://github.com/IBDer/research) 中**已由人类核验**的公开规则
3. 本仓库 `docs/adr/` 中的决定与 `openspec/specs/` 中的当前 spec
4. 已重新核验的原始来源（指南、药监、平台政策）
5. 历史资料、未核验草稿与非公开调研

> **未核验 = 只能当线索。** 判断一份文档是否已核验，看 [docs/inherited-documents.md](docs/inherited-documents.md) 的状态列；状态不是「已核验」的文档，不得作为实现依据，也不得被引用为「已经决定」。

## 2. 必读顺序

1. 本文件
2. [CONTEXT.md](CONTEXT.md) —— 术语必须从这里取
3. [docs/process/workflow.md](docs/process/workflow.md) —— 变更怎么走
4. 与任务相关的 `docs/` 与 `openspec/specs/`

## 3. 不可越线（医疗安全）

> **状态：待确认。** 以下四条来自未核验的 `SAFETY.md`（见 [docs/inherited-documents.md](docs/inherited-documents.md)）。人类维护者确认前，涉及这些范围的功能一律先问人、不得实现。

- 不诊断、不给个体化治疗建议、不做远程问诊或紧急分诊。
- **不自动判断疾病活动度**：不显示分数、不给出「缓解 / 活动 / 复发 / 需要加药」这类结论，不把患者报告项命名为 HBI / SCCAI / Mayo / CDAI / PRO2。
- 不声称食物导致症状的因果关系。
- 不复制未经权利核验的量表文字、图示、译本。
- 首版不开放患者社区 UGC。

任何功能只要落在上述范围内，**先停下来问人**，不要实现。

## 4. 数据与隐私

- 只用**合成测试数据**。真实或可识别的患者数据不得进入仓库、Issue、Discussion、日志、截图或第三方 AI 服务。
- 应用内不得把健康内容上报给崩溃 / 分析 SDK。
- 未经明确决定，不引入会把健康数据传出设备的依赖。

## 5. 内容来源纪律

- 私有调研仓库（project-context）中的原文**不得直接搬运**到本仓库。需要引用时，重新核验公开来源，用自己的话写，并标注来源与不确定性。
- 区分**事实 / 解释 / 产品假设 / 项目决定**，不要把后三者写成第一者。
- 引用法规与政策时只使用官方来源，记录地区、有效期与核验日期。

## 6. 工作流（唯一真相源：OpenSpec）

```
grilling / explore 想清楚
  → openspec change（proposal + delta spec + tasks）
      → 【闸门 1：人评审 spec】        ← 需求不对就不动手
          → 实现（TDD）
              → PR（附 CI 证据）
                  → 【闸门 2：人评审代码】 → 合并 → archive
```

- **OpenSpec 是「系统现在是什么样」的唯一权威**。GitHub Issues 只做看板，不承载 spec。
- GitHub Issues 不作为第二个真相源；两者冲突时以 `openspec/` 为准。
- 未通过闸门 1 的 change，不得开始写实现代码。

## 7. 提交与评审

- 一个 change 一个分支：`change/<change-name>`。
- PR 必须包含四件事：关联的 OpenSpec change、改了什么、CI 结果、风险与回滚方式。
- CI 红的树上不得继续提交。
- 合并由人执行；agent 不自行合并、不自行打 tag。
- 每个完成并归档的 change 打一个 tag。

## 8. 语言

- 文档、Issue、PR、提交信息的正文：**中文**。
- 代码标识符与代码注释：**英文**（标识符必须取自 [CONTEXT.md](CONTEXT.md)）。
- 面向患者的界面文案：中文，且不得出现医学结论。

## 9. AI 参与披露

重要内容（规范、需求、设计决定）由 AI 起草时必须可追溯，并在 PR 中说明；最终责任由人类维护者承担。公开发布的内容按组织模板标注 AI 参与情况。
