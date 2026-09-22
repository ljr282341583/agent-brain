# NEXT — DSH双击协作(DevHandoff)

> 断点唯一真相源。收尾必更新;过时事项挪进当篇 JOURNAL,不堆积也不删历史。
> 最近更新:2026-09-22 A机

## 进行中

- 跨机接力基础设施已就绪(大脑仓库已上 GitHub,skill/约定已去盘符化);
  待:重启 A 机会话验证 `session-handoff` skill 出现,并试跑首次"收尾"

## 下一步(按顺序)

1. A 机:重启会话,说"收尾"试跑,验证全链路(写日志 / 推大脑仓库)
2. B 机:clone 大脑仓库到本机任意路径(建议 `%USERPROFILE%\agent-brain`),DSH 新会话说「按 `<clone路径>\README.md` 的新机器初始化清单配置」,重启后按 README 验证三连
3. 用户:真要开工 DevHandoff 代码时,建 GitHub 私有仓库(名字待定)并推送本地首提交(b3de14d);B 机届时再 clone 项目代码仓库
4. 开发:按 PRD §15 顺序启动 DevHandoff MVP(细则见 `PRD-DevHandoff.md` §15)

## 已知坑

- 暂无
