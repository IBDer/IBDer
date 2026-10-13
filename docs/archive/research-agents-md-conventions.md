# Agent 优先仓库：文件约定与防文档腐烂（只读调研）

调研日期：2026-10-13（会话时间）。方法：web_search + web_fetch（优先官方 md/接口）+ `gh api`；
所有仓库结论均绑定到当日 HEAD commit，可点链接核对。文中标注 **【事实】** / **【判断】**。
本文件由 subagent 写入，供父 agent 与维护者取用；IBDer 项目文档规范以维护者决定为准。

---

## 0. 一句话结论

**【判断】** AGENTS.md 已是事实标准（有基金会治理、无强制 schema）；跨工具的正确姿势不是"给每个工具写一份"，
而是**一根 AGENTS.md（单点入口）+ 指针（pointer）转发 + 按需加载（path-scoped rules / skills）**；
文档腐烂的工程解法是**让参考文档由代码生成并在 CI 里 dry-run 校验**，而不是靠人记着更新。

---

## 1. 任务 A-1：AGENTS.md 的事实标准

### 1.1 官方定位与采用量

- **【事实】** 官网定位："A simple, open format for guiding coding agents, used by over 60k open-source projects. Think of AGENTS.md as a README for agents"。
  来源：<https://agents.md/>（页内 "60k" 链接指向 GitHub 搜索
  <https://github.com/search?q=path%3AAGENTS.md+NOT+is%3Afork+NOT+is%3Aarchived&type=code>）。
- **【事实】** 仓库 agentsmd/agents.md：24,898 stars，创建 2025-08-19，最近推送 2026-09-10，MIT。
  来源：<https://github.com/agentsmd/agents.md>（`gh api repos/agentsmd/agents.md`）。
