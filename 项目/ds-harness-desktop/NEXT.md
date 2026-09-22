# NEXT — 当前断点（只保留“现在接着干”需要的信息）

## 进行中

- 无半成品：代码 `main` `88091a6`（v0.3.4）干净、与远端一致。

## 下一步

1. B机 开工：先 `git pull`（或 clone），对 agent 说“先读大脑仓库里 ds-harness-desktop
   的笔记再继续”。
2. A机 继续开发就在原项目文件夹
   `G:\ai\deepseek harness output\workspace\projects\ds-harness-desktop`；
   如想根治 `dubious ownership`，征得用户同意后执行
   `git config --global --add safe.directory <路径>`（目前未改全局配置）。
3. 下一轮开发内容未拍板（v0.3.4 之后的新需求 / 更新器后续），开工前先向用户确认方向。

## 已知坑

- 会话工作区 `G:\ai\deepseek harness output\workspace\projects\ds-harness-desktop`
  属主是 `BUILTIN/Administrators`，直接跑 git 报 `dubious ownership`；要么临时加
  `git -c safe.directory=<路径>`，要么执行 `git config --global --add safe.directory <路径>`
  （改全局配置，须用户确认）。
- `过程记录/` 最新只到 2026-09-10，v0.3.1–v0.3.4（09-11~09-14）的会话日志没补，
  细节只能 `git log --oneline` 看提交说明。
- 测试/升级验证必须 `DSH_HOME` 重定向，别污染 `~/.dsh` 的真实凭据与会话；
  `app/runtime/` 无 npm，“调用侧车自带 npm”不成立。

最近更新：2026-09-22 A机
