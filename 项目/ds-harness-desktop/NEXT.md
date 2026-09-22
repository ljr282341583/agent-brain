# NEXT — 当前断点（只保留“现在接着干”需要的信息）

## 进行中

- 无半成品：verify:smoke 五步体检 + 打包自动挂载 + skill 1.0.4 等本次改动随收尾提交（起点 `main` `88091a6`）。

## 下一步

1. 发版流程：升 `app/package.json` version（建议 0.3.5）→ 关 desktop 壳 →
   `cd app && npm run verify:smoke` 拿 [5] 安装器端到端首次全量实证（期望 通过 7 / 失败 0）
   → 重开壳 → 说“收尾”（自动打包 + 体检，见 DECISIONS 档位二）。
2. 应用内 dsh 更新链路不可用待拍板（侧车无 npm，真有新版时会报“当前构建未捆绑 npm”）：
   a 放 npm 进侧车（+10~15MB）/ b 免 npm：registry tarball 下载 + Windows 自带 tar.exe 解压（推荐）
   / c 砍掉改走外壳更新。开工前问用户；选定后同步改 `docs/分发说明.md`（现称“侧车含 npm”，与现实矛盾）。
3. 低价值清账（可选）：AGENTS.md Project Commands 过时（“无自动化测试”已不成立，源在另一工作区
   `.agent-loop/project.md`）、补 `app/README.md`（代码注释引用但它不存在）、
   `过程记录/` 补 v0.3.1–v0.3.4 四篇（git log 可查）。
4. B机接力：`git pull` 后对 agent 说“先读大脑仓库里 ds-harness-desktop 的笔记再继续”。

## 已知坑

- NSIS 安装/卸载器按进程名 `taskkill /im "DS Harness Desktop.exe"` 全杀：verify:smoke [5] 已加守卫
  （检测到正式实例即 SKIP）；**任何脚本化装/卸操作前先查同名实例**。
- Node 24 禁止裸 spawn `.cmd`（EINVAL、status=null 无输出）：用 `node + npm-cli.js` 或 `cmd /c`；
  afterPack 已按此修复，新代码别再踩。
- desktop 模式死结：agent 跑在 desktop 的 dsh 服务里——关壳 = agent 断电，壳开着 = [5] 跳过；
  全量 [5] 只能用户关壳后自己跑命令（网页版模式可破此结，本次未选，见 DECISIONS）。
- 会话工作区属主 `BUILTIN/Administrators`，直接跑 git 报 `dubious ownership`：临时加
  `git -c safe.directory=<路径>`；根治须改全局 git 配置（用户未授权，勿擅动）。
- `过程记录/` 最新只到 2026-09-10（v0.3.1–v0.3.4 未补，细节看 `git log --oneline`）。
- 测试一律 `DSH_HOME` 重定向（verify:smoke 已内置）；`app/runtime/` 无 npm，
  “调用侧车自带 npm”不成立。

最近更新：2026-09-23 A机
