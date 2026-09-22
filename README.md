# agent-brain — 跨机开发思路仓库

> 私有仓库。存放所有项目的开发思路蒸馏笔记,靠 git 在 A/B 两机之间同步。
> 你用 Obsidian 打开本目录就是阅读器;agent 直接读写 markdown,零集成。

## 目录结构

```text
agent-brain\
├── README.md          本文件
├── machines.md        机器名登记(COMPUTERNAME → 代号)
├── inbox.md           随手想法、还没成项目的灵感
├── skills\            session-handoff skill 分发副本(B 机初始化用)
└── <项目名>\          每个项目一个文件夹
    ├── CONTEXT.md     项目说明书:是什么、阶段、关键文档、约定
    ├── DECISIONS.md   决策日志:定了什么、为什么、否决过啥
    ├── NEXT.md        断点看板:进行中 / 下一步 / 已知坑(收尾必更新)
    └── JOURNAL\       流水账:每次收尾一篇,文件名 日期-机器.md
```

## 两台机器的日常

**开局(接手开发)**

1. `git pull`(项目代码仓库 + 本仓库)
2. 对 agent 说:"先读 agent-brain 里本项目的笔记再继续"
3. agent 读 CONTEXT / DECISIONS / NEXT,接上思路干活

**收尾(结束开发)**

1. 对 agent 说:"收尾"(装了 `session-handoff` skill 则全自动)
2. agent:写 JOURNAL → 更新 NEXT → 有决策追加 DECISIONS → 提交并推送本仓库 + 项目代码仓库(日志自动带 commit 短哈希)

## 新项目接入(零配置)

在本仓库新建以项目名命名的文件夹,补上四件套即可;`session-handoff` skill
按当前工作目录名自动对应文件夹,不需要改 skill。

## B 机初始化清单

1. `git clone <本仓库地址> G:\ai\agent-brain` —— **路径必须与 A 机一致**(B 机没有 G 盘时,先让 A 机 agent 修改契约路径:SKILL.md 与 AGENTS.md 里的 `G:\ai\agent-brain` 全部替换,再重新分发)
2. 把下方「全局约定」代码块内容追加进 B 机的 `%USERPROFILE%\.dsh\AGENTS.md`(没有该文件就新建)
3. 把本仓库自带的 `skills\session-handoff\` 整个文件夹复制到 B 机 `%USERPROFILE%\.agents\skills\session-handoff\`(本仓库内是**分发副本**;A 机 `.agents\skills\` 里是**运行正本**,skill 更新时正本改完同步覆盖副本)
4. 首次收尾时 agent 会询问本机代号并登记进 `machines.md`

> 懒人路径:第 2、3 步可以不手动做——B 机装好 DSH 后新开会话,直接对 agent 说
> 「读 `G:\ai\agent-brain\README.md`,按 B 机初始化清单把跨机接力配置好」,它会自己完成。

## 全局约定(复制进各机的 %USERPROFILE%\.dsh\AGENTS.md)

```markdown
## 跨机接力约定
- 所有项目的开发思路/决策/断点集中记录在 `G:\ai\agent-brain\`(私有 git 仓库)。
- 开局:接到开发任务,若 `G:\ai\agent-brain\<项目名>\` 存在,先读其中
  CONTEXT.md、DECISIONS.md、NEXT.md 再动手,不要重复已否决的方案。
- 收尾:结束开发时用 `session-handoff` skill 蒸馏进度并推送两个仓库。
```

## 红线

- 密钥、token、密码、内网地址**绝不**写入本仓库(进了 git 历史就删不干净)
- 笔记只写**结论和理由**:不搬运原始对话,不贴大段代码(单段 ≤ 5 行)
- NEXT.md 只保留"当前断点",过时事项挪进当篇 JOURNAL,不堆积也不删历史
- 接力模式:同一时间只在一台机器上开发;push 被拒先 `git pull --rebase` 再试
