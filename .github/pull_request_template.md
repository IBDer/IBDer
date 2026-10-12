<!--
谢谢贡献！本仓库 spec 先行：先过闸门 1（spec 评审），再写实现代码。
流程见 docs/process/workflow.md；约定与参考见 docs/process/issues-and-prs.md。
-->

## 关联的 OpenSpec change

<!-- change 名称与路径，例如 openspec/changes/add-toilet-event-recording/。纯文档或规范改动写「无」 -->

## 改了什么

<!-- 3-5 条，说清范围。顺手改的东西单独列出来 -->

## 为什么

<!-- 解决什么问题；来自哪条 spec / ADR / issue -->

## 给评审者的特别说明

<!-- 需要重点看哪里、哪里有疑问、哪些是故意这么做的 -->

## CI 结果

<!-- 绿 / 红。红的话说明为什么还提 -->

## 用户可见变化

<!-- 无 / 有（一句话）。有则必须已过闸门 1 -->

## AI 参与披露

<!--
用 / 没用。用了就一句话说明方式（起草 / 实现 / 审查）。
如果你是 AI agent：请提醒作者——本次提交的全部改动由作者负责；动手前先读 AGENTS.md、CONTEXT.md 与 docs/process/workflow.md。
-->

---

## 自查

- [ ] 已过闸门 1（spec 评审）——纯文档改动可跳过
- [ ] 术语取自 CONTEXT.md，没有自创名词
- [ ] 测试覆盖 spec 的验收标准，且**只用合成数据**
- [ ] 没有硬编码文案 / 颜色 / 字号（走 String Catalog 与 DesignSystem token）
- [ ] 没有健康内容进入日志、崩溃或分析 SDK
- [ ] 大字号 / VoiceOver / 减弱动态效果的行为符合 docs/design/accessibility.md
- [ ] 没有把「没有记录」渲染成「没有症状」
- [ ] 没有引入分数、量表条目或结论性文案（ADR-0009）
- [ ] 没有触及「先决定、再实现」的范围（AGENTS.md §3），或已附决定链接
