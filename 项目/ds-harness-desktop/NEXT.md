# NEXT — 当前断点（只保留“现在接着干”需要的信息）

## 进行中

- **无。**（本轮「应用内 dsh 更新激活后秒回退」已修复并随 **v0.3.7** 发布 —— 2026-09-25 01:20
  CI 全绿：正式 Release 非 Draft、四资产齐全（Setup / blockmap / portable / latest.yml）、
  正文取 tag 注释且四节标题完整写回、线上 `latest.yml` = `version: 0.3.7` 连字符名。
  实机已先验证「重启服务」不再回退。提交 `bdf0bb8`，tag `v0.3.7`。
  根因/证据见项目仓库 `过程记录\2026-09-24-应用内更新自动回退bug与手工激活0.1.7.md`；
  本轮还顺带修掉 dsh 0.1.7 的插件不兼容与权限配置，见同日另一篇过程记录。
  **当前 dsh = 0.1.7-rc.2**（手工激活）；`~/.dsh` 备份在 `.dsh.bak-20260924-230423`。
  **本机壳已升到 0.3.7**（2026-09-25 01:38~01:50 走托盘「检查桌面端更新」真装，**真机自更新
  链路完整验证通过**：下载 → 向导安装 → 自动重启；升级后手工激活的 dsh 0.1.7、三个插件版本、
  权限配置全部无损）。安装耗时约 **720 秒**，原因见「下一步」第 2 条。）

## 下一步

1. **[5] 本机端到端已验证过一次**（隔离命名构建，2026-09-24：通过 8、失败 0、跳过 0），但本机
   安装器随后出现**间歇性 .onInit 相位不稳定**（见下条），因此 [5] 现有"一次重试 + 连续失败按
   环境问题 SKIP"的策略。改安装器/打包相关代码后重跑 = `npm run build:smoketest`（约 4 分钟）
   → `npm run verify:smoke`（**无需提权、无需 --force-installer**，本机有真实安装也安全）。
   未跑 build:smoketest 时本机默认 SKIP（安全默认值），发版门禁由 CI 承担。
2. **本机安装器 `.onInit` 插件相位间歇性不稳定（合并原「双击崩溃」条目，2026-09-24 实测）**：
   表现二选一——**秒崩 0xC0000005**（退出码 3221225477，1-2s，无 WER 事件）或**长时间挂起**
   （手动探测 >600s 未返回，进程挂着），此外也成功过（298s）。**要害证据**：崩溃留下的
   `%TEMP%\ns*.tmp` 里**只有 `System.dll`(12288B) + `UAC.dll`(14848B)** → 崩在插件加载 /
   `.onInit` 早期；用户 18:15/18:18 双击真实包的两处崩溃（事件 1000：`System.dll` @0x1581）
   也各留一个同样的 `ns*.tmp` → **同一相位、同一现象，且与被测产物无关**（全新隔离构建同样
   复现，同一产物也有成功记录）。已排除：磁盘空间（C: 58.5GB 空闲）、第三方杀软（仅 Defender，
   行为日志无记录）、产物完整性（136,345,726B 完整）。
   **下一步排查建议**：① 把隔离包拿到 **A机** 跑同一命令（判断是否本机特有）；② 若仅 B机复现，
   查 shell/UAC/Defender 与已知文件夹相关配置差异（`multiUser.nsh` 在 `.onInit` 里调
   `SHGetKnownFolderPath`）；③ 复现时抓 `ns*.tmp` 内容 + 进程转储。
   **复现务必用隔离包**（`npm run build:smoketest` → 双击 `产出\smoketest\…SmokeTest Setup …exe`），
   不要裸双击真实包（会触发 uninstallOldVersion 卸掉真安装）。
   **2026-09-25 新证据（收窄排查面）**：真机 0.3.6→0.3.7 自更新，安装相位**约 720 秒**
   （01:38:14 交给安装器 → 01:50:31 应用重启），**进度条持续移动但很慢**、事件日志无崩溃记录
   （只有两条无关的 Security-SPP）。与既有量级同阶（成功 298s / 挂起 >600s）。
   **同时实测排除两个嫌疑**：同盘复制 `resources`（13,444 文件 / 233 MB，**含 Defender 实时
   扫描**）仅 **23.4 秒**（574 文件/秒，10 MB/秒）→ **文件数与杀毒扫描都不是瓶颈**，
   「装机慢」应从**瘦身依赖树 / 加 Defender 排除**这两个方向撤出（原判断已被推翻）。
   推断（未实测）：更新走「卸旧 + 装新」两遍，各含一次该相位 → 可能是**两次慢相位叠加**。
   **A机 已跑（2026-09-25，结果：不复现）**：隔离包在本机连跑三遍 = **8/0/0 全绿**，安装相位
    **58s / 64s / 58s**（卸载 4~5s），无秒崩、无挂起——比 B机 最快的 298s 还快约 5 倍。
    → **现象指向 B机 环境特有，非产物问题**。A机 基线（供 B机 对照）：UAC `EnableLUA=0`
    **全关**（安装器从不走提权握手）、Defender **实时防护=关闭**、已知文件夹全本地默认
    （无 OneDrive/网络重定向）、Win10 专业版 19045、管理员会话；A机 `%TEMP%\ns*.tmp` 旧残留
    内含 **4 插件**（System+UAC+StdUtils+nsExec）→ 顺利越过 B机 崩溃时停住的那两个。
    **下一步（B机）**：① 查 B机 UAC 是否开启——若开，安装/卸载各需一次 `UAC_RunElevated`
    提权握手（正是 `UAC.dll` 那一相位，**最强嫌疑**），试「临时关 UAC」或 `/currentuser`
    免提权对照复现；② 查 Defender 实时防护状态（A机 是关闭的）；③ 查已知文件夹是否被
    OneDrive/网络重定向（`multiUser.nsh` 在 `.onInit` 调 `SHGetKnownFolderPath`）；
    ④ 复现时抓 `ns*.tmp` 内容 + 进程转储。详情见 `JOURNAL\2026-09-25-A机.md`。
