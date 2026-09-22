# NEXT — 当前断点（只保留“现在接着干”需要的信息）

## 进行中

- 发版流程走了一半：0.3.5 升号、分发文档如实化、release notes 草稿已提交（`f174b90`）；
  [5] 三重保险加固随本次收尾提交。**余下 = 打 tag → GitHub Release → 真机自更新验证。**

## 下一步

1. 收尾汇报后打 tag `v0.3.5` → `git push origin v0.3.5` → GitHub Releases 新建**正式** Release
   （非 Draft，Draft 用户收不到推送）→ 上传 4 文件：`DS Harness Desktop Setup 0.3.5.exe`、
   同名 `.blockmap`、`DS Harness Desktop-0.3.5-portable.exe`、`latest.yml`。
   **文件名一个字都不能改**（latest.yml 记录的是原文件名，改名即 404）；Release 描述直接贴
   `docs/release-notes-v0.3.5.md`。
2. 真机复验自更新（历史「更新完打不开」事故现场）：本机已装版托盘「检查桌面端更新」→
   发现 0.3.5 → 下载安装重启 → 确认正常打开。
3. 应用内 dsh 更新链路三选一拍板（不变：a npm 入侧车 +10~15MB / b registry tarball +
   Windows 自带 tar.exe 解压（推荐）/ c 砍掉改走外壳更新）；分发说明两处「暂不可用」
   文案随拍板定稿。
4. 低价值清账（可选，不变）：AGENTS.md Project Commands 过时（“无自动化测试”已不成立）、
   补 `app/README.md`（代码注释引用它）、`过程记录/` 补 v0.3.1–v0.3.4 四篇。
5. （可选）[5] 卸载断言加固：卸载后注册表卸载键消失才全绿（当前只断言文件移除+真安装体完好）。
6. B机接力：`git pull` 后对 agent 说“先读大脑仓库里 ds-harness-desktop 的笔记再继续”。

## 已知坑

- **NSIS 装/卸三大坑（本次全踩过，脚本化装/卸必读）**：① 安装器 `uninstallOldVersion`
  按注册表先跑旧版卸载器——temp 安装前必须**暂存并删除卸载注册表键**、结束后导回
  （[5] 已内置，漏做会把用户真实安装整个卸毁）；② 卸载器必须带 `_?=$INSTDIR` 否则它
  复制到 %TEMP% 异步跑、父进程秒回、在你收尾之后才补刀删文件；③ 安装/卸载按进程名
  `taskkill /im "DS Harness Desktop.exe"` 全杀同名实例（[5] 检测到正式实例即 SKIP）。
- NSIS `/D=` 含空格路径会被按空格截断：须把整个 `/D=...` 作为**一个带引号参数**传入
  （Node spawnSync 参数数组天然如此；PowerShell Start-Process 单字符串易翻车，WMI Create
  传完整带引号命令行最稳）。
- Node 24 禁止裸 spawn `.cmd`（EINVAL、status=null 无输出）：用 `node + npm-cli.js` 或 `cmd /c`；
  afterPack 已按此修复，新代码别再踩。
- desktop 模式死结：agent 跑在 desktop 的 dsh 服务里——关壳 = agent 断电，壳开着 = [5] 跳过；
  全量 [5] 需用户关壳后自己跑命令（网页版模式可破，未选）。例外：全局 `dsh web` 占 3080 时
  可代打会话（壳死会话也能续），但壳重开会探到“非己生实例”可能弹错误页——先关全局 dsh web 再开壳。
- 会话工作区属主 `BUILTIN/Administrators`，直接跑 git 报 `dubious ownership`：临时加
  `git -c safe.directory=<路径>`；根治须改全局 git 配置（用户未授权，勿擅动）。
- `过程记录/` 最新只到 2026-09-10（v0.3.1–v0.3.4 未补，细节看 `git log --oneline`）。
- 测试一律 `DSH_HOME` 重定向（verify:smoke 已内置）；`app/runtime/` 无 npm，
  “调用侧车自带 npm”不成立。

最近更新：2026-09-23 A机
