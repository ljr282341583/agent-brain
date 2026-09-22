# agent-brain — 跨机开发思路仓库(大脑仓库)

> 私有仓库。存放所有项目的开发思路蒸馏笔记,靠 git 在多台机器之间同步。
> **每台机器 clone 到本机任意路径即可**;你用 Obsidian 打开本目录就是阅读器,
> agent 直接读写 markdown,零集成。本机的 clone 路径记录在 `%USERPROFILE%\.agent-brain`。

## 目录结构

```text
agent-brain\
├── README.md          本文件
├── machines.md        机器名登记(COMPUTERNAME → 代号)
├── inbox.md           随手想法、还没成项目的灵感
├── skills\            session-handoff skill 分发副本(各机初始化用)
└── 项目\              所有项目笔记统一住这里(一级目录保持清爽)
    └── <项目名>\      每个项目一个文件夹
        ├── CONTEXT.md     项目说明书:是什么、阶段、关键文档、约定
        ├── DECISIONS.md   决策日志:定了什么、为什么、否决过啥
        ├── NEXT.md        断点看板:进行中 / 下一步 / 已知坑(收尾必更新)
        └── JOURNAL\       流水账:每次收尾一篇,文件名 日期-机器.md
```

## 机器间仅存的两条约定

1. **三方同名**:DSH 项目文件夹名 = 代码仓库名 = 本仓库里的项目文件夹名(skill 靠目录名认路)。
2. **自定位**:大脑仓库 clone 路径各机自定;clone 后把路径写进本机 `%USERPROFILE%\.agent-brain`(一行,无引号)。除此之外,没有任何写死的盘符。

## 新手教程

- [教程1-日常开发流程.md](教程1-日常开发流程.md) —— 配置好的机器怎么日常用:A 机开新项目 → B 机接手,小白向
- [教程2-新电脑从零配置.md](教程2-新电脑从零配置.md) —— 一台全新电脑加入这套系统(主力机方向),从装软件开始
- [教程3-旧项目接入.md](教程3-旧项目接入.md) —— 已经写了一半的老项目怎么进这套系统:补课 → 首次收尾 → 建仓推送

## 两台机器的日常

**开局(接手开发)**

1. `git pull`(项目代码仓库 + 大脑仓库)
2. 对 agent 说:"先读大脑仓库里本项目的笔记再继续"
3. agent 读 CONTEXT / DECISIONS / NEXT,接上思路干活

**收尾(结束开发)**

1. 对 agent 说:"收尾"(装了 `session-handoff` skill 则全自动)
2. agent:定位大脑仓库 → 写 JOURNAL → 更新 NEXT → 有决策追加 DECISIONS → 提交并推送本仓库 + 项目代码仓库(日志自动带 commit 短哈希)

## 新项目接入(零配置)

在本仓库的 `项目\` 文件夹下新建以项目名命名的子文件夹,补上四件套即可;`session-handoff` skill
按当前工作目录名自动对应 `项目\<项目名>\`,不需要改 skill。

## 新机器初始化清单(B 机 / 第三台机第一次看这里)

1. clone 本仓库到**本机任意路径**(建议短而稳:`%USERPROFILE%\agent-brain` 或某盘 `\ai\agent-brain`)
2. 懒人路径:DSH 新会话对 agent 说「读 `<clone路径>\README.md`,按『新机器初始化清单』把跨机接力配置好」→ 它自动完成三件事:
   - 把本仓库 `skills\session-handoff\` 复制到 `%USERPROFILE%\.agents\skills\session-handoff\`
   - 把下方「全局约定」写入 `%USERPROFILE%\.dsh\AGENTS.md`
   - 把本机 clone 路径写入 `%USERPROFILE%\.agent-brain`
3. 重启会话,验证:问 agent 任一已有项目的断点(如"DSH双击协作 现在做到哪了"),能答出 = 通了
4. 首次收尾时 agent 会询问本机代号并登记进 `machines.md`

## 全局约定(复制进各机的 %USERPROFILE%\.dsh\AGENTS.md)

```markdown
## 跨机接力约定
- 所有项目的开发思路/决策/断点集中记录在「大脑仓库」(agent-brain,私有 git 仓库),统一放在其 `项目\` 子目录下。
- 大脑仓库本机位置记录在 `%USERPROFILE%\.agent-brain`(一行路径);该文件不存在时,
  依次探测 G:\ai\agent-brain、D:\ai\agent-brain、E:\ai\agent-brain、
  %USERPROFILE%\agent-brain,命中即用,全未命中则询问用户,确定后回写该文件。
- 开局:接到开发任务,若 <大脑根>\项目\<项目名>\ 存在,先读其中 CONTEXT.md、DECISIONS.md、
  NEXT.md 再动手,不要重复已否决的方案。
- 收尾:结束开发时用 session-handoff skill 蒸馏进度并推送「项目仓库 + 大脑仓库」。
```

## skill 正本与副本

- **运行正本**:各机 `%USERPROFILE%\.agents\skills\session-handoff\`(DSH 从这里加载)
- **分发副本**:本仓库 `skills\session-handoff\`;更新 skill 时先改正本,再覆盖副本随仓库分发

## 红线

- 密钥、token、密码、内网地址**绝不**写入本仓库(进了 git 历史就删不干净)
- 笔记只写**结论和理由**:不搬运原始对话,不贴大段代码(单段 ≤ 5 行)
- NEXT.md 只保留"当前断点",过时事项挪进当篇 JOURNAL,不堆积也不删历史
- 接力模式:同一时间只在一台机器上开发;push 被拒先 `git pull --rebase` 再试
