# DECISIONS — DSH双击协作(DevHandoff)

> 只记"拍板了的":决定 + 理由 + 否决过的备选。讨论中 / 待确认的只进 JOURNAL。

## 2026-09-22 跨机思路同步:先落零代码方案(agent-brain),DevHandoff 后续产品化

- **决定**:立即用 `G:\ai\agent-brain\` 私有 git 仓库 + markdown 四件套(CONTEXT / DECISIONS / NEXT / JOURNAL)承担两台机器之间的思路同步,"收尾"由 `session-handoff` skill 自动化;DevHandoff 作为该流程的产品化升级继续开发。
- **理由**:零新依赖、当天可用、agent 直接读写文件零集成;且数据形态(结构化交接记录 + commit 锚点)与 DevHandoff PRD 完全同构,手动跑通等于提前验证产品的数据模型。
- **否决**:
  - Notion —— agent 访问必须走 API/MCP,两台机器都要维护 token,国内网络不稳;
  - 同步原始对话 —— 噪音大、烧 token,80% 是被推翻的探索过程;
  - Mem0 / Zep 类记忆服务 —— 检索结果不可控、多一个服务要养、看不到全貌;
  - 笔记随各项目仓库走 —— 跨项目引用和"未成项目的想法"没有容身之所,Obsidian 无法一个 vault 看全部。

## 2026-09-22 agent-brain 采用"独立大脑仓库"模型

- **决定**:一个私有仓库集中所有项目的笔记;代码仍在各自仓库;两机 clone 到相同路径 `G:\ai\agent-brain\`。
- **理由**:项目多、体量小、互相借鉴频繁;一个 vault 全局搜索 / 双链;代码仓库保持干净、随时可开源。
- **代价**(接受):收尾要推两个仓库(skill 一条龙解决);笔记与代码版本靠 commit 短哈希锚定,不对应即提示先 pull。

## 2026-09-22(源自 PRD)上下文与代码版本的关联点

- **决定**:用 Git Commit Hash 作为代码状态与 AI 开发上下文的唯一关联点;当前 commit 与上下文 commit 不一致时必须显式警告(PRD §5.4、§14)。
- **理由**:分支会漂移,commit 不可变;这是 PRD 结论节标注的最关键设计决策。
