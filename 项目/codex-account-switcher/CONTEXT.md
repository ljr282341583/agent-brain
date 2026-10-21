# CONTEXT — codex-account-switcher（Codex 账号切换器）

> 新会话 / 另一台机器开工前必读。项目定位或阶段大变时更新本文件。
> 建档：2026-10-21 A机

## 项目是什么

Windows 桌面小工具（Python + tkinter，PyInstaller 打包成目录版 / 单文件版），用来**在多个 Codex 账号之间切换登录态，而本地会话一条都不丢**。

原理（一句话）：Codex 把「登录凭据 `auth.json`」「供应商配置 `config.toml`」「会话记录 `sessions\` + `state_5.sqlite`」分开存放；本工具**只复制前两样文件**，从不写会话目录。所以"不掉会话"不是靠备份恢复，而是根本不碰。

- **当前主证路径（本机）**：`G:\ai\deepseek harness output\workspace\projects\codex-account-switcher`
- **代码仓库**：**暂无**（项目文件夹还没 `git init`，文件不受版本管理保护）
- **当前阶段**：v1.0.0 可用。两份 exe 已用**图标 v2** 重建，`build.ps1` 全流程（语法检查 + 48 项逻辑测试 + 17 项界面测试 + 打包）全绿；用户已存第一份快照「主号」，**但「切换选中账号」尚未真机实测**。

| 产物 | 路径 | 说明 |
| --- | --- | --- |
| 目录版（推荐） | `dist\CodexAccountSwitcher\CodexAccountSwitcher.exe` | 同目录 `_internal` 是运行库，整个文件夹一起搬 |
| 单文件版 | `portable\Codex账号切换器.exe` | 拷到哪都能跑；启动时在自身旁解压 `_MEI*`（必须带 `--runtime-tmpdir .`） |
| 桌面快捷方式 | `桌面\Codex 账号切换器.lnk` | 指向目录版 exe，图标取 **exe 内嵌资源**（`…exe,0`） |

## 代码构成

```
core.py            纯逻辑:快照/切换/回滚/会话统计/备份(无界面依赖,可单测)
ui.py              tkinter 界面(暗色主题,卡片+表格+日志)
test_core.py       逻辑测试 48 项(全在临时目录跑)
test_gui.py        界面层测试 17 项(Tk 窗口自动化驱动)
make_icon.py       生成 icon.ico / icon-preview.png / icon-sheet.png
make_demo_home.py  造一份假 CODEX_HOME 供预览截图
dev-shot2.ps1      开发用:启动程序并 PrintWindow 截图(不抢焦点)
build.ps1          一键构建:测试 → 生成图标 → 目录版 + 单文件版
```

## 用户环境（本机 A机，改动前必知）

- `CODEX_HOME` = `C:\Users\Administrator\.codex`
- 当前登录：**API Key**（DeepSeek 中转；`model_provider = deepseek`，`base_url = https://api.deepseek.com/`，`model = deepseek-v4-flash`，`wire_api = responses`）
- ⚠️ **该 key 同时写在两处**：`auth.json` 的 `OPENAI_API_KEY` 与 `config.toml` 的 `[model_providers.deepseek].experimental_bearer_token`（涉及密钥配置，已脱敏）。Codex 走 DeepSeek 时认的是 config 里那把 → **保存/切换必须勾「同时切换 config.toml」**。
- `config.toml` 230 行：另有 37+ 条项目信任（`[projects.'…']`）、MCP（`node_repl` / `cua_repl`）、插件与 marketplaces、desktop / features / memories。本工具**整份覆盖**，不做字段合并。
- 会话量：119 条（91 活动 / 28 归档）。
- `.codex` 目录 ACL 有 Codex Windows 沙箱遗留：**46 条孤儿 SID 的 DENY 写入 ACE** + `CodexSandboxUsers`(RX)；`codex-windows-sandbox-service` 常驻。2026-10-21 00:38 曾偶发「保存失败 [WinError 5]」。
- 用户是**非技术用户**：解释一律**大白话**，少用术语，先说结论再说原因。

## 关键文档

- 项目 `README.md` — 权威：功能、三步上手、安全设计、常见问题、构建步骤，以及本机两个已固化的构建坑（`.ps1` 必须 UTF-8 with BOM；单文件版必须给 `--runtime-tmpdir`）。
- `icon-sheet.png` — 图标各尺寸实拍（上排 1:1、下排放大），改图标后必看。
- `icon-comparison.png` — 新旧图标对照。
- `icon.ico`（v2 当前）、`icon-v1.ico` / `icon-v1-preview.png`（旧版备查）。

## 约定

- 文档与界面中文；对用户解释用大白话闭环。
- 红线：密钥 / token / 内网地址不进任何笔记；`CODEX_HOME\accounts\` 里是**明文凭据**，别同步网盘、别入 git。
- 改图标：改 `make_icon.py` → `python make_icon.py`（看 `icon-sheet.png` 自查）→ `build.ps1`。
- 改 `.ps1` 必须存成 **UTF-8 with BOM**（PowerShell 5.1 否则按 GBK 解析报错）。
- 构建：`powershell -ExecutionPolicy Bypass -File build.ps1`（先测试后打包；打包后要重新打包才生效图标/代码改动）。