3. 低价值清账（可选）：AGENTS.md Project Commands 过时 **且硬约束 3「runtime 无 npm」
   与现实不符**（源在外部 `.agent-loop/project.md`，须在源头改）、补 `app/README.md`
   （代码注释引用它）、`过程记录/` 补 v0.3.1–v0.3.4 四篇。
4. （可选）[5] 卸载断言加固：卸载后注册表卸载键消失才全绿（当前已断言文件移除 + 真安装体
   完好）；快照扩全机位置已随 09-24 修复完成，此项只剩断言本体。
5. B机接力：`git pull` 后对 agent 说“先读大脑仓库里 ds-harness-desktop 的笔记再继续”。
6. **增量下载失败（低优先，排队）**：`Cannot download differentially, fallback to full download`
   已出现 3 次（09-12、09-23、09-24）；本可只下 **714 KB（1%）**，实际每次下满 130 MB。
   2026-09-25 实测全量下载仅 **18 秒**（约 7 MB/秒）→ 修它只省十几秒，**优先级低**，
   等网络成为瓶颈再修。真正的痛点在安装相位，见第 2 条。
7. **等 pnpm 冷却期过后补升插件**（1 天规则，见「已知坑」）：`dshmarket` 1.58.0 → 1.65.1、
   `@mars-sea/dsh-commandcode-provider` 0.11.11 → 0.11.14（两者均 2026-09-24 发布）。
   命令：`dsh plugin --profile web update dshmarket@latest`。
8. 顺带评估 `overrideFallbackDone` 的重置时机是否也需绑定子进程实例（当前按「每次成功启动重置」）。
9. **官方桌面端已上线（预览/偷跑态）→ 本项目定位待用户拍板**（2026-09-25 A机 核实）：
   官方仓库已有 `apps/desktop` + `apps/desktop-host`（Electron、复用 Web UI，自带托盘/单实例/
   自动更新/强制更新策略），Windows 包 `deepseek-harness-0.1.7-rc.1.20260924.1-win-x64.exe` 在
   `download.deepseek.com/dsh-desk/bin/win-x64/` **实测存在**、可自更新到 **0.1.7-rc.2**（= 本机
   dsh 同代）；官网与 GitHub Release 尚未官宣（assets 为空）。我们的差异面：可退回内置 dsh、
   可锁 dsh 版本、无账号/实名门槛、有守卫 + `verify:smoke` 体检；官方缺口：无 Linux。
   **待核实**：是否共用 `~/.dsh`（共用则 session 单实例锁会互抢）、是否自带运行时、同机共存是否打架。
   详见 `JOURNAL\2026-09-25-A机.md` 追加节。**用户拍板前不要动项目定位与代码。**

## 已知坑

