# NEXT — 小红书抖音去水印apk（轻取 / QingQu）

> 断点唯一真相源。收尾必更新；过时事项挪进当篇 JOURNAL，不堆积也不删历史。
> 最近更新：2026-09-27 B机（首次通读建档，CONTEXT/NEXT 由用户点名新建）

## 进行中

- 无进行中的编码任务。**纯本地版 v2.2 已完成、已构建、已上传 GitHub（私有）**，处于"可用但未真机验证"状态。

### 当前确凿状态（本次通读 + 校验得到）

- 最新 APK：`版本开发\纯本地APK版\轻取-v2.2-纯本地-debug.apk`，4,192,662 字节，versionCode 3 / versionName 2.2。
- **APK 与源码一致已证**：用当前源码重跑 `npm run build:web`，产出 `index-B2j434gl.css`(18,150B) 与 `index-C7SIkLLr.js`(220,757B)，与 APK 内 `assets/public/assets/` 两个文件**逐字节同大小同名**；全部源码 mtime 早于 APK 构建时刻。
- 三处同哈希副本：`版本开发\纯本地APK版\`（工作副本）、`github-upload\releases\`、`android\app\build\outputs\apk\debug\app-debug.apk`。
- 远程仓库：`ljr282341583/qingqu-media-saver`（私有，默认分支 main，单提交 `73fb6ae`，151 个文件）。本地 tree 与远程 tree 均为 `15400a065f78aa069301fba7312fa7b1b7221773`（一致）。
- 该会话**网络受限**：`github.com` 的 Git 传输被重置（本机代理当时未运行），改用 **GitHub API**（Contents 引导提交 + Git Data blobs/tree/commit）完成上传。事后用户本机 `git fetch` + `git reset --hard origin/main` 已成功，Git 通道恢复正常。

## 下一步（按顺序）

1. **执行迁名（方案 B，2026-09-27 已定）**：DSH 文件夹 `小红书抖音去水印apk` → `qingqu-media-saver`，与仓库名、本笔记名对齐。脚本已备好并做了人工备份：

   ```powershell
   # 迁移（幂等；必须在“别的项目会话”或普通 PowerShell 窗口执行）
   pwsh -NoProfile -File "G:\ai\_qingqu-migrate\migrate-project-name.ps1"
   # 出问题就回滚
   pwsh -NoProfile -File "G:\ai\_qingqu-migrate\rollback-project-name.ps1"
   ```

   - 已有备份：`G:\ai\_qingqu-migrate\backup-manual-20260927-110336\`（7 个会话文件 + `workspace.json`，共 4.96 MB）
   - 脚本会自动备份、检查 DSH 是否在跑、改完校验 JSON；**不要在本项目会话里执行**（该文件夹就是本会话工作目录，改完本会话作废）
   - 执行后：完全退出并重启 DSH → 打开 `qingqu-media-saver` → 确认旧会话都在且能打开
   - 若 `workspace.json` 被应用回写（项目名又变旧），关掉应用再跑一次脚本
2. **仓库工作副本归位**：当前 Git 工作副本是**另建的** `github-upload\`，违反「项目仓库一律用原来的项目文件夹、不另建克隆副本」约定。需把这套整理后的目录结构（根=纯本地版 / `versions\server\` / `releases\` / `docs\`）与"原文件夹"合并方案定下来再动。
3. **让"克隆即可构建"成立**：仓库里只有 `capacitor.config.ts`，而 CLI 7.4.3 + Node 24 解析该 `.ts` 会失败（见已知坑），照 README 敲命令会卡住。建议把 `capacitor.config.json` 一并入库，或删除 `.ts`。
4. **构建脚本去机器化**：`android\build-apk.cmd` 写死了本机 SDK 与 Gradle 8.9 缓存绝对路径；同时 `gradle\wrapper\gradle-wrapper.properties` 指向未缓存的 8.14.3。应在别的机器/用户上验证一次，或改成参数化。
5. **仓库工程惯例**：补 `LICENSE`（需用户选授权类型）、`.gitattributes`（`* text=auto eol=lf`，本次上传已因 CRLF/LF 差异返工过）；补仓库描述与 Topics。
6. **发布形态**：建 Build/Release 与 tag `v2.2`，把 APK 作为 Release 附件（现在 3 个约 4MB 的 APK 直接躺在 `releases\` 目录里，会随每次克隆下载）。
7. **补齐未发布物**：本地已有 `轻取-v2.0-纯本地-debug.apk`（4,496,106B）但未入库，而 README 版本历史列了 v2.0；`tools\` 下 4 个验证脚本未入库（要入库需先把写死的 `..\..\data\qingqu.db` 相对路径参数化）。
8. **真机验证（最大空白）**：至今**没有任何真机/模拟器实测**（`adb devices` 为空）。需要实测 6 类链接——抖音视频/图集/动态照片、小红书视频/图集/实况图——并确认相册落盘、下载进度、原生粘贴、记录勾选删除、状态栏避让。
9. 补 `DECISIONS.md` 与 `JOURNAL\`（本项目建档时按用户要求只写了 CONTEXT/NEXT，但本会话决策量很大：本地化重构、Capacitor 版本回退、水印取舍、仓库形态）。

## 已知坑

- **`cap sync`/`cap copy` 会因 `capacitor.config.ts` 报错**：CLI 7.4.3 + Node 24 报 `Parsing capacitor.config.ts failed: Cannot read properties of undefined (reading 'CommonJS')`。本次构建的绕法是把 `.ts` 临时改名 → `cap copy` → 再改回来；`package.json` 的 `android:sync` 现在就是 `cap copy android`。**仓库里没有 `.json` 版本**，所以克隆后照 README 操作会失败。
- **`npm run android:sync` 与 README 写法不一致**：脚本用 `cap copy`（只拷 Web 资源），README 部分段落仍写 `cap sync`。改 Capacitor 插件/依赖时 `copy` 不更新原生依赖，需偶发手动 `sync`。
- **Gradle wrapper 与缓存不对口**：wrapper 指定 8.14.3（本机没缓存，联网下载会超时），实际靠 `build-apk.cmd` 里写死的缓存 Gradle 8.9；AGP 8.7.3 配 8.9 可用。换机必然踩这个。
- **中文路径会触发 AGP 报错**：`project path contains non-ASCII characters`，靠 `android\gradle.properties` 里的 `android.overridePathCheck=true` 放过。
- **Gradle 用户目录权限**：默认 `C:\Users\<用户>\.gradle` 可能不可写（`Could not create parent directory for lock file`），本项目把 `GRADLE_USER_HOME`/`ANDROID_USER_HOME` 指到项目内 `.gradle-home` / `.android-home`（已在 .gitignore 排除）。
- **JDK 与 Capacitor 大版本强绑定**：Capacitor 7.x 的 `capacitor\build.gradle` 要 `JavaVersion.VERSION_21`，本机只有 JDK 17 → `无效的源发行版：21`。回退到 6.2.1 解决；**不要随手升 Capacitor**。
- **AndroidX 版本会反向卡 compileSdk/AGP**：activity 1.11.0 / core 1.17.0 要求 compileSdk 36 + AGP ≥8.9.1；已回退到 activity 1.10.1 / core 1.16.0 配 compileSdk 35 + AGP 8.7.3。
- **沙箱内 Vite 的 spawn EPERM**：构建脚本统一加 `--configLoader native`，去掉会失败。
- **npm 写用户级缓存被拒（EPERM）**：安装依赖统一 `npm install --ignore-scripts --cache .npm-cache`。
- **抖音必须用 crawler UA**：普通匿名 Web 请求要新鲜 cookie，会报 `Fresh cookies ... are needed`；公开详情接口用 Googlebot UA 才返回数据。图文/动图另有 ld+json SEO 兜底。
- **小红书水印问题已定性、未解决**：审计确认这批公开页面只给 `H5_DTL`（大图）+ `H5_PRV`（缩略图），**没有**第二套明确无水印原图，也没有出现 `CRD_WM_WEBP`；视频 `masterUrl` 与 `backupUrls` 是同一文件的两个 CDN（哈希一致），不是干净版本；H.264/H.265 只是编码差异。**用户手动保存（官方通道）水印在右下角，本工具取的 H5_DTL 水印在画面中央**——说明是两份不同衍生文件。若平台把标识写进像素，换 URL 无解。用户已表态"就这样吧"，**不要反复重启这个话题**；除非用户再提，否则不做裁剪/AI 擦除（会改变原图）。
- **`data\` 目录含敏感物**：`test-cookies.txt`、抖音/小红书抓取页面与 state JSON、`qingqu.db`。（本笔记不复述内容。）**绝不入库**；`audit-output` 里的样本图/视频也不宜再分发。
- **两份工作区副本**：D 盘与 G 盘各有一份同内容项目，**写入不互相同步**（已用标记文件验证），编辑前先确认目标副本；用户实际常用的是 G 盘那份（PS 提示符可作判据）。
- **没有 git 远程推送能力时不要假装成功**：本次 `gh repo create` 成功但 `git push` 失败，是靠 API 才传上去的；下次遇到同类报错要区分"仓库已建"与"代码已传"。
- **DSH 会话是按「项目路径」编码存放的**：`~\.dsh\sessions\<编码路径>\<会话 id>\session.jsonl.zstd`。编码规则：`\`→`-`、空格→`~0020`、非 ASCII 字符→`~`+4 位**大写** UTF-16 十六进制，整体前后各加 `--`（本项目旧名编码为 `--G-ai-deepseek~0020harness~0020output-workspace-projects-~5C0F~7EA2~4E66~6296~97F3~53BB~6C34~5370apk--`）。项目登记表在 `~\.dsh\storages\workspace.json`（`projectId → path/title/sessionIds`），会话缓存 `storages\session_projcache.json` 存 `identity.cwd`，桌面端 Local Storage（leveldb）**不存**裸路径。**改项目文件夹名 = 文件夹 + sessions 目录 + workspace.json 三处一起改**，缺一处会话就"消失"（文件还在，只是挂不上）。
- **执行迁名时注意沙箱**：迁移脚本要写 `~\.dsh\...` 与 `G:\ai\agent-brain`，都在 DSH 项目工作区之外；若在另一个 DSH 会话里执行，可能被文件沙箱拦（workspace-write 策略），此时改用普通 PowerShell 窗口，或在该会话里就那一条命令申请放宽。
- **迁名会让正在使用旧路径的会话当场失效**：Windows 也不允许重命名被当作工作目录的文件夹（实测该目录独占打开被拒）。所以脚本的前置检查会拒绝在目标文件夹内执行。
