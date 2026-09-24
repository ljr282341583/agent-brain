# NEXT — 当前断点（只保留“现在接着干”需要的信息）

## 进行中

- 无

## 下一步

1. **等用户用管理员 PowerShell 跑完整 [5] 并把输出贴回**（关桌面端 → 管理员 PS →
   `cd app && npm run verify:smoke`）。核对三行真断言都在且 8/0/0：「暂存卸载键/安装记忆键
   （真实安装 D:\…）」「安装前复查通过」「真实安装体完好（D:\…）」；结果记 JOURNAL。
2. 排查本机 Setup 双击崩溃：0xc0000005（NSIS `System.dll` @0x1581，2026-09-24 两次
   同偏移；静默 `/S` 正常、交互路径必崩）。安全复现：**先暂存卸载键再启动**——切勿
   直接双击未暂存状态下的安装器，会触发 uninstallOldVersion 卸掉真安装。
3. 低价值清账（可选）：AGENTS.md Project Commands 过时 **且硬约束 3「runtime 无 npm」
   与现实不符**（源在外部 `.agent-loop/project.md`，须在源头改）、补 `app/README.md`
   （代码注释引用它）、`过程记录/` 补 v0.3.1–v0.3.4 四篇。
4. （可选）[5] 卸载断言加固：卸载后注册表卸载键消失才全绿（当前已断言文件移除 + 真安装体
   完好）；快照扩全机位置已随 09-24 修复完成，此项只剩断言本体。
5. B机接力：`git pull` 后对 agent 说“先读大脑仓库里 ds-harness-desktop 的笔记再继续”。

## 已知坑

- **更新向导模式页陷阱（0.3.5 实测踩过，更新曾漂到 Program Files）**：electron-updater
  更新不带 `/S`（弹完整向导），第一页「装给谁」默认由记忆键决定、目录页被
  `skipPageIfUpdated` 跳过；切错模式即漂移——全机模式默认 `$PROGRAMFILES64`。更深一层：
  electron-updater 的 `/D=` 依赖**卸载键**的 InstallLocation，而 electron-builder 只写
  **安装记忆键**（`HKLM\Software\99d3b161-…`）→ 第一道保险天然失效。当前记忆键 = G:\
  （全机模式）：**更新时一路默认、别切「仅当前用户」**（会孤儿化现装→双安装）。更新完
  验证口诀：查 `G:\…\resources\app\package.json` 版本号（或让 agent「查更新位置」）。
- **全机安装的自查位置（2026-09-23 [5] 后误报"快捷方式没了"实锤）**：B机为全机安装——
  程序 `D:\AI(CODEX)\dsh desktop\DS Harness Desktop`、图标在 `C:\Users\Public\Desktop`
  与 `C:\ProgramData\Microsoft\Windows\Start Menu\Programs`、卸载键在 **HKLM**（HKCU 无）、
  记忆键 `HKLM\99d3b161-…` 指 D:\。**按 `USERPROFILE\Desktop`/`APPDATA` 开始菜单/
  `HKCU` 卸载/`LOCALAPPDATA\Programs`/`C:\Program Files` 自检会全部查空——不是丢了，
  是这五处只对应每用户安装**；全机安装的图标在桌面上照样显示（公共桌面），开始菜单
  搜索也能命中。09-24 起 [5] 的卸载键暂存与快捷方式快照已覆盖全机位置（三 hive +
  公共桌面/ProgramData）。
- **[5] 曾假绿误删真安装（2026-09-24 实锤，修复 = `85a9d96` + `3f26481` + `a605bf3`）**：旧暂存只扫
  HKCU、全机安装的键在 HKLM → 暂存扑空 → NSIS uninstallOldVersion 清空 D:\ 安装与公共
  图标；同时三道断言全空转（`realDirs=[]` 循环不执行、快照只盖用户级位置、「已还原」
  无条件打印）→ **8/0/0 是假绿**。现已：三 hive 暂存（**卸载键 + 安装记忆键**）+ 动安装器
  前的**独立复查硬闸** + 快照补全机位置 + 真安装断言 + 跑完**"痕迹全无"硬断言**（快捷方式
  逐项复查在位 + 卸载键数回基线，缺一即判红，不再有静默的"已还原"）。**跑 [5] 必须管理员 PowerShell**
  （暂存 HKLM 要提权，未提权会 fail-closed 报红——红 = 安全）；零风险演练：
  `npm run verify:smoke -- --audit-stash`。绿不绿要看这几行真打印过：「暂存卸载键/安装
  记忆键」「安装前复查通过」「真实安装体完好」。
