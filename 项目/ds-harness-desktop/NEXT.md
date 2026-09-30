# NEXT — 当前断点（只保留“现在接着干”需要的信息）

## 进行中

- **无半成品。** 桌面端 **v0.3.9 已发布**：提交 `54a84b0`（修复）+ `2e27422`（体检开关）+ `f40fbd0`（发版），
  tag `v0.3.9`，CI run `36761280749`。修的是 2026-09-30 事故根因 —— 外壳把「覆盖版本子进程退出」等价于
  「覆盖版本启动失败」，把一次运行 4.6 小时后的静默崩溃误判为版本不可用，4ms 内永久降级到内置版本；
  而该 profile 依赖只在 dsh ≥ 0.1.7 存在的实验包，内置 0.1.5-rc.1 永远解析不了 → 应用永久打不开。
  复盘与本机端到端复刻见 `JOURNAL\2026-10-01-A机.md`。
- **A机 安装体是「v0.3.8 + 热补丁」状态**：备份在 `resources\app\src\_patch-backup-20261001\`（含还原说明），
  重启应用生效；装/更新到 **0.3.9** 后由正式产物取代、状态归一。
- 工作区干净，`main` 与 `origin/main` 一致（`f40fbd0`）。上一轮 v0.3.8（内置「手机访问」）流水见
  `JOURNAL\2026-09-25-A机.md`。

## 下一步

1. **用户侧**：装/更新到 **v0.3.9**（托盘「检查桌面端更新」或从 Releases 下载）。重启后可自查日志里出现
   `uptimeMs=` / `reachedUi=` / `[recovery]` 字段 = 新判定在跑。
2. **补「重装 / 修复当前 dsh」入口（本轮审查发现，未做，优先级最高）**：当覆盖版本与内置版本**都**加载不了
   当前 profile 时，界面无路可走（错误页只有「重启服务」；托盘「检查 dsh 更新」在覆盖版本已是通道最新时
   也不动手）。设计要点：绕过 `checkForUpdate` 的 `hasUpdate` 门槛，直接
   `updater.installVersion` + `activate` + `restartHarness`；错误页顺带给出 profile 清单路径与「打开该目录」。
   **这是本次事故暴露出的最后一处死角。**
3. **B机 `.onInit` 相位问题**（沿用旧条目）：A机 不复现（隔离包连跑三遍 8/0/0，安装相位 58/64/58 秒）；
   B机 待查 —— ① UAC 是否开启（`UAC.RunElevated` 是最强嫌疑，试临时关 UAC 或 `/currentuser` 对照）；
   ② Defender 实时防护状态；③ 已知文件夹是否被 OneDrive/网络重定向。复现**务必用隔离包**
   （`npm run build:smoketest`），别裸双击真实包（会触发 `uninstallOldVersion` 卸掉真安装）。
4. **本机体检已能拿绿灯**（本轮修好口径）：agent 会话内跑 `npm run build:dir` 或
   `npm run verify:smoke -- --packaged` 即可（见「已知坑」第 1、2 条），不必再切普通终端。
5. 低价值清账（可选）：`过程记录/` 补 v0.3.1–v0.3.4 四篇；`[5]` 卸载断言加固（卸载后注册表卸载键消失才全绿）。
6. **插件补升**（pnpm 冷却期已过，可直接升）：`dshmarket` 1.58.0 → 1.65.1、
   `@mars-sea/dsh-commandcode-provider` 0.11.11 → 0.11.14。
   命令：`dsh plugin --profile web update dshmarket@latest`。
7. **增量下载失败**（低优先，排队）：`Cannot download differentially, fallback to full download` 已出现 3 次；
   全量下载只需 18 秒 → 修它只省十几秒，等网络成瓶颈再说。
8. **官方桌面端已上线（预览/偷跑态）→ 本项目定位待用户拍板**（2026-09-25 A机 核实）：官方有
   `apps/desktop` + `apps/desktop-host`，Windows 包实测存在、可自更新到 0.1.7-rc.2。我们的差异面：
   可退回内置 dsh、可锁 dsh 精确版本、无账号/实名门槛、有打包守卫与 `verify:smoke` 体检；官方缺口：无 Linux。
   **用户拍板前不要动项目定位与代码。**
9. ~~评估 `overrideFallbackDone` 的重置时机是否也绑定子进程实例~~ → **本轮已解决**：语义重写为「成功加载 UI
   才复位」，并新增 `fallbackFromVersion`（回退后内置版也起不来时，一次性把 `state.json` 恢复回覆盖版本），
   见 `DECISIONS.md` 2026-10-01。
10. **提交纪律照旧**：只 `git add` 自己改的文件，不要 `git add -A`。

## 已知坑

- **⚠️ agent 会话内打包/体检（2026-10-01 口径更新，旧口径作废）**：`afterPack.js` 的 `resolveNpmRunner`
  优先用仓库内的侧车 `app\runtime\node.exe` 跑 `npm ci --omit=dev`，而**凡镜像位于会话工作区内的进程，
  写工作区外一律 EPERM**（同机对照：系统 node / PowerShell 不受限）→ npm 报 `errno -4048` /
  `syscall mkdir %TEMP%\dsh-desktop-prod-deps\<key>\node_modules`。**旧口径「请在普通终端跑」已作废**，
  现在这样绕过即可（2026-10-01 实测两次全绿）：
  `$env:TEMP=$env:TMP='<仓库>\.tmp-build'; $env:npm_config_cache='<仓库>\.tmp-build\npm-cache'; npm run build`。
  首次要重新下载生产依赖（3–5 分钟）；跑完删 `.tmp-build`（超长路径见本文件「超长路径」条）。
- **⚠️ 本机 A机 在 agent 会话启动 Electron 需 `--no-sandbox`**：不加秒退 `0x80000003`
  （`STATUS_BREAKPOINT`，Chromium 沙箱初始化失败），**是执行环境限制、与产物无关**
  （2026-10-01 A/B 复证：打过补丁的产物与未打补丁的正式版表现一致）。**已有开关**：
  `$env:DSH_SMOKE_EXTRA_ARGS='--no-sandbox'; npm run verify:smoke -- --packaged` → 通过 7 / 失败 0 / 跳过 1；
  该变量只作用于体检自己拉起的隔离实例（隔离端口/userData/DSH_HOME、不抢单实例锁），CI 不设。
- **删除超长路径目录**：`Remove-Item` / `rmdir /s` 会报 `Could not find a part of the path`
  （如 `@opentelemetry\…\getMachineId-unsupported.js.map`）→ 用 `robocopy <空目录> <目标> /MIR` 清空后再删。
- **验证改动不用真装**：`npm run build:dir` 出的 `产出\win-unpacked\` 直接跑即可（冒烟 [4] 就是这么验的），
  只有验真机自动更新链路时才需要真装一次（本机一次真装约 720 秒）。
- **更新缓存会留 260 MB 残留**：`%LOCALAPPDATA%\ds-harness-desktop-updater\` 下 `installer.exe` 与
  `pending\*.exe` 各 130 MB，装完不自动删。清理时机：确认无 `Setup/Au_/Un_A` 进程在跑。
- **窗口菜单栏默认藏着**：主窗口 `autoHideMenuBar: true`，**按 `Alt`** 才唤出「文件 / 视图 / 手机访问」；
  用户拍板保持现状，日常入口用**托盘右键**。
- **尾网 / 内网地址不进笔记、也不进提交信息**（2026-09-25 踩过一次，用户拍板不追改历史）；需要示例时用占位符。
  2026-10-01 发版已做红线自检（提交 + tag 说明扫描 `100.x` / `token=` 均干净）。
- **dsh 0.1.7 删了 `settingsScope` 服务 → 第三方插件 pending 卡死**（2026-09-24 B机 实锤）：0.1.7 把
  `dsh-settings` 的 `SettingsProvider` 换成 `SettingsForms`，旧版 `@mars-sea/dsh-commandcode-provider`
  （早于 0.11.9）`inject` 它 → Cordis 永远等服务 → 条目永久 pending、页面打不开。**壳的两道保险都盖不住
  这一类**（冒烟用干净临时 `DSH_HOME`、不带第三方插件；自动回退只在子进程退出时触发，而 pending 时进程活着）。
  **升引擎前后都要 update 一遍插件。**
  （2026-10-01 补：本轮把「自动回退」的判据也收窄并加了 profile 预检，但**冒烟仍不覆盖真实 profile**，
  这条结论不变。）
- **pnpm 11 默认 `minimumReleaseAge = 1440`（1 天）**：刚发布的版本装不上，`@latest` 常拿到至少 1 天前的版本；
  想立刻装须写进 `profiles\web\pnpm-workspace.yaml` 的 `minimumReleaseAgeExclude`。
  **排查「版本没升上去」先看这条。**
- **`defaultPreset: auto` 在 0.1.7 必定报错**（2026-09-24 已修）：`PermissionPresetService` 构造函数里就
  `resolve(defaultPreset)`，而 `auto` 只在自动审阅集成 live 时可选，且不能出现在用户 `presets` 表里。
  已把 `profiles\web\cordis.patch.yml` 改为 `defaultPreset: workspace-write`。
- **更新向导模式页陷阱（0.3.5 实测）**：electron-updater 更新不带 `/S`，第一页「装给谁」由记忆键决定、
  目录页被 `skipPageIfUpdated` 跳过；切错模式即漂移（全机模式默认 `$PROGRAMFILES64`）。当前记忆键 = `G:\`
  （全机模式）：**更新时一路默认、别切「仅当前用户」**。验证口诀：查 `G:\…\resources\app\package.json` 版本号。
- **全机安装的自查位置**：程序 `G:\ai\dsh desktop\DS Harness Desktop`、图标在公共桌面/ProgramData 开始菜单、
  卸载键与记忆键在 **HKLM**（HKCU 无）。按用户级位置自检会全部查空——不是丢了。
- **[5] 曾假绿误删真安装**（2026-09-24 实锤，修复 = `85a9d96` + `3f26481` + `a605bf3`）：暂存只扫 HKCU →
  全机安装的键在 HKLM → 暂存扑空 → NSIS `uninstallOldVersion` 清空安装与公共图标，三道断言全空转。
  现已三 hive 暂存 + 独立复查硬闸 + 快照补全机位置 + 真安装断言 + 「痕迹全无」硬断言。
  **跑 [5] 必须管理员 PowerShell**；零风险演练：`npm run verify:smoke -- --audit-stash`。
- **「装到临时目录」≠ 隔离：隔离的单位是命名空间**（2026-09-24 事故的设计级根因）：NSIS 的快捷方式路径与
  注册表键名由产品名/GUID 派生、与安装目录无关。对策：① `npm run build:smoketest` 隔离命名构建（首选）；
  ② 本机存在真实安装即默认 SKIP（`--force-installer` 才跑）；③ temp 安装强制 `/currentuser`；④ 护栏保留。
- **PowerShell 5.1 的 `ConvertTo-Json` 对单元素数组会退化成裸字符串**：跨进程回传结果一律用哨兵行协议
  （`KEY=` 行 + `SCAN-DONE <count>`），别依赖 JSON 形态。
- **发版说明三坑**：① `Set-Content -Encoding utf8`（PS5.1）**带 BOM** → 用
  `[IO.File]::WriteAllText(…, [Text.UTF8Encoding]::new($false))`；② `Get-Content` 不带 `-Encoding UTF8`
  会按 GBK 解 UTF-8 全乱码；③ **一切 `#` 开头的行都会从 tag 注释里消失**（连 `git tag -F` 也照剥）→
  标题/节标题别用 `#`，改用 `**粗体**`。2026-10-01 v0.3.9 已按此办理并通过剥行自检（4 个粗体节标题在位）。
