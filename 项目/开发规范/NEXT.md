# NEXT — 开发规范(断点)

> 只留当前断点,旧内容进 JOURNAL。最近更新:2026-11-01 A机

## 进行中

无。v1.0 已完成并推送,等待实战检验。

## 下一步

1. **实战验证一次**:下一个有界面的需求(哪怕是老项目加一屏)完整走 P0→P1,观察:用户能否顺畅从 2–3 套方向里选、门禁②是否形成真卡点、出稿耗时是否可接受。跑完回来按实际情况改 `WORKFLOW.md`。
2. 若 P1 出稿太慢:把 `templates/prototype/index.html` 的屏做成"复制一屏只改 data-screen"的程度,减少手写量。
3. 可选:对存量 APK 只做 P1 设计评审(候选:`计杯`、`货运计数`、`轻取`、`ds-harness-mobile`),不动代码,验证"改造"场景。
4. 技能里引用的是规范目录**绝对路径**;若移动目录,需同步改 `SKILL.md`「权威文档」表(那里有"目录丢失时用内联精简模板"的兜底)。

## 已知坑

- **git 代理**:本机 `http.proxy/https.proxy = 127.0.0.1:7897`,代理没起时 push 会报 `Failed to connect ... via 127.0.0.1`。绕过:`git -c http.proxy= -c https.proxy= push`(已实测可用),或先启动代理。
- 用 Edge headless 对 `file://` 中文路径截图会失败:先把 html 复制到 `%TEMP%` 纯 ASCII 目录再截。
- 技能能否被自动加载,取决于模型是否读到 AGENTS.md 红线并主动调 `skill`;万一没触发,直接说"按开发规范来"即可强制。
- 规范对"纯后端 / 脚本 / 数据处理"不设门禁,别把 P0–P5 套到无界面任务上(会把小事做重)。
- 中文项目名 `开发规范` 对应的 GitHub 仓库用了 ASCII 名 `dev-workflow`(GitHub 地址/克隆更稳);大脑仓库目录仍叫 `开发规范`,两边不一致属已知。
- **换机器装法**:`git clone` dev-workflow → 跑 `install\install-machine.ps1`(用 `powershell -ExecutionPolicy Bypass -File`,本机没有 `pwsh` 命令)。脚本装「技能 + `~/.dsh/AGENTS.md` 红线 + 工作区 §2.6」;**工作区根自动探测**(当前目录向上 → 本仓库向上 → `storages\workspace.json` 登记路径),不写死盘符;探测不到只提示不瞎改,可 `-WorkspaceAgents <目录|AGENTS.md>` 显式指定或 `none` 跳过。实测四种情形(自动/显式目录/显式不存在/ none)均正确。
- 安装脚本必须是 **UTF-8 带 BOM**,否则 Windows PowerShell 5.1 会把中文读成乱码并报语法错(踩过一次)。
- **B机路径未实测**:历史笔记里 B机 项目路径都是 `G:\ai\deepseek harness output\workspace\projects\…`(同 A机),推断工作区根相同,但未在 B机 上验证;若不同,靠自动探测或 `-WorkspaceAgents` 兜底。
