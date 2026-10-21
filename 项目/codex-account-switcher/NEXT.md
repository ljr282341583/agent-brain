# NEXT — codex-account-switcher（Codex 账号切换器）

> 断点唯一真相源。收尾必更新；过时事项挪进当篇 JOURNAL，不堆积也不删历史。
> 最近更新：2026-10-21 A机

## 进行中

- 代码无半成品：v1.0.0 功能完整，图标 v2 已重建两份 exe，`build.ps1` 全绿（48 + 17 项测试通过）。
- **用户侧只差最后一步验证**：已用脚本替用户存好第一份快照「主号」（API Key + 含 config.toml），但**用户还没在界面里点过「切换选中账号」**，端到端"切了真换号"未实测。
- 用户遇到过一次性「保存失败 [WinError 5] 拒绝访问 …\.codex\accounts」，已人工建档兜底；根因未复现（详见 JOURNAL 与 DECISIONS 2026-10-21 最后一条）。

## 下一步（按顺序）

1. **让用户点一次「切换选中账号」并重启 Codex 验证真换号**。切换前会自动写 `.last-switch-*` 备份，切错可点「回滚上次切换」；这是唯一没实测的核心路径。
2. 若「保存 / 切换」**再次**报 WinError 5：给 `core.ensure_store()` 与各 `shutil.copy2` 加重试（3 次、0.3~0.5s 退避），失败时在界面提示「先关掉 Codex 再试」，并把错误原文写进操作日志；必要时再考虑"快照目录回退到 exe 同级"（需先问用户）。
3. **项目尚无 git 仓库**：建议 `git init` + 首次提交（`.gitignore` 排除 `dist\`、`portable\`、`__pycache__`、`*.spec`、`build\`、`_MEI*`）。是否入库待用户拍板。
4. 可选：写一个只读的 ACL 体检脚本，把 `.codex` 上 46 条孤儿 SID 的 DENY ACE 列给人看（**不要自动清理**，Codex 沙箱随时会再加，先证明无副作用再说）。
5. 图标若要再调：改 `make_icon.py`（配色 `C_START/C_MID/C_END`、`glyph_params()`、`_arrow_glyph()`）→ `python make_icon.py` 看 `icon-sheet.png` → `build.ps1`。
6. README 是否补一节「本机 `.codex` 权限踩坑」：建议**不写进通用 README**（属本机环境特有），只留在本笔记。

## 已知坑

- **用户那套 DeepSeek 的 key 在两处**（`auth.json` 的 `OPENAI_API_KEY` + `config.toml` 的 `[model_providers.deepseek].experimental_bearer_token`，涉及密钥配置、已脱敏）。Codex 认 config 里那把 → **保存/切换必须勾「同时切换 config.toml」**，否则白切。
- **`config.toml` 是整份覆盖**，不做字段级合并。里面有 37+ 项目信任、MCP、插件设置 → 勾选后切号会整份回到快照时的样子，之后新加的信任会丢，需要重新「保存当前登录为账号」覆盖更新。
- **`shell` 里改 `.ps1` 必须保 UTF-8 BOM**：用工具改文件（尤其 Python `read_text/write_text`）容易把 BOM 弄丢，PowerShell 5.1 会按 GBK 解析中文报错。补丁脚本请用 `utf-8-sig` 读写。
- **打包时若目标 exe 正在运行会复制失败**（文件被锁）。同卷 `Move-Item` 改名是允许的：可先把旧 exe 改名为 `.old.exe` 再写入新的，等用户关掉程序后再删旧文件。
- **PyInstaller onefile 的父进程只是引导器**：杀进程要 `taskkill /T`；也解释过为什么"截图后还留一个实例"。
- **窗口/任务栏图标来自打包时内嵌的 `icon.ico`**（运行时从 `_MEIPASS/icon.ico` 或同目录读）→ 换图标**必须重新打包**才生效，只换磁盘上的 ico 没用。
- **图标缓存**：换 exe 图标后资源管理器可能仍显示旧图/空白；`ie4uinit.exe -show` + `SHChangeNotify` 能刷新，必要时才重启 explorer。
- **`.codex` 上的沙箱遗留 ACL**（46 条孤儿 SID DENY + `CodexSandboxUsers` RX）会让"写 `.codex`"偶发被挡；遇到先复现再判断，别直接改代码。
- `test_gui.py` / `test_core.py` 都跑在临时目录，**不会碰真实 `CODEX_HOME`**；但 `dev-shot2.ps1` 默认用项目内 `.demo-home` 和 CWD 写 `_run_*.txt`，跑完记得清理。
