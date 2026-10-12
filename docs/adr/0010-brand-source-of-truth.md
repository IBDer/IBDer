# ADR-0010：品牌视觉以实际启用的 logo 与 banner 为准

- **状态**：已接受
- **日期**：2026-10-12

## 背景

`project-context/decisions/brand-direction.md` 的状态写着 "logo deferred"，主色方向描述为 terracotta / apricot / cocoa / aubergine。但组织已于 **2026-10-10** 启用新版 logo 与主页 banner（提交信息 `brand: replace profile banner with new IBDer logo`）。

两者只部分对应，导致 `docs/design/design-tokens.md` 出现「两个真源」。

## 决定

**品牌视觉以实际启用的 logo 与 banner 为准**（组织主页当前资产 `profile/assets/ibder-profile-banner.jpg`，2026-10-10 更新）。色板取自该资产实测：

`#1B133A` · `#2E1B4A` · `#302B50` · `#6C3474` · `#852E83` · `#9C42A4` · `#A85593` · `#D450B1` · `#DE858A` · `#F4779C` · `#FBB761` · `#EED1B4`

`brand-direction.md` 中的「暖陶土 / 杏色 / 可可 / 茄紫」描述与 "logo deferred" 状态视为**已被取代的历史记录**。

## 后果

- `docs/design/design-tokens.md` 的品牌色与之一致，不再需要第二个来源。
- `brand-direction.md` 中的 **logo 禁用清单与语气词仍然有效**——它们约束未来的图标工作，不因更换 logo 而失效。
- 将来若再次更换品牌资产，更新本 ADR，而不是新增一个并列真源。
