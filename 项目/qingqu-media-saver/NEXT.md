# NEXT — qingqu-media-saver（轻取 / QingQu）

> 断点唯一真相源。收尾必更新；过时事项挪进当篇 JOURNAL，不堆积也不删历史。
> 最近更新：2026-09-28 B机（抖音 403 已修，v2.3.2 经用户真机确认可用）

## 进行中

- **抖音 403 已修复并经真机确认**：用户反馈「这一版完美」。最终版本 **v2.3.2**。
- 修复过程连出三版（v2.3 → v2.3.1 → v2.3.2），前两版真机失败的原因与教训见 `JOURNAL\2026-09-28-B机.md`。
- **无进行中的编码任务。** 下一步都是收尾性/工程性事项。

### 当前确凿状态（2026-09-28 复核）

- 最新 APK：`版本开发\纯本地APK版\轻取-v2.3.2-纯本地-debug.apk`，**4,204,334 字节**，versionCode 6 / versionName 2.3.2，SHA256 `0CFA859CA7FAA2F2411690CDAC08872A79E316FFDEE58C16EA068A1F162C292E`。
- **真机状态：抖音三类链接（视频/图文/动态照片）可用**（用户实测）。视频拿到的是**干净直链**（非 `/playwm/` 水印端点）。
- **APK 与源码一致已证**：`apkanalyzer` 核对 versionName/versionCode；APK 内 `assets/public/assets/` 与 `dist/` 同名同大小；`DouyinWebExtractor` 在 dex 中。
- 注入脚本逻辑：`tools/verify-tap-js.mjs` **3/3 通过**（用**真实抓取的详情接口响应** + 模拟 axios 的 `readystatechange`/`responseText` 读取方式）。
- 项目文件夹**不是 git 仓库**；唯一仓库是 `github-upload\.git`（单提交 `73fb6ae` = **v2.2 代码，未同步 v2.3.2**）。
- DSH 会话仓：`~\.dsh\sessions\--G-ai-…-projects-qingqu-media-saver--\`。

## 下一步（按顺序）

1. **`github-upload\` 同步 v2.3.2 并决定仓库形态（需用户拍板，优先级最高）**：现在代码改在 `版本开发\纯本地APK版\`，而 git 仓库在另建的 `github-upload\`，**两者已脱节两版**（v2.3/2.3.1/2.3.2 都没进 git）。选项：①直接在项目文件夹 `git init` 并接管这个仓库（符合「项目仓库一律用原来的项目文件夹」约定）②继续沿用 `github-upload\` 同步。**动之前先问用户。**
2. **`tools\` 探针脚本入库**：21 个探针 + `verify-tap-js.mjs` + payload JSON 目前被 `.gitignore` 排除，且写死 Chrome 路径与本机路径。它们是抖音改版后重新定位的唯一抓手，建议参数化后入库。
3. **`_ROUTER_DATA` / 详情接口漂移的应对**：抖音改版即失效。改 `TAP_JS` 或 `EARLY_JS` 前**必跑 `tools/verify-tap-js.mjs`**；重新定位用 `webview-cdp-probe5/6/21.mjs`。
4. **回归小红书**：本次只实测了抖音。小红书链路虽经探针确认正常，但**改版后的端到端回归没跑**（图集/视频/实况图三类）。
5. **他机型 WebView 差异**：本次只在用户那一台机器验证。系统 WebView 版本过低或厂商魔改过的机型可能行为不同——这是 WebView 方案的固有风险。
6. **迁名工具包纳入版本管理**：仍只存在于 `G:\ai\_qingqu-migrate\`（非 git 仓库，约 60KB）。
7. **让"克隆即可构建"成立**：仓库里只有 `capacitor.config.ts`，CLI 7.4.3 + Node 24 解析该 `.ts` 会失败；应把 `capacitor.config.json` 一并入库或删掉 `.ts`。
8. **构建脚本去机器化**：`android\build-apk.cmd` 写死本机 SDK 与 Gradle 8.9 缓存绝对路径；wrapper 指向未缓存的 8.14.3。
9. **仓库工程惯例**：补 `LICENSE`、`.gitattributes`（`* text=auto eol=lf`）；补仓库描述与 Topics。
10. **发布形态**：建 Release 与 tag `v2.3.2`，把 APK 作为 Release 附件（现在 5 个约 4MB 的 APK 直接躺在目录里）。
11. **D 盘副本是否同步迁名（用户定）**：`D:\AI(CODEX)\...\projects\小红书抖音去水印apk` 未处理，且同样没有 git 仓库。
12. **大脑仓库接力**：本条笔记推送后，A 机 pull 即可拿到「抖音 403 根因 + WebView 方案 + 两处钩子教训 + 能力边界」的完整认知。

## 已知坑

### 抖音（2026-09-28 重大更新，影响最大）

- **匿名 HTTP 打抖音详情接口已彻底不可用**：`/aweme/v1/web/aweme/detail/` 被字节 **Argus 安全网关**拦成 `403 Blocked by ArgusSecurityPlugin Uifid Not Found`。16 种 UA/Referer 组合全灭；`iesdouyin/share/*` 分享页降级为 **2492 字节 WAF 挑战页**；老 `iteminfo` 接口返回 200 但 0 字节。**不要再花时间试 UA 和 Referer。**
- **⚠️ 最关键的一条：axios 用 `onreadystatechange` + `responseText` 读响应，只监听 `'load'` 事件抓不到。** v2.3.1 真机失败就栽在这。正确做法是覆盖 `XMLHttpRequest.prototype.responseText` 访问器（本项目在 `EARLY_JS` 与 `TAP_JS` 里各做了一层）。**这是通用教训，不只对抖音。**
- **详情接口的数据在页面里，只是要抢在 axios 之前**：桌面页**确实会调用**详情接口且**成功**（`status_code=0`，76KB，`aweme_detail.video.play_addr` 是 `douyinvod.com` 干净直链、还有 13 组 `bit_rate`）。不要因为探针没抓到就断定"页面不调接口"。
- **干净视频直链只在桌面页**；移动页 `<video>.src` 是 `/aweme/v1/playwm/` **水印端点**。**UA 选错就差一个水印**，所以 WebView 必须桌面 UA 优先。
- **`/playwm/` → `/play/` 的替换是陷阱**：`/play/` 返回 **HTTP 200 但 0 字节**，`/playwm/` 返回 404。永远不要做这个猜测替换。
- **WebView 不能用 1×1 极简尺寸**：抖音播放器懒加载，1×1 视口实测不触发 `<source>` 挂载。要用**全屏 + alpha=0 + 触摸穿透**（本项目做法）。
- **"取 cookie 再 Java 侧重放接口"这条路不通**：即使 WebView 里确实拿到了 `UIFID` cookie，Java 侧重放依然 403（还缺页面生成的请求签名）。只能用页面自己发出的请求。
- **抖音动态照片的伴生视频已被平台下线**：移动页/桌面页/iesdouyin 分享页三入口的 `_ROUTER_DATA` 图对象都只剩 `uri/url_list/download_url_list/height/width`，**没有 `video` 节点**。v1.0/v2.2 能取到 7–9 段，现只能保存静态图。**不要再找这个字段。**
- **图集/动图是 `_ROUTER_DATA` 直出，不是 XHR**：位置 `window._ROUTER_DATA.loaderData['note_(id)/page'].videoInfoRes.item_list[0]`。钩 XHR 抓不到它。
- **图文/动图作品不会触发详情接口**：`douyin.com/note/{id}` 只调 SEO related；`/video/{id}` 打开图文作品会 302 到别处。
- **`iesdouyin/share/slides/{id}` 已 302 → `douyin.com/note/{id}` → 404**：动图短链要走 `douyin.com/note/{同 id}`。
- **详情接口的宽高在 `it.video.width/height` 上，不在 `it` 上**；不继承会让结果页显示 `0P`。
- **图片只有 q75/q80 的 webp**，不是无损原图；URL 带 `x-expires` 签名会过期。扩展名要按真实格式给（webp），否则会把 webp 字节存成 `.jpg`——v2.2 就有这个缺陷。
- **小红书链路未受影响**：2026-09-28 复测正常（图集 7 图 7 实况、视频 masterUrl 720x1280）。不要因为抖音挂了去动小红书代码。

### 验证方法论（本次最大教训）

- **不要用手写的理想数据验证抓取逻辑**。v2.3/v2.3.1 的验证器喂的是我自己编的 DOM payload，只证明了逻辑自洽，真机一跑就废。
- **正确做法**：把真实响应从浏览器抓下来存成 payload → 在沙箱里**复刻页面真实的读取方式**（如 axios 的 `readystatechange`+`responseText`）→ 只留待测那一条通路。
- **"探针没抓到" ≠ "页面没有"**：v2.3.1 的探针没抓到详情响应，我据此判断"桌面页不调接口"，实际是**抖音自己加了 403 拦截、页面改从 SSR 初始数据取**，而页面其实调了。要抓全部网络请求 + 逐条取响应体才能下结论。

### 构建与环境

- **改 DSH 项目名必须「四处同改」**（本文件旧版写的"三处"是错的，2026-09-27 实测被它坑惨）：①项目文件夹 ②`.dsh\sessions` 下的项目编码目录 ③**每个会话文件头部里的 `cwd`** ④`workspace.json`。缺第③处 → 应用启动抛 `corrupt session log` → 工作区服务起不来 → 界面项目/会话全空（**数据没丢，是服务没起来**）。已固化成安全版脚本并配 40 项断言自测。
- **⚠️ 2026-09-27 修正上文**：旧版第 58 条曾断言"改项目文件夹名 = 文件夹 + sessions 目录 + workspace.json 三处一起改"——**该断言已被证明不完整**，以本条为准。
- **会话仓的任何改动都必须在 DSH 完全退出时做**：应用运行时持有登记表与目录监听；18:26 移走两个已登记的会话目录 → 18:27 内核退出、桌面端被关。安全版脚本已将其设为硬性前置检查（`-AllowRunningDsh` 可绕过但会警告）。
- **判断"能不能改名"只有一种可靠办法**：真改一次名再改回来。逐文件共享冲突探测（10.6 万项耗时 575 秒）既慢，又会**漏掉被 mmap 映射的文件**；进程 cwd / 句柄清单更不能当判据。
- **空壳会话容易被误判成"打不开/丢内容"**：判定法 = 解出该会话全部事件后看有没有 `user/message` / `assistant/message`，并检查事件 `seq` 是否连续（有缺口才是被截断）。本项目有两个这样的空壳（标题为空 → 侧栏回退显示项目名，两个还同名，特别像故障）。
- **迁名内核依赖 Node ≥ 22.15**（需要 `zlib.zstdCompressSync/zstdDecompressSync`）。本机 `C:\Program Files\nodejs\node.exe` 与 DSH 自带 runtime 都是 v24.16.0，可用。
- **会话日志是"多帧拼接"的 zstd 容器**：每写一批事件追加一帧。Node 的 zstd 解压**只读第一帧**就停，所以绝不能"整体解压→改→整体重压"（会把整段对话丢光）；只能逐帧扫描、**只重建第 1 帧**、其余帧字节级保留。
- **`cap sync`/`cap copy` 会因 `capacitor.config.ts` 报错**：CLI 7.4.3 + Node 24 报 `Parsing capacitor.config.ts failed: Cannot read properties of undefined (reading 'CommonJS')`。本次构建的绕法是把 `.ts` 临时改名 → `cap copy` → 再改回来；`package.json` 的 `android:sync` 现在就是 `cap copy android`。**仓库里没有 `.json` 版本**，所以克隆后照 README 操作会失败。
- **`npm run android:sync` 与 README 写法不一致**：脚本用 `cap copy`（只拷 Web 资源），README 部分段落仍写 `cap sync`。改 Capacitor 插件/依赖时 `copy` 不更新原生依赖，需偶发手动 `sync`。
- **Gradle wrapper 与缓存不对口**：wrapper 指定 8.14.3（本机没缓存，联网下载会超时），实际靠 `build-apk.cmd` 里写死的缓存 Gradle 8.9；AGP 8.7.3 配 8.9 可用。换机必然踩这个。
- **中文路径会触发 AGP 报错**：`project path contains non-ASCII characters`，靠 `android\gradle.properties` 里的 `android.overridePathCheck=true` 放过。
- **Gradle 用户目录权限**：默认 `C:\Users\<用户>\.gradle` 可能不可写（`Could not create parent directory for lock file`），本项目把 `GRADLE_USER_HOME`/`ANDROID_USER_HOME` 指到项目内 `.gradle-home` / `.android-home`（已在 .gitignore 排除）。
- **JDK 与 Capacitor 大版本强绑定**：Capacitor 7.x 的 `capacitor\build.gradle` 要 `JavaVersion.VERSION_21`，本机只有 JDK 17 → `无效的源发行版：21`。回退到 6.2.1 解决；**不要随手升 Capacitor**。
- **AndroidX 版本会反向卡 compileSdk/AGP**：activity 1.11.0 / core 1.17.0 要求 compileSdk 36 + AGP ≥8.9.1；已回退到 activity 1.10.1 / core 1.16.0 配 compileSdk 35 + AGP 8.7.3。
- **沙箱内 Vite 的 spawn EPERM**：构建脚本统一加 `--configLoader native`，去掉会失败。
- **npm 写用户级缓存被拒（EPERM）**：安装依赖统一 `npm install --ignore-scripts --cache .npm-cache`。
- **⚠️ 已失效（2026-09-28）：抖音用 crawler UA 打详情接口**。旧笔记写「公开详情接口用 Googlebot UA 才返回数据」——**现在无论用什么 UA 都 403**，见上文「抖音」小节。该条仅作历史记录保留。
- **v2.2 的"图文/动图另有 ld+json SEO 兜底"从未实现**：原代码在 `aweme_detail == null` 时直接抛「该抖音作品未返回公开资源」；爬虫 UA 的 SEO 页 ld+json 只有标题/作者/时长/封面，没有媒体直链，当不了兜底。已在 CONTEXT.md 改正。
- **小红书水印问题已定性、未解决**：审计确认这批公开页面只给 `H5_DTL`（大图）+ `H5_PRV`（缩略图），**没有**第二套明确无水印原图，也没有出现 `CRD_WM_WEBP`；视频 `masterUrl` 与 `backupUrls` 是同一文件的两个 CDN（哈希一致），不是干净版本；H.264/H.265 只是编码差异。**用户手动保存（官方通道）水印在右下角，本工具取的 H5_DTL 水印在画面中央**——说明是两份不同衍生文件。若平台把标识写进像素，换 URL 无解。用户已表态"就这样吧"，**不要反复重启这个话题**；除非用户再提，否则不做裁剪/AI 擦除（会改变原图）。
- **`data\` 目录含敏感物**：`test-cookies.txt`、抖音/小红书抓取页面与 state JSON、`qingqu.db`。（本笔记不复述内容。）**绝不入库**；`audit-output` 里的样本图/视频也不宜再分发。
- **两份工作区副本**：D 盘与 G 盘各有一份同内容项目，**写入不互相同步**（已用标记文件验证），编辑前先确认目标副本；用户实际常用的是 G 盘那份（PS 提示符可作判据）。G 盘那份已于 2026-09-27 迁名，D 盘那份**未迁名**。
- **没有 git 远程推送能力时不要假装成功**：本次 `gh repo create` 成功但 `git push` 失败，是靠 API 才传上去的；下次遇到同类报错要区分"仓库已建"与"代码已传"。
- **DSH 会话是按「项目路径」编码存放的**：`~\.dsh\sessions\<编码路径>\<会话 id>\session.jsonl.zstd`。编码规则：`\`→`-`、空格→`~0020`、非 ASCII 字符→`~`+4 位**大写** UTF-16 十六进制，整体前后各加 `--`（旧名编码为 `--G-ai-deepseek~0020harness~0020output-workspace-projects-~5C0F~7EA2~4E66~6296~97F3~53BB~6C34~5370apk--`，新名编码为 `--G-ai-deepseek~0020harness~0020output-workspace-projects-qingqu-media-saver--`）。项目登记表在 `~\.dsh\storages\workspace.json`。编码规则已固化在 `_qingqu-migrate\lib\session-tool.mjs` 里，不要手算。
- **执行迁名时注意沙箱**：迁移脚本要写 `~\.dsh\...` 与 `G:\ai\agent-brain`，都在 DSH 项目工作区之外；若在另一个 DSH 会话里执行，可能被文件沙箱拦（workspace-write 策略），此时改用普通 PowerShell 窗口，或就那一条命令申请放宽。
- **迁名会让正在使用旧路径的会话当场失效**：所以脚本的前置检查会拒绝在目标文件夹内执行，且要求 DSH 完全退出。若中途失败，**直接再跑一次即可**（v2 幂等），或反向跑回滚脚本。
