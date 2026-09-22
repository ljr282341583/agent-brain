# NEXT — 当前断点（只保留“现在接着干”需要的信息）

## 进行中

- **0.3.5 发版流水线全部收官**：tag → CI 自动发布（十步全绿）→ 真机自更新验证 PASS →
  按用户要求把安装从 `C:\Program Files` 搬回 `G:\ai\dsh desktop\…`（记忆键已回填 G:\，
  今后更新原地不动）。反馈三件套 + 分发说明实测修正随本次收尾提交，**待下一版带出**。

## 下一步

1. 发 0.3.6（时机自定）带出反馈三件套：升号 0.3.6（package.json+lockfile）→ 说“收尾”
   （自动打包+体检全绿）→ 打 tag `v0.3.6`（**注释 = Release 说明，用 `-F` 文件喂，
   正文别在命令文本里出现行首 `## `**）→ 推 tag 即由 release.yml 自动发布 → 托盘验证。
   0.3.5 已占用：本地 `产出\` 若构建出 0.3.5 是「同号不同源」，勿与 GitHub 发布资产混淆。
2. （可拍板小项）本地打包自动跑 `app\scripts\prepare-runtime.ps1`（侧车 npm 对齐 CI）+
   [2] 静态检查加「侧车含 npm」断言防回归。
3. 低价值清账（可选）：AGENTS.md Project Commands 过时 **且硬约束 3「runtime 无 npm」
   与现实不符**（源在外部 `.agent-loop/project.md`，须在源头改）、补 `app/README.md`
   （代码注释引用它）、`过程记录/` 补 v0.3.1–v0.3.4 四篇。
4. （可选）[5] 卸载断言加固：卸载后注册表卸载键消失才全绿（当前已断言文件移除 + 真安装体完好）。
5. B机接力：`git pull` 后对 agent 说“先读大脑仓库里 ds-harness-desktop 的笔记再继续”。

## 已知坑

- **更新向导模式页陷阱（0.3.5 实测踩过，更新曾漂到 Program Files）**：electron-updater
  更新不带 `/S`（弹完整向导），第一页「装给谁」默认由记忆键决定、目录页被
  `skipPageIfUpdated` 跳过；切错模式即漂移——全机模式默认 `$PROGRAMFILES64`。更深一层：
  electron-updater 的 `/D=` 依赖**卸载键**的 InstallLocation，而 electron-builder 只写
  **安装记忆键**（`HKLM\Software\99d3b161-…`）→ 第一道保险天然失效。当前记忆键 = G:\
  （全机模式）：**更新时一路默认、别切「仅当前用户」**（会孤儿化现装→双安装）。更新完
  验证口诀：查 `G:\…\resources\app\package.json` 版本号（或让 agent「查更新位置」）。
- **发版说明三坑（0.3.5 修了三轮）**：① `Set-Content -Encoding utf8`（PS5.1）带 BOM——
  用 `[IO.File]::WriteAllText(…, [Text.UTF8Encoding]::new($false))`；② `Get-Content` 不带
  `-Encoding UTF8` 会按 GBK 解 UTF-8 全乱码；③ 命令文本里**行首 `## ` 会被吃掉**（tag
  注释标题就这么丢的）——正文一律从文件读（`-Encoding UTF8`）再组装。
- **发版即推 tag**：`.github/workflows/release.yml` 监听 `v*` tag 自动打包发布
  （`--publish always`、资产连字符名、说明取 tag 注释、`releaseType: release` 正式非 Draft）；
  上传的 4 资产名连字符，本地产物名空格——同一文件双名，**文档与 notes 一律写连字符名**。
- **NSIS 装/卸三大坑（已全踩过，脚本化装/卸必读）**：① `uninstallOldVersion` 按注册表先跑
  旧卸载器——temp 安装前必须暂存并删除卸载键、结束后导回（[5] 已内置）；② 卸载器必须带
  `_?=$INSTDIR` 否则复制到 %TEMP% 异步跑、父进程秒回、事后补刀；③ 安装/卸载按进程名
  `taskkill /im "DS Harness Desktop.exe"` 全杀同名实例（[5] 检测到正式实例即 SKIP）。
- NSIS `/D=` 含空格路径：整个 `/D=...` 必须作为**一个带引号参数**传入（WMI Create 裸
  命令行实证可行；PowerShell Start-Process 单字符串会按空格截断）。
- **侧车 npm 双态**：CI 发布物永远含 npm（`prepare-runtime.ps1`）；本地初始 runtime 没有
  （.gitignore 不入库）——本地打包前跑一次 `app\scripts\prepare-runtime.ps1`
  （2026-09-23 A机 已跑，npm 11.13.0）。AGENTS 硬约束 3 的「无 npm」只对没跑脚本的本地树成立。
- Node 24 禁止裸 spawn `.cmd`（EINVAL、status=null 无输出）：用 `node + npm-cli.js` 或
  `cmd /c`（afterPack 已按此修复）。
- desktop 模式死结：关壳 = agent 断电、壳开 = [5] 跳过；例外：全局 `dsh web` 占 3080 时
  可代打会话（壳死会话也能续），壳重开可能弹错误页——先关全局 dsh web（会断当前会话，
  重开能续）。
- 会话工作区属主 `BUILTIN/Administrators`，git 报 `dubious ownership`：临时加
  `git -c safe.directory=<路径>`；根治须改全局 git 配置（用户未授权，勿擅动）。
- **前台长轮询调用会被宿主掐掉且结果不落盘**：等待/轮询逻辑放后台任务，前台只做
  「发射即返回」；`Invoke-CimMethod` 参数名是 `-Arguments`（非 `-ArgumentList`）。
- `过程记录/` 最新只到 2026-09-10（v0.3.1–v0.3.4 未补，细节看 `git log --oneline`）。
- 测试一律 `DSH_HOME` 重定向（verify:smoke 已内置）。

最近更新：2026-09-23 A机