- **发版即推 tag**：`.github/workflows/release.yml` 监听 `v*` tag 自动打包发布（`--publish always`、
  资产连字符名、说明取 tag 注释、`releaseType: release`）；CI 第一步会把 tag 版本号同步进
  `app/package.json` / `package-lock.json`（本地也照此升号，两边一致）。上传的 4 资产名连字符、
  本地产物名空格 —— 同一文件双名，**文档与 notes 一律写连字符名**。
- **NSIS 装/卸三大坑**：① `uninstallOldVersion` 按注册表先跑旧卸载器（temp 安装前必须暂存并删除卸载键）；
  ② 卸载器必须带 `_?=$INSTDIR`；③ 安装/卸载按进程名 `taskkill /im "DS Harness Desktop.exe"` 全杀同名实例
  （[5] 检测到正式实例即 SKIP）。`/D=` 含空格路径必须作为**一个带引号参数**传入。
- **侧车 npm 双态**：CI 发布物永远含 npm（`prepare-runtime.ps1`）；本地初始 runtime 没有（.gitignore 不入库），
  自 0.3.6 起 `build` / `build:dir` 已前置该脚本，smoke [2] 断言「侧车含可执行 npm」。
- Node 24 禁止裸 spawn `.cmd`（EINVAL、status=null 无输出）：用 `node + npm-cli.js` 或 `cmd /c`。
- **desktop 模式死结**：关壳 = agent 断电、壳开 = [5] 跳过；例外：全局 `dsh web` 占 3080 时可代打会话
  （壳死会话也能续），壳重开可能弹错误页——先关全局 dsh web（会断当前会话，重开能续）。
