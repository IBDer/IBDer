# 流程：OpenSpec 与两个人工闸门

**状态：初稿，待评审。**

## 唯一真相源

- **系统现在是什么样** → `openspec/specs/`
- **正在改什么** → `openspec/changes/<change-name>/`
- **为什么这样决定** → `docs/adr/`
- GitHub Issues 只做「此刻谁在做哪条」的看板，**不承载 spec**。

## 一个 change 的生命周期

```
1. 想清楚        grilling / explore（不写代码、不写 spec）
2. 写 change      openspec propose → proposal + delta spec + tasks
3. 【闸门 1】     人类评审 spec：需求、非目标、验收标准、隐私与安全影响
4. 实现          TDD；一个 change 一个分支 change/<name>
5. 提 PR         openspec change 链接 + 改了什么 + CI 结果 + 风险与回滚
6. 【闸门 2】     人类评审代码
7. 合并          由人类执行
8. 归档          archive → delta 合并进主 spec；打 tag
```

**未通过闸门 1 不得开始实现。** 这是本仓库最容易破的规矩，也是返工成本最高的一条。

## 闸门 1 的评审清单

- [ ] 说清了要解决的患者问题，以及证据来自哪里
- [ ] 写明了非目标（这次**不做**什么）
- [ ] 每条验收标准可被测试或人工验证
- [ ] 隐私影响：数据从哪来、存哪、是否离开设备
- [ ] 边界影响：输出的是「患者记录的事实」还是「产品下的结论」。评分类输出已由 [ADR-0009](../adr/0009-no-scores-in-v1.md) 决定**首版不做**；涉及因果、诊疗建议、社区 UGC 的，必须先有明确决定
- [ ] 是否需要新术语；需要则先改 CONTEXT.md

## 闸门 2 的评审清单

- [ ] 与 spec 一致；有偏差则 spec 先更新
- [ ] 测试覆盖了 spec 里的验收标准
- [ ] 无硬编码文案、颜色、字号
- [ ] 无健康内容进入日志
- [ ] 大字号 / VoiceOver / 减弱动态效果的行为符合规范
- [ ] 没有顺手做 spec 之外的事

## 分支、提交与 tag

- 分支：`change/<change-name>`；文档类：`docs/<topic>`。
- 提交信息：中文正文，一行说清做了什么。
- agent **不自行合并**、**不自行打 tag**。
- 归档后由人类打 tag（`v0.x.0`）。
