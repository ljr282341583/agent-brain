# CONTEXT — DSH双击协作(DevHandoff)

> 新会话 / 另一台机器开工前必读。项目定位或阶段大变时更新本文件。

## 项目是什么

DevHandoff:跨设备 AI 开发上下文同步平台。解决 A/B 两台电脑之间代码能 git 同步、
但 AI 对话 / 开发思路 / 技术决策 / 未完成任务无法同步的问题。不恢复原始聊天窗口,
而是把开发上下文与 Git 分支 + Commit Hash 关联,供另一台机器的 Agent 读取后继续开发。

## 当前阶段(2026-09-22)

- **PRD 完成,代码未开始**:项目目录目前只有 `PRD-DevHandoff.md`(约 1440 行,含完整 PRD + 可直接投喂 Agent 的开发 Prompt)。
- 项目尚未 `git init`,尚未建 GitHub 仓库。
- 配套零代码先行版 **agent-brain 仓库**(本仓库)已落地:先手动跑通跨机流程,DevHandoff 是它的产品化 / 自动化版本。

## 关键文档

- `PRD-DevHandoff.md`(项目根):产品定位、MVP 范围、数据模型(User/Device/Project/ProjectBinding/Conversation/Message/Handoff/Decision/Task)、API 设计、Agent 上下文格式、技术栈、开发顺序、验收标准、安全要求。

## 核心设计(读 PRD 前先记住三条)

1. **Git Commit 是代码与上下文的唯一关联点**;交接记录必须绑定 branch + commitHash,版本不一致必须显式警告。
2. **Agent 默认读结构化交接记录,不读原始对话**;完整对话仅作可搜索存档。
3. 摘要必须区分"已决定 / 讨论中 / 待确认",不得凭空创造;用户手改版本优先。

## 技术栈(MVP)

- 前端:React + TypeScript + Vite + Tailwind + TanStack Query + Zod + React Hook Form
- 后端:Node + TypeScript + Fastify/NestJS + Prisma + PostgreSQL + JWT/安全 Cookie
- CLI:Commander / Oclif;测试:Vitest + Playwright + Supertest
- 工程:pnpm monorepo(`apps/web|api|cli` + `packages/*`),模块化单体,不上微服务

## 约定

- 文档 / README 用中文,代码与命名用英文。
- 先跑通 MVP 再扩展,不过度设计;外部输入必须校验;接口必须鉴权。
- 敏感信息默认拦截(`.env`、密钥、token),支持 `[REDACTED]` 替换,不上传整个代码仓库。