- 会话工作区属主 `BUILTIN/Administrators`，git 报 `dubious ownership`：临时加
  `git -c safe.directory=<路径>`；根治须改全局 git 配置（用户未授权，勿擅动）。
- **前台长轮询调用会被宿主掐掉且结果不落盘**：等待/轮询放后台任务（2026-10-01 又踩一次：PowerShell 输出
  被缓冲 → 改成「写文件 + node 直接测」）；`Invoke-CimMethod` 参数名是 `-Arguments`。
- 测试一律 `DSH_HOME` 重定向（verify:smoke 已内置）。
- **B机 dev 树 `node_modules` 腐坏 = 三连假故障**（2026-09-23 B机 实锤）：表征三连——smoke [3] 等不到 token、
  [4] 打包 exe 秒退 0、real-home 启动崩。修法：`set ELECTRON_MIRROR=…npmmirror… && npm ci` 再 `npm run build`；
  三症齐发先查 `node_modules\@deepseek-ai\dsh` 版本 vs lockfile。
- **改写 `app\scripts\prepare-runtime.ps1` 必须保留 UTF-8 BOM**（否则 PS5.1 按 GBK 解析报错/乱码）。
- **`~/.dsh\quarantine-legacy-v2`（陈旧 v2 会话隔离区）**：两种「搬回」都会把无害变必崩，保持原样即可；
  复验用 `过程记录\2026-09-23-会话档案身份审计.js`（系统 node 跑，全绿 = 0 错位 0 冲突）。
- **手机端配对**：cookie 30 天，地址变化（域名 ↔ IP / 端口变化）后需重扫一次；中继关掉只是连不上，配对不失效。

最近更新：2026-10-01 A机
