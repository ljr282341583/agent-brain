# CONTEXT — ds-harness-desktop（DS Harness Desktop）

> 新会话 / 另一台机器开工前必读。项目定位或阶段大变时更新本文件。

## 项目是什么

Electron 外壳包裹官方 DeepSeek Harness（`@deepseek-ai/dsh`），由捆绑的独立 Node 24
侧车（`app/runtime/node.exe`）执行 `dsh web`，产出 NSIS 安装包 + portable 分发给用户。
当前版本 **v0.3.7**（tag `v0.3.7`，提交 `bdf0bb8`，核实于 2026-09-25）。

## 当前阶段（2026-09-22）

- 代码停在 `main` `88091a6`，与 `origin/main` 一致、工作区干净；该笔已确认由 A机 提交并推送。
- **唯一工作副本**：原项目文件夹 `G:\ai\deepseek harness output\workspace\projects\ds-harness-desktop`
  （`main` `88091a6` = 远端最新、工作区干净，`git pull` 已确认 up to date）。
  2026-09-22 一度另建的 `G:\ai\ds-harness-desktop` 属冗余克隆，核实无改动后已删除
  （结论以 DECISIONS 同日「纠正」条目为准）。
- 无自动化测试与 lint；验证 = `npm start` 人工冒烟 + 打包守卫输出。

## 关键文档

- 仓库根 `AGENTS.md`：agent-loop 启动指引、架构快照、命令、8 条硬约束（先读它）。
- `docs/`：设计方案 / 使用方法 / 分发说明；`过程记录/`：按次会话日志（最新 2026-09-10）。
- 远程仓库：https://github.com/ljr282341583/ds-harness-desktop
- agent-loop 长期记忆根不在本仓库内（另一工作区的 `projects/dsh-desktop-updater/.agent-loop/`），
  本项目跨机思路断点以**本大脑目录**为准。

## 约定 / 硬约束（违反即回退）

1. 内置 dsh 版本是保底：任何更新失败都必须能回到内置版本。
2. 打包守卫必须保留：拒绝 `cordis.patch.yml` 含 `compression: none` 的构建。
3. `app/runtime/` 只含 `node.exe`、**不含 npm**，不入库。
4. `~/.dsh` 是共享数据目录，测试一律 `DSH_HOME` 重定向到临时目录。
5. 便携版每次启动自解压到临时目录，无法原地自更新。
6. 版本判断只认顶层 `@deepseek-ai/dsh` 的 dist-tags；依赖用精确版本（无 `^`）。
7. 上游 RC 同版本号可能重发布，以 `dist.integrity` 判内容。

## 外部环境（2026-09-25 A机 核实；定位是否调整**尚未拍板**）

- **官方桌面端（Electron）已上线预览/偷跑态**：源码在官方仓库 `apps/desktop` + `apps/desktop-host`
  （复用现有 Web UI 与 Agent/会话/插件逻辑，自带托盘/单实例/自动更新/强制更新策略）；Windows 包
  `deepseek-harness-0.1.7-rc.1.20260924.1-win-x64.exe` 在 `download.deepseek.com/dsh-desk/bin/win-x64/`
  实测存在、客户端内可自更新到 **0.1.7-rc.2**；**官网与 GitHub Release 尚无下载入口**（未官宣）。
- 与本项目重叠：免命令行、内置 dsh、托盘 + 自动更新。本项目差异面：可退回内置 dsh 保底、可锁 dsh
  精确版本、无账号/实名门槛、有打包守卫与 `verify:smoke` 体检；官方缺口：无 Linux 版。
- 讨论稿与待核实项见 `JOURNAL\2026-09-25-A机.md` 追加节、`NEXT.md` 第 9 条。