- **PowerShell 5.1 的 `ConvertTo-Json` 对单元素数组会退化成裸字符串**：`@('x') |
  ConvertTo-Json -Compress` → `"x"`（不是 `["x"]`）。2026-09-24 在体检硬闸里踩到，
  解析端误判"扫描失败"。**跨进程回传结果一律用哨兵行协议**（`KEY=` 行 + `SCAN-DONE
  <count>`，缺哨兵或计数不符即视为失败），别依赖 JSON 形态。
- **发版说明三坑（0.3.5 修了三轮）**：① `Set-Content -Encoding utf8`（PS5.1）带 BOM——
  用 `[IO.File]::WriteAllText(…, [Text.UTF8Encoding]::new($false))`；② `Get-Content` 不带
  `-Encoding UTF8` 会按 GBK 解 UTF-8 全乱码；③ **一切 `#` 开头的行都会从 tag 注释里消失**——2026-09-23 v0.3.6
  实测：连 `git tag -F <文件>` 也照剥（`#` 标题与 `## ` 节标题全部丢失、只剩正文；
  0.3.5 记的「从文件读」并不防这一刀，剥行发生在 git 内部）。**notes 的标题/节标题
  别用 `#` 走 tag，改用 `**粗体**` 或纯文本**；`-Encoding UTF8` 只解决编码不解决剥行。
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
  （.gitignore 不入库）——自 0.3.6 起 `npm run build`/`build:dir` 已前置自动跑该脚本
  （幂等快路径，就绪秒过）+ smoke [2] 断言「侧车含可执行 npm」，不再依赖人工记得跑。
  AGENTS 硬约束 3 的「无 npm」只对没跑脚本的本地树成立。
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
- **B机 dev 树 node_modules 腐坏 = 三连假故障（2026-09-23 实锤，B机）**：`app\node_modules`
  长期不重装会与 lockfile 漂移（当时 dsh 0.1.1-rc.2 vs 声明 0.1.5-rc.1），表征三连：
  smoke [3] 120s 等不到 token URL、[4] 打包 exe 秒退 0、real-home 启动崩（推断旧版不认
  `.v3.jsonl.zstd` 后缀去校验陈旧 v2）。修法：`set ELECTRON_MIRROR=…npmmirror… && npm ci`
  再 `npm run build`；三症齐发先查 `node_modules\@deepseek-ai\dsh` 版本 vs lockfile。
- **改写 `app\scripts\prepare-runtime.ps1` 必须保留 UTF-8 BOM**：无 BOM 的 UTF-8 被
  PS5.1 按 GBK 解析，报 `Unexpected token '}'` 或 `渚ц溅` 乱码（2026-09-23 踩过，已回写
  BOM；重写该文件后用 `powershell -NoProfile -File` 跑一遍 exit 0 验证）。
- **`~/.dsh\quarantine-legacy-v2`（陈旧 v2 会话隔离区，2026-09-23 B机）**：存 2 个户口
  失配的 v2 文件（b319e52f 协议生成修改、cde953a9 剪视频老 D: 路径），0.1.5 下无害
  （启动只选最高代 v3）。**两种「搬回」都会把无害变必崩**：整会话目录迁去老户口目录 →
  v3 错位启动必崩；只迁 v2 去老户口目录 → 同 id 跨项目目录 duplicate 必崩。按原相对
  路径搬回其原位（= 回滚到修复前）才安全，但没有必要。复验用
  `过程记录\2026-09-23-会话档案身份审计.js`（系统 node 跑，全绿 = 0 错位 0 冲突）。

最近更新：2026-09-24 B机
