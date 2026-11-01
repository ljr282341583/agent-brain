# NEXT — 开发规范(断点)

> 只留当前断点,旧内容进 JOURNAL。最近更新:2026-11-01 A机

## 进行中

无。v1.0 **已发布**(GitHub Release `v1.0.0` + `ui-first-dev-installer-v1.0.0.zip`)且仓库**已转公开**;README 已改版为对外落地页。安装侧做到"小白可用",等待实战检验。

**现在装法三条**(2026-11-01 起):
1. 一句话:对 AI 说"把 https://github.com/ljr282341583/dev-workflow 装到这台电脑,装完自检并告诉我结果" → AI 读 `install/AGENT-INSTALL.md` 自己干完。
2. 双击:从 [Releases](https://github.com/ljr282341583/dev-workflow/releases/latest) 下 `ui-first-dev-installer-v*.zip` → 解压 → 双击 `安装.cmd`。
3. 命令行:`powershell -ExecutionPolicy Bypass -File .\install\install-machine.ps1`(默认 `-Target all`)。

> 本机(A机)三套已装好并自检全 ✅;B机 未试装(见已知坑)。


## 下一步

1. **实战验证一次**:下一个有界面的需求(哪怕是老项目加一屏)完整走 P0→P1,观察:用户能否顺畅从 2–3 套方向里选、门禁②是否形成真卡点、出稿耗时是否可接受。跑完回来按实际情况改 `WORKFLOW.md`。
2. 若 P1 出稿太慢:把 `templates/prototype/index.html` 的屏做成"复制一屏只改 data-screen"的程度,减少手写量。
3. 可选:对存量 APK 只做 P1 设计评审(候选:`计杯`、`货运计数`、`轻取`、`ds-harness-mobile`),不动代码,验证"改造"场景。
4. 技能里引用的是规范目录**绝对路径**;若移动目录,需同步改 `SKILL.md`「权威文档」表(那里有"目录丢失时用内联精简模板"的兜底)。
5. **发版流程**(改规范正文后):WORKFLOW.md 末尾补变更记录 → 同步 README「更新记录」→ `install\打包一键安装.ps1 -Version x.y.z` → `gh release create vX.Y.Z <zip> --notes-file ...`(资产名保持 ASCII)。
6. 可选增强:README 里加一个 15 秒演示 GIF(原型切四态/点确认弹层),比截图更直观。

## 已知坑

- **git 代理**:本机 `http.proxy/https.proxy = 127.0.0.1:7897`,代理没起时 push 会报 `Failed to connect ... via 127.0.0.1`。绕过:`git -c http.proxy= -c https.proxy= push`(已实测可用),或先启动代理。
- 用 Edge headless 对 `file://` 中文路径截图会失败:先把 html 复制到 `%TEMP%` 纯 ASCII 目录再截。
- 技能能否被自动加载,取决于模型是否读到 AGENTS.md 红线并主动调 `skill`;万一没触发,直接说"按开发规范来"即可强制。
- 规范对"纯后端 / 脚本 / 数据处理"不设门禁,别把 P0–P5 套到无界面任务上(会把小事做重)。
- 中文项目名 `开发规范` 对应的 GitHub 仓库用了 ASCII 名 `dev-workflow`(GitHub 地址/克隆更稳);大脑仓库目录仍叫 `开发规范`,两边不一致属已知。
- **换机器装法**:`git clone` dev-workflow → 跑 `install\install-machine.ps1`(用 `powershell -ExecutionPolicy Bypass -File`,本机没有 `pwsh` 命令)。默认 `-Target all`,装「DSH/Codex/Claude 三套技能 + 对应红线 + 工作区 §2.6」,未安装的工具自动跳过;**工作区根自动探测**(当前目录向上 → 本仓库向上 → `storages\workspace.json` 登记路径),不写死盘符;探测不到只提示不瞎改,可 `-WorkspaceAgents <目录|AGENTS.md>` 显式指定或 `none` 跳过。实测:自动、显式目录、显式不存在、none 四种情形均正确。
- 安装脚本必须是 **UTF-8 带 BOM**,否则 Windows PowerShell 5.1 会把中文读成乱码并报语法错(踩过一次)。
- 本机已铺三套(2026-11-01):`.agents\skills`+`.dsh\AGENTS.md`(DSH)、`.codex\skills`+`.codex\AGENTS.md`(Codex)、`.claude\skills`+`.claude\CLAUDE.md`(Claude)。注意本机 **`claude` 命令不在 PATH**,`~\.claude` 目录是既有的;真正装 Claude Code 后它默认读该 CLAUDE.md。
- 脚本改过 `$home` 变量名踩坑(PS 里 `$HOME` 是只读自动变量,函数参数不能叫 `$home`),已改为 `$baseDir`。
- **B机路径未实测**:历史笔记里 B机 项目路径都是 `G:\ai\deepseek harness output\workspace\projects\…`(同 A机),推断工作区根相同,但未在 B机 上验证;若不同,靠自动探测或 `-WorkspaceAgents` 兜底。
- **gh release 上传中文文件名会被改名**:`gh release upload` 把 `UI优先开发流程-安装包-v1.0.0.zip` 改成了 `UI.-.-v1.0.0.zip`。对策:zip 资产名保持 ASCII(`ui-first-dev-installer-v*.zip`),zip 内部文件夹名可以中文。`gh release create --notes-file` 比 `--notes` 稳(长中文内联易被 PowerShell 参数解析截断)。
- 仓库已**转公开**(2026-11-01),地址不变;公开前已 `git grep` 扫过密钥/token/私钥/内网 IP,零命中。大脑仓库仍私有。
- 本机 `dist\` 里是打包产物,已 `.gitignore`;发新版时重新跑 `install\打包一键安装.ps1` 再 `gh release upload`。
