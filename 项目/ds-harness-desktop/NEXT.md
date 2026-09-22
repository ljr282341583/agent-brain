# NEXT — 当前断点（只保留“现在接着干”需要的信息）

## 进行中

- **v0.3.5 已正式发布**：tag `v0.3.5` → CI（run 35774840909，7m58s 全绿）→ 正式 Release
  四资产（连字符名）齐备；说明已用纠偏后的 release notes 重写（修掉 BOM 与错误的
  npm 声称）。**余下唯一一步 = 真机自更新验证。**

## 下一步

1. 真机复验自更新（历史「更新完打不开」事故现场）：本机已装 0.3.4 托盘「检查桌面端更新」→
   发现 0.3.5 → 下载安装重启 → 确认正常打开。注意：本机装的是**本地构建**的 0.3.4
   （侧车无 npm）；升到 CI 出的 0.3.5 后侧车含 npm。
2. ~~应用内 dsh 更新链路三选一拍板~~ **已作废（2026-09-23 纠偏）**：CI 发布物侧车一直含 npm
   （`scripts/prepare-runtime.ps1` 官方脚本拷入），应用内「检查 dsh 更新」可用；此前
   “不可用”结论取自本地从未跑过脚本的 runtime，属误判。遗留小项（可拍板）：本地打包前
   先跑 `app\scripts\prepare-runtime.ps1`——要不要挂进 `npm run build` 自动化、并在
   [2] 静态检查加「侧车含 npm」断言防回归。
3. 低价值清账（可选）：AGENTS.md Project Commands 过时 **且硬约束 3「runtime 无 npm」
   同样与现实不符**（源在外部 `.agent-loop/project.md`，须在源头改）、补 `app/README.md`
   （代码注释引用它）、`过程记录/` 补 v0.3.1–v0.3.4 四篇。
4. （可选）[5] 卸载断言加固：卸载后注册表卸载键消失才全绿（当前已断言文件移除 + 真安装体完好）。
5. B机接力：`git pull` 后对 agent 说“先读大脑仓库里 ds-harness-desktop 的笔记再继续”。

## 已知坑

- **NSIS 装/卸三大坑（本次全踩过，脚本化装/卸必读）**：① 安装器 `uninstallOldVersion`
  按注册表先跑旧版卸载器——temp 安装前必须**暂存并删除卸载注册表键**、结束后导回
  （[5] 已内置，漏做会把用户真实安装整个卸毁）；② 卸载器必须带 `_?=$INSTDIR` 否则它
  复制到 %TEMP% 异步跑、父进程秒回、在你收尾之后才补刀删文件；③ 安装/卸载按进程名
  `taskkill /im "DS Harness Desktop.exe"` 全杀同名实例（[5] 检测到正式实例即 SKIP）。
- NSIS `/D=` 含空格路径会被按空格截断：须把整个 `/D=...` 作为**一个带引号参数**传入
  （Node spawnSync 参数数组天然如此；PowerShell Start-Process 单字符串易翻车，WMI Create
  传完整带引号命令行最稳）。
- **侧车 npm 双态**：CI 发布物永远含 npm（prepare-runtime.ps1）；本地初始 runtime 没有
  （.gitignore 不入库）——本地包的「检查 dsh 更新」会报错，跑一次
  `app\scripts\prepare-runtime.ps1` 即补齐（2026-09-23 A机 已跑，npm 11.13.0）。
  AGENTS 硬约束 3 的「无 npm」说法只对没跑脚本的本地树成立。
- Node 24 禁止裸 spawn `.cmd`（EINVAL、status=null 无输出）：用 `node + npm-cli.js` 或 `cmd /c`；
  afterPack 已按此修复，新代码别再踩。
- desktop 模式死结：agent 跑在 desktop 的 dsh 服务里——关壳 = agent 断电，壳开着 = [5] 跳过；
  全量 [5] 需用户关壳后自己跑命令（网页版模式可破，未选）。例外：全局 `dsh web` 占 3080 时
  可代打会话（壳死会话也能续），但壳重开会探到“非己生实例”可能弹错误页——先关全局 dsh web 再开壳。
- 会话工作区属主 `BUILTIN/Administrators`，直接跑 git 报 `dubious ownership`：临时加
  `git -c safe.directory=<路径>`；根治须改全局 git 配置（用户未授权，勿擅动）。
- `过程记录/` 最新只到 2026-09-10（v0.3.1–v0.3.4 未补，细节看 `git log --oneline`）。
- 测试一律 `DSH_HOME` 重定向（verify:smoke 已内置）。

最近更新：2026-09-23 A机