- **验证改动不用真装（2026-09-25 补）**：`npm run build:dir` 出的 `产出\win-unpacked\` 直接跑
  即可（冒烟 [4] 就是这么验"打包产物能否拉起"的），**只有验真机自动更新链路时才需要真装一次**。
  本机一次真装约 720 秒（见「下一步」第 2 条），发版密集期用这条能省掉大部分等待。
- **更新缓存会留 260 MB 残留（2026-09-25 清过一次）**：`%LOCALAPPDATA%\ds-harness-desktop-updater\`
  下 `installer.exe` 与 `pending\*.exe` 各 130 MB，装完不会自动删。清理时机：确认无
  `Setup/Au_/Un_A` 进程在跑。

- **dsh 0.1.7 删了 `settingsScope` 服务 → 第三方插件 pending 卡死（2026-09-24 B机实锤）**：
  0.1.7 把 `@deepseek-ai/dsh-settings` 的 `SettingsProvider` 换成 `SettingsForms`，并**移除**了浏览器侧
  `settingsScope` 与 `installSection`。旧版 `@mars-sea/dsh-commandcode-provider`（早于 0.11.9）inject 它
  → Cordis 永远等服务 → 条目永久 pending，报 `dsh: warning: 1 entry did not activate` /
  `pending (waiting for service: settingsScope)`，页面打不开。**0.11.9（09-22）起作者做了双代适配**，
  `dsh plugin --profile web update <pkg>@latest` 即解决。**dshmarket 1.58.0 的 `client.js` 里仍有
  `ctx.inject(["settingsScope"], …)`，但那是惰性注入 → 不阻塞启动、只静默失效**。
  **壳的两道保险都盖不住这一类**：冒烟验证用干净临时 `DSH_HOME`、不带第三方插件；自动回退只在
  **子进程退出**时触发，而插件 pending 时进程活着、UI 也打得开。**升引擎前后都要 update 一遍插件。**
- **pnpm 11 默认 `minimumReleaseAge = 1440`（1 天）**：供应链保护默认开启，**刚发布的版本装不上**。
  故 `@latest` 常拿到"至少 1 天前"的版本（实证：provider 0.11.14 发布于 09-24 12:46，用户实际拿到
  0.11.11；`pnpm outdated` 报 dshmarket 1.58.0 而非 1.65.1）。想立刻装某版本须写进
  `profiles\web\pnpm-workspace.yaml` 的 `minimumReleaseAgeExclude`（已有 3 条此类豁免）。
  **排查"版本没升上去"先看这条，别急着怀疑镜像没同步。**
- **`defaultPreset: auto` 在 0.1.7 必定报错（2026-09-24 已修）**：0.1.7 的 `PermissionPresetService`
  构造函数里就 `resolve(defaultPreset)`，而 `auto` 只在 Auto 审阅集成 live 时才进入可选名单
  （`autoAdmit !== undefined`）→ 必然 unknown preset；**且 `auto` 不能出现在用户 `presets` 表里**
  （源码显式抛错）。已把 `profiles\web\cordis.patch.yml` 改为 `defaultPreset: workspace-write`
  （原值备份 `.bak-dsh017fix-20260924-232831`）；想用 Auto 请到「插件管理 → 自动审阅」启用集成。
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
- **"装到临时目录" ≠ 隔离：隔离的单位是命名空间，不是目录（2026-09-24 事故的设计级根因）**：
  NSIS 的快捷方式路径（公共桌面/开始菜单的 `DS Harness Desktop.lnk`）与注册表键名
  （`...\Uninstall\99d3b161-…`、`Software\99d3b161-…`）都由**产品名/GUID 派生**，与安装
  目录无关；`assistedInstaller.nsh` L112-120 还表明**安装模式由"安装记忆键"决定**（HKLM 有
  → 全机 → 读写公共桌面/HKLM，且开装前的 `uninstallOldVersion` 会去读真安装的卸载键）。
  对策（2026-09-24 已全部落地）：① **`npm run build:smoketest`**——体检专用隔离命名构建
  （productName/shortcutName/guid 三换），`verify:smoke` 读到清单即自动优先使用它，实测
  8/0/0 且真实安装零接触（**首选**）；② 用真实安装包时：本机存在真实安装即**默认 SKIP**
  （`--force-installer` 才跑）；③ temp 安装强制 **`/currentuser`**（L129-133 支持）→ 只写
  HKCU + 用户级快捷方式；④ 护栏（三 hive 暂存/独立复查/快照还原/判红）作纵深防御保留。
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

最近更新：2026-09-25 A机