- **【事实】** 治理：网站 About 段落写 "AGENTS.md is now stewarded by the Agentic AI Foundation under the Linux Foundation"，
  并链到 <https://aaif.io>。来源：仓库源码
  [components/AboutSection.tsx](https://github.com/agentsmd/agents.md/blob/main/components/AboutSection.tsx)。
- **【事实】** Linux Foundation 2025-12-09 公告：AAIF 成立，创始贡献项目为 Anthropic MCP、Block goose、OpenAI AGENTS.md；
  公告原文称 "AGENTS.md is a simple, universal standard that gives AI coding agents a consistent source of project-specific guidance"。
  来源：<https://aaif.io/news/linux-foundation-announces-formation-of-aaif>；项目页 <https://aaif.io/projects>。

### 1.2 有没有官方 spec？

- **【事实】** 没有强 schema。官网 FAQ 原文："Are there required fields? **No.** AGENTS.md is just standard Markdown.
  Use any headings you like; the agent simply parses the text you provide."
  来源：<https://agents.md/>（FAQ 段）。
- **【事实】** 唯一被官方写死的规则是**冲突分层**："The closest AGENTS.md to the edited file wins; explicit user chat prompts
  override everything."（FAQ）。以及 "Large monorepo? Use nested AGENTS.md files for subprojects … the closest one takes
  precedence"，并给出规模样本 "at time of writing the main OpenAI repo has 88 AGENTS.md files"。
- **【事实】** 官方推荐的起步章节：Project overview / Build and test commands / Code style guidelines /
  Testing instructions / Security considerations。
- **【判断】** 因此"AGENTS.md 规范"实质等于：**文件名 + 就近覆盖 + 纯 Markdown**。可校验性来自各工具实现，不来自 spec。
  仓库里那份 `Technical_Charter.pdf`（229 KB）是治理文件，不是格式规范（`gh api repos/agentsmd/agents.md/contents`）。

### 1.3 OpenAI / Codex 的用法

- **【事实】** Codex 仓库自己把文档外置：其 `docs/agents_md.md` 全文只有一行
  "For information about AGENTS.md, see [this documentation](https://developers.openai.com/codex/guides/agents-md)."
  且 `docs/` 下几乎全是 84–726 字节的指针存根（`docs/config.md` 726B、`docs/sandbox.md` 150B…）。
  来源：[openai/codex docs/agents_md.md](https://github.com/openai/codex/blob/main/docs/agents_md.md)。
- **【事实·限制】** `developers.openai.com` 对抓取返回 403，本次未能取得 Codex 官方 AGENTS.md 指南原文；
  关于 Codex 的加载/分层描述以 agents.md 官网 + GitHub Copilot 官方文档为证。

---

## 2. 任务 A-2：主流 agent 工具各读什么文件 / 有没有权威对照 / 冲突怎么分层

### 2.1 权威对照表（GitHub 官方文档，覆盖面最广）

- **【事实】** GitHub 的 *Support for different types of custom instructions* 明确列出各环境支持的文件：
  GitHub.com 的 Copilot cloud agent：`.github/copilot-instructions.md`、`.github/instructions/**/*.instructions.md`、
  以及 **agent instructions 用 `AGENTS.md`、`CLAUDE.md` 或 `GEMINI.md`**；Copilot code review 还额外支持 `REVIEW.md`。
  来源：<https://docs.github.com/en/copilot/reference/custom-instructions-support>。
- **【事实】** 同文档的仓库自定义指令篇写："You can create one or more `AGENTS.md` files, stored anywhere within the
  repository. When Copilot is working, **the nearest `AGENTS.md` file in the directory tree will take precedence**.
  … Alternatively, you can use a single `CLAUDE.md` or `GEMINI.md` file stored in the root of the repository."
  来源：<https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions>
  （markdown 正文接口：`https://docs.github.com/api/article/body?pathname=/en/copilot/how-tos/...`）。
- **【判断】** 这是目前**唯一一份厂商官方、跨工具**的对照（但只覆盖 Copilot 各形态）。没有中立机构发布的
  "Codex vs Claude Code vs Cursor vs Copilot vs Gemini CLI" 权威对照表；网上那些对比文章多为二手解读，不建议作依据。

### 2.2 各工具逐条（每条给一手链接）

| 工具 | 读什么 | 分层/优先级 | 来源 |
|---|---|---|---|
| Codex (OpenAI) | `AGENTS.md`（仓库根与子目录） | 就近文件优先；用户对话指令覆盖一切 | [agents.md](https://agents.md/)（OpenAI 为共同作者）；[openai/codex docs/agents_md.md](https://github.com/openai/codex/blob/main/docs/agents_md.md) |
| Claude Code | `CLAUDE.md` 或 `.claude/CLAUDE.md`；**也读 `AGENTS.md`** | 加载顺序由宽到窄：Managed policy → `~/.claude/CLAUDE.md` → `./CLAUDE.md`/`./.claude/CLAUDE.md` → `./CLAUDE.local.md`（越具体越后加载）；上层目录启动时加载，子目录按需加载 | [code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory) |
| Claude Code（组合） | `@path/to/file` 导入语法，最多 4 跳 | "Imports help you organize a long file but **don't reduce its context cost**, because imported files also load at launch" | 同上 |
| Cursor | `.cursor/rules/*.mdc`（frontmatter: `description`/`globs`/`alwaysApply`），**或** `AGENTS.md` | 规则四态：Always Apply / Apply Intelligently / Apply to Specific Files / Apply Manually；官方称 AGENTS.md 是 "Simple alternative to `.cursor/rules`" | <https://cursor.com/docs/rules>（`.md` 正文 <https://cursor.com/docs/rules.md>） |
| GitHub Copilot | `.github/copilot-instructions.md`、`.github/instructions/*.instructions.md`、`AGENTS.md`/`CLAUDE.md`/`GEMINI.md` | 见 2.1：目录树中**最近**的 AGENTS.md 生效 | 见 2.1 链接 |
| Gemini CLI | `GEMINI.md` 为默认；`context.fileName` 可改成字符串或数组（官方示例 `["AGENTS.md","CONTEXT.md","GEMINI.md"]`） | **三层拼接**：全局 `~/.gemini/GEMINI.md` → 工作区及其父目录 → 工具访问文件时的 JIT 目录扫描；"concatenates the contents of all found files" | [docs/cli/gemini-md.md](https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/gemini-md.md)、[config.ts](https://github.com/google-gemini/gemini-cli/blob/main/packages/core/src/config/config.ts)（`contextFileName?: string \| string[]`） |
| Gemini CLI（导入） | `@file.md` 导入 | 支持相对/绝对路径 | 同上 |

- **【事实】** Gemini CLI 默认文件名需要自行配置才读 AGENTS.md（`setGeminiMdFilename(params.contextFileName)`，
  见 config.ts L1412-L1414）；agents.md 官网把它列进兼容名单，链接指向 Gemini 的 settings 文档，属于"可配置支持"。
- **【事实】** Aider 需要显式配置：官网 FAQ 给 `.aider.conf.yml` → `read: AGENTS.md`。

### 2.3 冲突时分层的三档（综合官方原文的**【判断】**）

1. **用户当前指令**最高（agents.md FAQ: "explicit user chat prompts override everything"）。
2. **就近文件覆盖远处文件**（agents.md FAQ；GitHub Copilot 文档同款措辞 "nearest … takes precedence"）。
3. **工具专属文件与 AGENTS.md 并存时**：没有统一规范，各工具自行决定（Claude Code 会同时加载 CLAUDE.md 与 AGENTS.md；
   Copilot 若指定了 `CLAUDE.md`/`GEMINI.md` 则作为替代）。**【判断】** 这正是"不要给每个工具写一份"的硬理由。

---

## 3. 任务 A-3：4 个真实且活跃的 agent 优先仓库（结构与单一真相源）

以下按 2026-10-13 HEAD 固定，链接可直接点开核对。

### 3.1 getsentry/sentry（指针 + symlink 单源，最值得抄）

- **【事实】** `CLAUDE.md` 全文 11 字节，内容为 `@AGENTS.md`，即 Claude Code 的导入语法把根 `AGENTS.md` 当唯一真相源。
  <https://github.com/getsentry/sentry/blob/2cfdf473/CLAUDE.md>；HEAD `2cfdf4734137083b1d7e9c83166ab98fd49eae4a`（2026-10-13）。
- **【事实】** 根 `AGENTS.md`（7,861 B）里写了"禁止重复"的规矩，原文：
  "Workflow steering (commit, pre-commit, hybrid cloud, etc.) lives in **skills** (`.agents/skills/`). Attach or read the
  area `AGENTS.md` when working in that tree. **Add or update guidance in the appropriate AGENTS.md or skill—do not
  duplicate long guidance in editor-specific rule files.**"
  <https://github.com/getsentry/sentry/blob/2cfdf473/AGENTS.md>
- **【事实】** 规模：仓库内 5 个 `AGENTS.md`、4 个 `CLAUDE.md`（后者皆指针），`.agents/skills/` 下 136 个文件（`gh api` git tree 统计）。
- **【事实】** 能力不用"文档"维护，而用清单维护：`agents.toml` 用 `pin = false` + `source = "getsentry/skills"` 把
  skills 直接指向外部仓库，`agents = ["claude","cursor"]` 声明目标工具。
  <https://github.com/getsentry/sentry/blob/2cfdf473/agents.toml>

### 3.2 microsoft/vscode（根文件 271 B，纯指针）

- **【事实】** 根 `AGENTS.md` 271 字节，全文主旨一行：
  "For detailed project overview, architecture, coding guidelines, and validation steps, see the
  [Copilot Instructions](.github/copilot-instructions.md)."
  <https://github.com/microsoft/vscode/blob/0ea598a4/AGENTS.md>
- **【事实】** 真正内容在 `.github/copilot-instructions.md`（12,759 B / 162 行），把项目结构、验证命令、
  搜索策略一次讲清；仓库内共 8 个 `AGENTS.md`（按目录就近生效），另有 `.agents/skills/launch/SKILL.md` 这类按需技能。
- **【判断】** 这是"**根文件是指针、真相源只有一个**"的最小可抄实现，也回避了"根文件越写越长"。

### 3.3 astral-sh/uv（单文件规则 + 代码生成文档 + CI 漂移门禁）

- **【事实】** 根 `AGENTS.md` 3,505 B，全是可执行祈使句（ALWAYS/NEVER/PREFER/AVOID），例如
  "NEVER perform builds with the release profile, unless asked or reproducing performance issues"、
  "ALWAYS check whether the behavior of a new test is already covered by an existing test"，
  并以 "Read CONTRIBUTING.md for guidelines on how to run tools" 把流程外链。
  <https://github.com/astral-sh/uv/blob/59e5912e/AGENTS.md>
- **【事实】** 文档站 `mkdocs.yml`（11,573 B）挂 `llmstxt` 插件，并为 agent 写了抓取说明：
  "When fetching documentation, use explicit `index.md` paths for directories … This returns clean markdown instead of
  rendered HTML with JS/CSS." <https://github.com/astral-sh/uv/blob/59e5912e/mkdocs.yml>
- **【事实】** CI 有专门的 `check-docs.yml`：先跑 `cargo dev generate-options-reference`、
  `generate-cli-reference`、`generate-env-vars-reference`、`generate-preview-features-reference`，
  再 `mkdocs build --strict`。<https://github.com/astral-sh/uv/blob/59e5912e/.github/workflows/check-docs.yml>

### 3.4 vercel/next.js（反例兼正面：28 KB 大文件 + 技能准入规则）

- **【事实】** 根 `AGENTS.md` 28,678 B，一个文件承载结构、命令、测试、lint、PR、上下文节省、提交规范等 40+ 章节；
  另要求"编辑任何子目录前，先读从根到目标目录的所有 README"；仓库内 9 个 `AGENTS.md`。
  <https://github.com/vercel/next.js/blob/6e107283/AGENTS.md>
- **【事实】** 它给"技能"写了**准入与拒绝条件**（少见，值得抄）：
  "Create a skill when content is: **Too detailed for AGENTS.md** … **Only relevant for specific tasks** …
  Do NOT create a skill for: One-liner rules or guardrails (keep those in AGENTS.md); Content every agent session
  needs (that's what AGENTS.md is for); Simple facts without actionable steps."
  <https://github.com/vercel/next.js/blob/6e107283/.agents/skills/README.md>
- **【判断】** 可见 .agents/skills/README.md 与 AGENTS.md 的关系被写成"显式二分"。其余仓库（Vue、Bitwarden 等）也在往该结构收敛。

### 3.5 补充样本：bitwarden/clients（层叠文件 + 外链文档枢纽）

- **【事实】** 仓库**没有根 AGENTS.md**，而是 `.claude/CLAUDE.md` 作枢纽：列出"read on demand"（README/CONTRIBUTING）、
  `@../.github/PULL_REQUEST_TEMPLATE.md` 导入、Critical Rules、monorepo 边界、验证命令，末尾把架构/ADR/风格全部外链到
  `contributing.bitwarden.com`；`.claude/rules/` 下 10 个主题文件（angular / testing / tailwind / i18n …）按路径生效。
  <https://github.com/bitwarden/clients/blob/73d72d8d/.claude/CLAUDE.md>
- **【事实】** `docs/` 只有 2 个文件（`cipher-types.md`、`using-nx-to-build-projects.md`），`CONTRIBUTING.md` 313 字节、
  只负责把贡献者导向外部文档站。<https://github.com/bitwarden/clients/blob/73d72d8d/CONTRIBUTING.md>

### 3.6 结构化归纳：根目录 / docs / 单一真相源 / 数量控制

| 维度 | 观察到的做法（事实） | 代表链接 |
|---|---|---|
| 根目录放什么 | 只放**入口**：`AGENTS.md`（可短到 271 B 的纯指针）、`CONTRIBUTING.md`（可短到外链）、`README.md`；工具专属文件（`CLAUDE.md`）当指针 | vscode、sentry、bitwarden |
| docs/ 放什么 | 参考手册（CLI/配置/API）**由源码生成**或外置到独立文档站；仓库内 docs 只放人读的少量主题 | uv、bitwarden、openai/codex |
| 单一真相源 | 一条链：`AGENTS.md`（或外部文档站）为源 → `CLAUDE.md` = `@AGENTS.md` / 指针 → 工具专属规则只做转发 | sentry、vscode |
| 数量控制 | 显式"该不该新建文档/技能"的准入规则；把细则下沉到按需加载层（`.claude/rules/`、`.agents/skills/`） | next.js `.agents/skills/README.md` |
| 规模化 | 复用**嵌套 AGENTS.md**（vscode 8 个、next.js 9 个、sentry 5 个）而非堆一个巨型文件 | agents.md 官网 monorepo 段 |

---

## 4. 任务 A-4：如何防止文档腐烂（doc rot）

### 4.1 事实：真实存在的机制

1. **生成式文档 + CI 漂移门禁（最强）**
   - uv：`cargo dev generate-all --mode dry-run` 等 check 步骤进 CI；
     `check-generated-files.yml` 里包括 `generate-all --mode dry-run`、`generate-sysconfig-metadata --mode check`、
     `generate-scenario-tests --mode check`、`generate-json-schema --mode check`、`generate-dirhash-test-vectors --mode check`。
     <https://github.com/astral-sh/uv/blob/59e5912e/.github/workflows/check-generated-files.yml>
   - uv 的 CONTRIBUTING "Linting" 清单里也写了 `# Generated files` → `cargo dev generate-all --mode dry-run`，
     即**人也在本地跑同一道闸**。<https://github.com/astral-sh/uv/blob/59e5912e/CONTRIBUTING.md>
2. **严格构建（strict build）**：uv 的 `check-docs.yml` 用 `mkdocs build --strict`，断链/缺页直接失败。
3. **提示词审计（工具内置）**：Claude Code `/doctor prompt-audit` 专门找"写给旧模型的指令、指向不存在的文件/命令、
   互相矛盾的说明"，覆盖 `CLAUDE.md`/`CLAUDE.local.md`/`AGENTS.md` 以及 `.claude/` 下的 rules/skills/commands/subagents。
   原文："Claude looks for problems such as instructions written for older models, references to files or commands that
   don't exist, and files that contradict each other."（需 v2.1.283+）
   <https://code.claude.com/docs/en/memory>
4. **把生成流程图交给文档技能**：next.js `.agents/skills/docs-diagrams/` 内含 `review-checklist.md`、
   `scripts/gen.mjs`、`scripts/measure.py`、`scripts/render.sh`、`style-tokens.md`（`gh api` 树列表），
   即"图由脚本生成"而不是手画。
5. **学术证据（有量化）**：Treude & Baltes, *Context Rot in AI-Assisted Software Development*（arXiv 2606.09090, 2026-06-08）
   摘要原文："applying an existing README/wiki consistency checker to a statistically representative sample of 356
   repositories identifies stale code element references in **23.0% of repositories**"。
   <https://arxiv.org/abs/2606.09090>
6. **没有任何机制的例子**：本次抽查的 5 个活跃仓库里，**只有 uv** 对"仓库内 markdown 是否与代码一致"设了 CI 门禁；
   vscode / next.js / sentry / bitwarden 都靠"减少指向 + 就近覆盖 + 外链文档站"降低腐烂面，而不是检测腐烂。

### 4.2 判断：三种"防腐"策略的性价比

- **【判断】生成 > 校验 > 人工。** 只要参考文档是生成的，就根本不存在"忘了更新"这一失败模式（uv 模式）。
- **【判断】指针化是第二优。** 减少对代码符号的直接引用（"Minimal pointer-style configs: a CLAUDE.md that is a
  30-line pointer table with zero direct code references has nothing to drift"，见 agentpatterns 的
  [Stale AI Configuration Artifacts](https://agentpatterns.ai/anti-patterns/stale-ai-configuration-artifacts/)——
  该站为二手来源，其引用的 [arXiv 2606.09090](https://arxiv.org/abs/2606.09090) 是一手）。
- **【判断】最差是"多份副本 + 无门禁"**：每多一个工具专属副本，就多一份需要同步的腐烂面。

---

## 5. 特别关注：过度文档化的反面 vs "少而准"的正面

### 5.1 反面案例（都有证据，不点名批评、只描述规模）

- **【事实】28 KB 单文件**：next.js 根 `AGENTS.md` 28,678 B（≈ 700+ 行）；对比 vscode 根文件 271 B。
  <https://github.com/vercel/next.js/blob/6e107283/AGENTS.md>
- **【事实】官方给过尺寸上限**：Claude Code 文档 "Size: **target under 200 lines per CLAUDE.md file**. Longer files
  consume more context and **reduce adherence**." <https://code.claude.com/docs/en/memory>
- **【事实】"格式化"不等于会读**：`@import` "don't reduce its context cost, because imported files also load at launch"（同上）。
- **【事实】会自动拼接的工具风险更大**：Gemini CLI 会把找到的 GEMINI.md 全部拼接（JIT 扫描目录祖先），
  文件越多、目录越深，注入量越不可控。<https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/gemini-md.md>
- **【事实·误读警告】** GitHub 博客《How to write a great agents.md: Lessons from over 2,500 repositories》
  （Matt Nigh, 2025-11-19/25）讲的是 **Copilot 自定义 agent persona**（`.github/agents/<name>.md` + frontmatter），
  **不是**仓库级 `AGENTS.md` 约定；但它基于 2,500+ 文件的统计给出了可复用的六项内容清单：
  "commands, testing, project structure, code style, git workflow, and boundaries"，并称
  ""Never commit secrets" was the most common helpful constraint"。
  <https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/>

### 5.2 "少而准"的正面（可直接借鉴的模板）

- **【事实】指针式根文件**：sentry `CLAUDE.md` = `@AGENTS.md`（11 B）；vscode `AGENTS.md` = 271 B 指向唯一真相源。
- **【事实】祈使句单文件**：uv `AGENTS.md` 3.5 KB，只有可执行规则，不含教程。
- **【事实】入口不重复**：sentry "do not duplicate long guidance in editor-specific rule files"；bitwarden 用
  "read on demand" 明确哪些文件**不要**开机即读。
- **【事实】下沉层有明确边界**：next.js "Too detailed for AGENTS.md → skill；every session needs → AGENTS.md"。
- **【判断】可操作的"少而准"配方**：根 `AGENTS.md` ≤ 100–200 行，只写（a）命令、（b）硬边界（NEVER/CRITICAL）、
  （c）去哪里读更多（链接/目录）；（d）把路径相关的细则放 `.claude/rules/` 或 skills 按需加载；
  （e）参考文档一律生成 + CI dry-run。

---

## 6. 给 IBDer 的具体建议（**【判断】**，非事实）

1. **保持一根 `AGENTS.md` 作为唯一入口**（现状已符合），不要再造 `CLAUDE.md`/`.cursor/rules` 的第二份真相；
   若某工具必须一个专属文件，内容只写一行指针（`@AGENTS.md`）。
2. **给根文件设行长上限**（建议 ≤ 150 行），把"读什么、什么时候读"写成显式清单（类似 bitwarden 的 read-on-demand），
   把细节沉到 `docs/` 与 skills 里按需加载。
3. **明确三层分工**：AGENTS.md = 每次会话都要的规则；`docs/` = 人读的参考与流程；`openspec/specs/` = 系统行为的权威
   （已有 authority order，不要与 `docs/` 互相复制）。
4. **加一道 docs 防腐闸**：至少 `markdownlint` + 断链检查（lychee）+ 生成物 dry-run；
   若某份文档可由代码/规格生成（例如标识符表来自 CONTEXT.md、OpenAPI/单测清单），就生成它。
5. **给"新建文档"设准入规则**（照抄 next.js `.agents/skills/README.md` 的 Do/Don't 二分），
   并在 PR 模板里问一句"这份文档会在什么时候被谁读？"，否则不进仓库。
6. **AI 生成内容的披露**已在 AGENTS.md §9 定义；建议把"文档是否仍与代码一致"的检查也写进 PR 证据清单。

---

## 7. 本次调研的缺口（诚实声明）

- `developers.openai.com`（Codex 官方 AGENTS.md 指南）返回 403，未取得原文；Codex 结论依赖 agents.md 官网
  （OpenAI 为共同作者）与 openai/codex 仓库自身文件。
- 未找到中立第三方发布的跨工具"权威对照表"；2.1 的 GitHub 文档是目前最接近的官方对照。
- GitHub code search API 的 `total_count` 对 `filename:` 查询明显不可信（曾返回 1,046,528），
  因此**没有**在这里复述"60k"以外的采用量数字；60k 为 agents.md 官网自述。
- 未发现公开的对照实验量化"AGENTS.md 篇幅 vs 任务成功率"；Claude 文档的 "reduce adherence" 是厂商经验，
  学术量化目前只到"23% 仓库存在失效代码引用"这一步。

---

## 附录 A：与 `writing-for-agents` skill 的术语对齐（**【判断】**，用于落地讨论）

本次调研的观察与仓库内 `writing-for-agents` skill 的机制是同一件事的两种说法；对照如下，便于把上面的
"事实"翻译成可执行的编辑动作：

| skill 术语 | 本次调研中的对应事实 |
|---|---|
| **Context load**（每次会话都付的代价） | Claude 官方 "target under 200 lines per CLAUDE.md file … reduce adherence"；`@import` "don't reduce its context cost"；Gemini CLI 全量拼接 |
| **Cognitive load**（人脑当索引） | bitwarden "read on demand" 清单；next.js "编辑子目录前先读沿途 README" |
| **Context pointer**（指针 + 触发条件） | vscode 根 `AGENTS.md` 271 B 指向唯一真相源；sentry `AGENTS.md` 写明"area AGENTS.md / skills 在何时读" |
| **Progressive disclosure**（下沉到按需层） | `.claude/rules/*.md`（路径触发）、`.agents/skills/`（任务触发）、Cursor `.mdc` 的 globs/alwaysApply |
| **Single source of truth** | sentry `CLAUDE.md` = `@AGENTS.md`；sentry 明文 "do not duplicate long guidance in editor-specific rule files" |
| **Environment as source of truth / cache** | uv 把 CLI/配置参考**生成**而不是手写；openai/codex 把 docs 全部外链成一行指针 |
| **Sprawl**（每行都活但太长） | next.js 28,678 B 单文件；反面限额见 Claude 的 200 行建议 |
| **No-op 与sediment** | 未在抽查仓库中直接观测到，属【判断】：本地可用的检测手段是 Claude Code `/doctor prompt-audit`（找失效引用与互相矛盾）与 uv 式生成物 dry-run |

**【判断】** 由此得到一条可写进 IBDer 的自检规则：根 `AGENTS.md` 里每一行只做两件事——下命令，或放指针
（指针需写明"什么时候去读"）。任何"解释性段落"优先下沉到 `docs/`，任何"环境里查得到的事实"（脚本名、目录结构、
配置项）不写进文件。
