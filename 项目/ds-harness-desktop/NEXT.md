# NEXT — 当前断点（只保留“现在接着干”需要的信息）

## 进行中

- **无半成品。** v0.3.9 + 2026-10-29 本轮改进（升级前 profile 预检 / 一键回到上一版本 / 单实例冲突提示 /
  `verify:profile` / 产物目录改 `dist`）已实现，`npm test` 42/0、`build:dir` 与 `build` 均
  「通过 7 / 失败 0 / 跳过 1」。
- 本机（A机）已把 **0.3.9（带本轮新代码）装到 `G:\ai\dsh desktop` 并在跑**；引擎 `0.2.1-rc.4`；
  回退目标 `0.2.0-rc.2` 的版本目录仍在。
- 代码已提交并推送（`main`），提交哈希见本轮 JOURNAL。

## 下一步

1. **在新装的 0.3.9 上验两条新路径**：① 托盘「回到上一个版本（v0.2.0-rc.2）」来回切；
   ② 错误页三按钮（重启服务 / 回到 vX / 打开 profile 目录）。
2. **内置 dsh 升到 `0.2.1-rc.4`**（`app/package.json` 精确版本 + `npm ci`）→ 「保底」重新有效；
   或反向：把「回到内置版本」入口降级，并把 `AGENTS.md` 硬约束 1 改成实话（内置仅最小可用）。
3. **发 0.3.10**：✅ 已完成（2026-10-29，tag `v0.3.10`，CI run `40745597756` 全绿；Release 四资产：Setup 129.9 MB / portable 129.7 MB / blockmap / latest.yml，正文取 tag 注释）。本机装的还是 0.3.9，可用托盘「检查桌面端更新」升级。
4. **插件升版**：`dshmarket 1.66.7 → 1.73.1`、`@mars-sea/dsh-commandcode-provider 0.12.1 → 0.15.5`；
   升前跑 `dsh --profile web --dump-config` 查 `skipping|incompatible`。
5. **把「本地自研插件禁止在 `dependencies` 写 `@deepseek-ai/*` 核心包」写进 `AGENTS.md` 硬约束**
   （本轮只写进了 `过程记录/` 与 JOURNAL）。
6. 清理 `~/.dsh\profiles\web\node_modules\@deepseek-ai\` 下的 `.bak` / `.shadow-20261028` 手工残留
   （需普通 PowerShell；agent 会话里改不动 Medium 文件）。
7. 历史产物：`产出\` 已整体改名 `历史产物\`（3.2 GB，已在 `.gitignore`）；是否移出工作区归档待用户定。
8. （沿用旧条目，未动）B机 `.onInit` 相位问题、`[5]` 卸载断言加固、增量下载 fallback。

## 已知坑

- **⚠️ 工作区 = Low integrity（2026-10-29 实锤，解释了一堆玄学）**：agent 会话把仓库根目录标成
  `Low Mandatory Level`，**在里面构建出来的 exe 全部继承该标签** → Electron 起不来（`0x80000003`，
  Chromium 沙箱初始化失败，连 JS 都没跑）、NSIS 安装包报 `Error writing temporary file`（Low 进程
  写不了 Medium 的 `%TEMP%`）。工作区外副本能用是因为复制不带标签。
  修复：普通 PowerShell 里 `icacls "<仓库>\dist" /setintegritylevel Medium /T /C`，或双击仓库根
  `unlock-artifacts.cmd`；**每次重新打包都要再跑一次**。这也是「agent 会话里 Electron 要
  `--no-sandbox`」的真正原因（低完整性），不是执行环境玄学。
- **解锁过的 dist 会让 agent 打包失败**：`unlock-artifacts.cmd` 把文件升成 Medium 后，Low 的 agent
  会话删不掉它们 → `npm run build(dir)` 报 `remove ...: Access is denied`。
  重新打包前先双击仓库根 **`reset-dist.cmd`** 清空 dist（顺序：reset-dist → build → unlock-artifacts）。
- **本地自研插件禁止用 `dependencies` 钉 `@deepseek-ai/*` 核心包**（2026-10-29 事故根因）：一律
  `peerDependencies` 范围（如 `">=0.2.0-rc.2 <0.3.0"`），否则 pnpm 会在 profile 里落一份旧核心包，
  下次升引擎直接 `tools` 行被禁用、整条插件链 pending。
- **`verify:profile` 在 agent 会话里要指系统 node**：`$env:DSH_DESKTOP_NODE='C:\Program Files\nodejs\node.exe'`；
  默认会挑侧车 `app/runtime/node.exe`，它是工作区镜像、Low IL，写不了 `~/.dsh` → 报 EPERM（脚本已内置此提示）。
- **单实例锁**：两份壳共用 `%APPDATA%\ds-harness-desktop`，第二个实例会退出（现在有弹窗说明）；
  测新构建前必须彻底退出旧实例，否则只会聚焦旧窗口。
- 沿用（详见 `过程记录/` 与旧 JOURNAL）：agent 会话打包要把 `TEMP`/`TMP`/`npm_config_cache`/
  `ELECTRON_CACHE`/`ELECTRON_BUILDER_CACHE` 全指进仓库；`~/.dsh` 相关测试必须 `DSH_HOME` 重定向；
  超长路径删除用 `robocopy <空目录> <目标> /MIR` 再删；`dsh plugin allow-version` 只对精确版本生效；
  `settings.yaml` 迁移只跑一次（被拒分节静默丢失）；发版说明三坑（PS5.1 BOM / `#` 行被剥 / GBK 乱码）；
  NSIS 装/卸三坑；侧车 npm 双态；desktop 模式死结（关壳 = agent 断电）；工作区 git 报
  `dubious ownership` 用 `-c safe.directory=<路径>`；前台长轮询会被宿主掐掉；B机 `node_modules` 腐坏三连。

最近更新：2026-10-29 A机
