# NEXT — qingqu-media-saver（轻取 / QingQu）

> 断点唯一真相源。收尾必更新；过时事项挪进当篇 JOURNAL，不堆积也不删历史。
> 最近更新：2026-10-01 A机（v2.3.3→v2.3.7 连修抖音水印/动态照片；**v2.3.7 尚未真机确认**；项目仓库 HEAD `93c2b4d`）

## 进行中

- **抖音「视频带水印 + 动态照片变静态图」的排查收尾在 v2.3.7，等真机确认。**
  - 已实证：**桌面页能拿到干净视频 + 图片 + 伴生视频三件套；移动页只有 `/playwm/` 水印视频、且图片不带伴生视频**。
  - 真机反馈（v2.3.5 结果页出现「当前仅取到平台带标识的公开版本」）坐实：**用户设备上走的是移动页回落**，即**桌面页在真机上拿不到数据**。
  - **桌面页为什么拿不到数据：仍未定位**（推断是被 WAF/验证页挡住，未证）。v2.3.6 起结果页会带［诊断：…］，内含各加载策略被放弃时的页面状态——**下一步就靠这个拿真机现场**。
- **`轻取-v2.3.7-纯本地-debug.apk` 已构建并核验**（4,207,054 字节 / SHA256 `DEBE9CF2…` / versionCode 11），在本机 `版本开发\纯本地APK版\`（`*.apk` 已 gitignore，不入库）。
- **最新对外发布仍是 v2.3.2**（tag + Release + APK 附件，均未被本次改动触碰）；v2.3.3–v2.3.7 都**没有发布**。

### 当前确凿状态（2026-10-01 复核）

- **仓库**：项目文件夹本身即 git 仓库，remote `ljr282341583/qingqu-media-saver`，HEAD `93c2b4d`，tag `v2.3.2`，LICENSE = MIT。A 机本次从空目录 clone 落点 `a84b57f`、283 个跟踪文件、`fsck` 通过。
- **v2.3.2 Release 原样保留**：`qingqu-v2.3.2-debug.apk`，4,204,334 字节，SHA256 `0CFA859CA7FAA2F2411690CDAC08872A79E316FFDEE58C16EA068A1F162C292E`（用户明确要求：**不要覆盖历史 APK 版本**）。
- **A 机构建链路实测一次通过**：JDK 17.0.19 / 用户级 Gradle 8.9 缓存 / SDK `%LOCALAPPDATA%\Android\Sdk` 自动探测 / 依赖端点全通；缺 build-tools 35.0.0 由 AGP 自行绕过。
- 注入脚本逻辑：`tools\verify-tap-js.mjs` **3/3 通过**（注意：它现在也校验 `__QQ_EXPECT_IMAGES__` 占位符，模板缺占位符会直接报错退出）。
- **入库前已脱敏**：`tools\sanitize-for-repo.mjs`（`--check` 可只检查）覆盖分享 token 与 CDN 签名；**探针产物**（含 `biz_sign`/`uifid`/`sign`，规则覆盖不到）已由 `.gitignore` 排除 `tools/probe2*-*.json`，只入库脚本。
- DSH 会话仓：`~\.dsh\sessions\--G-ai-…-projects-qingqu-media-saver--\`。

## 下一步（按顺序）

1. **拿真机诊断，定位「桌面页为什么拿不到数据」**：让用户装 v2.3.7 试抖音视频链接，把结果页那行**［诊断：…］**原样发回。看 `url/title/video 数/source 数/有无 _ROUTER_DATA` 就能判断是**验证页**、**钩子没装上**、还是**页面结构变了**。这一条是下面 2、3 条的前置。
2. **动态照片（动图）修复**：数据只在桌面页（移动页 `imagesWithVideo: 0`），桌面页通不通决定能不能修。`DECISIONS.md` 里 2026-09-28「伴生视频已下线、不做补救」**已被推翻**，别再按"已下线"处理。
3. **确认 v2.3.7 的水印改写是否生效**：若真机仍有水印，看提示里的自述——
   ［换干净地址：无可用候选］= 地址没生成（多为 `video_id` 指向 URL 的形态，已故意不改写）；
   ［换干净地址：候选校验未通过］= 校验又挡住了（附［诊断：…］）。
4. **把 `@capacitor/cli` 降到 6.x（需评估）**：现在 CLI 7.4.3 配 android/core 6.2.1 **错配**，靠 `android\fix-java-version.mjs` 每次同步后打补丁。优先级已下降——A 机实测构建一次通过、没踩坑。
5. **仓库结构收拢（需用户拍板）**：一个仓库里并存三份代码——根目录（服务器版残留）、`版本开发\纯本地APK版\`（主线）、`版本归档\服务器版-v1.0\`（归档）。根 README 已加导航，**没搬家**。
6. **回归小红书**：本次只碰了抖音。小红书链路此前探针确认正常（图集 7 图 7 实况、视频 masterUrl 720x1280），**改版后的端到端回归仍未跑**（图集/视频/实况图三类）。
7. **他机型 WebView 差异**：只在用户那一台机器验证过；系统 WebView 版本过低/厂商魔改可能行为不同——WebView 方案的固有风险。
8. **发布 v2.3.7（可选）**：真机确认后再发；**用新 tag + 新 Release，不要动 v2.3.2**；附件用纯 ASCII 名。
9. **补历史版本的 Release（可选）**：v1.0/v2.0/v2.1/v2.2 的 APK 只在本地；同样 ASCII 名。
10. **`_ROUTER_DATA` / 详情接口漂移的应对**：抖音改版即失效。改 `TAP_JS`/`EARLY_JS` 前**必跑 `verify-tap-js.mjs`**；重新定位用 `webview-cdp-probe22–26.mjs`（本机无 Chrome，脚本默认走 Edge）。
11. **探针脚本去机器化**：`tools\` 下的探针写死了浏览器路径（Edge）与本机路径，换机器要改。
12. **迁名工具包纳入版本管理**：仍只在 `G:\ai\_qingqu-migrate\`（非 git 仓库，约 60KB）。
13. **仓库描述与 Topics**：LICENSE 已补，描述与 Topics 还没设。

## 已知坑

### 抖音取数（2026-10-01 大更新，影响最大）

- **⚠️ 页面上的视频不等于作品的视频（v2.3.3–v2.3.7 一路踩）**。三处都会骗人：
  1. **页头吉祥物加载片** `lf-douyin-pc-web.douyinstatic.com/.../uuu_265.mp4`（2.6s / 1080x1920 / HEVC，白兔抱红包）——比主播放器 `<source>` **早约 0.17~0.8 秒**挂载，被"第一条非空即可"抓到就是用户看到的"2 秒广告"。
  2. **相关推荐卡片的 `<video>`**——`/note/{id}` 页在 **+1.89s** 就挂上，地址在 **`*.douyinvod.com`（真实视频 CDN，域名白名单拦不住）**，容器只是普通 `div`。
  3. **接口的伴生视频**——note 页 **+2.99s** 就送来约 3 秒的 `aweme_detail.video`，而 **14 张图要等到 +3.9s**。
  → **现判据**：只认**主播放器容器**（`xg-video-container` / `basePlayerContainer`）里的 `<video>` + 视频源白名单 + **note 路由必须等到图片才算拿到数据**（`__QQ_EXPECT_IMAGES__`）。
- **⚠️ id 校验防不住"页面自己的片子"**：`Bridge.ready`/`poll` 会核对 `aweme_id`，但 `meta.aweme_id` 来自**页面标题**（是对的），所以身份校验只能防"别人的作品"，防不住"作品页上的装饰/推荐视频"。判"是不是作品本体"必须靠**容器 + 域名 + 等到正片数据**。
- **⚠️ 探测媒体地址时，206 的 `Content-Length` 不是文件大小**（v2.3.6 的教训，静默失效）：跟随 302 后返回 `206 / Content-Type: video/mp4 / Content-Length: 2 / Content-Range: bytes 0-1/4103700`。**要读 `Content-Range` 的总长度**，或直接放行 206。当时写成 `len > 1000` 才通过 → 永远 false → "换干净地址"被静默跳过，用户反馈"修了还是一样"。**凡是"探测→据此决策"的代码，都要先用真实响应复算一遍再打包。**
- **移动页（`PLANS[1]`，移动 UA）的能力边界**：作品节点**只有 `play_addr` 一个地址**，且是 `/aweme/v1/playwm/` **水印端点**（+1640ms 就到，比桌面路径还快）；`images[]` **一张都不带伴生视频**（字段只有 `uri/url_list/download_url_list/height,width`）。→ **桌面页不通 = 视频变水印 + 动态照片丢失，一个根因两个症状。**
- **⚠️ 更正旧条目：「`/playwm/` → `/play/` 的替换是陷阱」只在特定形态成立**。旧笔记记「`/play/` 返回 200 但 0 字节」——那说的是 **`video_id` 指向一个 URL** 的形态（图文/动图伴生视频常见）。**纯 id 形态实测可用**：同一 video_id 换 `/play/` 后 4,103,700 字节 / 720x1280 / **43.766667s**，抽帧肉眼**无水印**（水印版是 5,751,318 字节 / **46.751950s**）。现实现只在**纯 id 形态**改写，并在替换前用 `urlServesMedia()` 实测。
- **⚠️ 更正旧条目：「抖音动态照片伴生视频已被平台下线」已不成立**。2026-10-01 实测：**桌面页**的 `_ROUTER_DATA` 图片**带 `video` 节点**（回传载荷里 `liveVideo` 出现 18 次）；**移动页** 0 张。v2.3.2 时期该字段确实缺失过，平台已恢复。
- **在移动页上下文里直调详情接口 = 403 `blocked`**（fetch 与 XHR 都试过）。匿名接口的 Argus 拦截依然成立，拿不到 `aweme_detail`——**这条路封死，别再试**。
- **"取 cookie 再 Java 侧重放接口"这条路不通**：即使 WebView 里拿到 `UIFID` cookie，Java 侧重放依然 403（还缺页面生成的请求签名）。只能用页面自己发出的请求。
- **⚠️ 钩子必须装在「文档开始之前」**：`onPageStarted` 里 `evaluateJavascript` 看着够早，但那一刻新文档未必已提交，脚本可能落到旧文档而丢失。现用 `androidx.webkit` 的 `WebViewCompat.addDocumentStartJavaScript()`（与 CDP `Page.addScriptToEvaluateOnNewDocument` 等价），带 `WebViewFeature.DOCUMENT_START_SCRIPT` 特性检测，旧内核自动退回原方案。
- **⚠️ 最关键的一条：axios 用 `onreadystatechange` + `responseText` 读响应，只监听 `'load'` 事件抓不到。** v2.3.1 真机失败就栽在这。正确做法是覆盖 `XMLHttpRequest.prototype.responseText` 访问器（`EARLY_JS` 与 `TAP_JS` 各一层）。**通用教训，不只对抖音。**
- **详情接口的数据在页面里，只是要抢在 axios 之前**：桌面页**确实会调用**详情接口且**成功**（`status_code=0`，76KB，`aweme_detail.video.play_addr` 是 `douyinvod.com` 干净直链、还有 13 组 `bit_rate`）。不要因为探针没抓到就断定"页面不调接口"。
- **桌面页的每个候选地址都无水印**（2026-10-01 逐个下载+抽帧核验）：接口 `play_addr`（1080x1920/43.77s）、DOM 两个 `*.douyinvod.com`（576x1024）、DOM `/aweme/v1/play/?biz_sign=`（576x1024）。**唯一带水印的就是移动页 `/playwm/`。**
- **匿名 HTTP 打抖音详情接口已彻底不可用**：`403 Blocked by ArgusSecurityPlugin Uifid Not Found`；16 种 UA/Referer 组合全灭；老 `iteminfo` 接口 200 但 0 字节。**不要再花时间试 UA 和 Referer。**
- **WebView 不能用 1×1 极简尺寸**：抖音播放器懒加载，1×1 视口实测不触发 `<source>` 挂载。要用**全屏 + alpha=0 + 触摸穿透**（本项目做法）。
- **图集/动图是 `_ROUTER_DATA` 直出，不是 XHR**：位置 `window._ROUTER_DATA.loaderData['note_(id)/page'].videoInfoRes.item_list[0]`。钩 XHR 抓不到它。
- **图文/动图作品不会触发详情接口**：`douyin.com/note/{id}` 只调 SEO related；`/video/{id}` 打开图文作品会 302 到别处。
- **`iesdouyin/share/slides/{id}` 已 302 → `douyin.com/note/{id}` → 404**：动图短链要走 `douyin.com/note/{同 id}`。
- **详情接口的宽高在 `it.video.width/height` 上，不在 `it` 上**；不继承会让结果页显示 `0P`。
- **图片只有 q75/q80 的 webp**，不是无损原图；URL 带 `x-expires` 签名会过期。扩展名要按真实格式给（webp），否则会把 webp 字节存成 `.jpg`——v2.2 就有这个缺陷。
- **尺寸/时长只能从「真正选中的那个元素」读**：读 `document.querySelector('video')` 拿到的是页头吉祥物片（1080x1920 / 2.6s），会把错误元数据挂到作品上。
- **UI 曾把水印警告藏起来**：`src/App.tsx` 的来源状态提示原写成 `data.platform==='xiaohongshu' && …` → **抖音的 `watermark-fallback` 警告算出来了却从不渲染**，水印是静默交付的。已改为全平台渲染。**凡是"只给某个平台加条件"的渲染，都要确认另一个平台是否需要。**
- **小红书链路未受影响**：2026-09-28 复测正常。不要因为抖音挂了去动小红书代码。

### 验证方法论（两条最贵的教训）

- **不要用手写的理想数据验证抓取逻辑**。v2.3/v2.3.1 的验证器喂的是我自己编的 DOM payload，只证明了逻辑自洽，真机一跑就废。正确做法：真实响应存成 payload → **复刻页面真实的读取方式**（如 axios 的 `readystatechange`+`responseText`）→ 只留待测那一条通路。
- **"探测→据此决策"的代码必须先拿真实响应复算**（2026-10-01 补）：v2.3.6 的 206/Content-Length 误判就是没复算的结果，代价是用户多装一次、多等一轮。
- **"探针没抓到" ≠ "页面没有"**：v2.3.1 的探针没抓到详情响应，据此判断"桌面页不调接口"是错的——页面其实调了，只是当时被 403 拦、改从 SSR 初始数据取。
- **能在本地复现的差异一定要复现**：设备的触摸环境（`maxTouchPoints>0`）、禁止自动播放（`mediaPlaybackRequiresUserGesture` 默认 true）都试过了，**都不是**桌面页失败的原因——**排除也要有实测记录**，否则下一台机器还会重猜。
- **探针产物不要入库**：含真实 CDN 签名参数（`biz_sign`/`uifid`/`sign`），`sanitize-for-repo.mjs` 的规则覆盖不到。已在 `.gitignore` 排除 `tools/probe2*-*.json`。

### 构建与环境

- **⚠️ 构建（换机器/克隆必踩）**
  - **`cap copy` 不能用于准备 Android 工程**：它只拷 Web 资源，**不生成 `android\capacitor-cordova-android-plugins\`**（该目录被 gitignore 排除却是 `app\build.gradle` 的依赖）→ 全新克隆报 `Could not read script '...cordova.variables.gradle'`。**必须用 `cap sync`**。
  - **CLI 7.x 会把 Java 版本生成为 21，而本项目必须 JDK 17**（`@capacitor/cli` 7.4.3 与 android/core 6.2.1 错配）。`cap sync` 生成的两个 gradle 都写死 `VERSION_21` 且都不可入库，故有 `android\fix-java-version.mjs` 挂进 `android:sync` 自动改成 17。
  - **`.gitattributes` 的 `*.cmd text eol=crlf` 已验证有效**（2026-10-01）：A 机全新 clone 实测 `build-apk.cmd` **CRLF=108、孤立 LF=0**（本机 `core.autocrlf=true` 本会转 LF，被属性压住）。**仓库里再加批处理时注意。**
  - **批处理里不要用 `%~dp0文件名` 拼路径**：路径含中文与空格时会被引号解析搞坏。先 `cd /d "%~dp0"`，之后用相对路径。
  - **Gradle wrapper 缓存结构是 `dists\gradle-<ver>-bin\<hash>\gradle-<ver>\bin\gradle.bat`**（中间两层），hash 目录名**每台机器不同**，不能写死。
  - **`gradle-wrapper.properties` 指向的版本必须本机有缓存**：原指向 8.14.3（无缓存）→ 已改为 8.9 与缓存对齐。
- **git 推送需要绕过两个开关**：`git -c http.proxy= -c https.proxy= -c http.schannelCheckRevoke=false push`。①全局 `http.proxy` 配的 `127.0.0.1:7897`（Clash Verge / verge-mihomo）**握手直接失败**（TLS unexpected eof；curl 走它 0.7 秒报 000）②直连能通但卡 `CRYPT_E_NO_REVOCATION_CHECK`。
  - **2026-10-01 A 机补充**：直连 `github.com` **断续**——`ls-remote` 时好时坏，`git clone` 第 1 次 `Connection reset`、**第 2 次成功**（脚本化重试很有效）。**`gh api` 走直连稳定**（api.github.com 0.7s），可作后备通道。
- **Gradle wrapper 联网下载会被证书链问题挡住**（`PKIX path building failed`）：构建脚本因此优先复用已有缓存。
- **中文路径会触发 AGP 报错**：靠 `android\gradle.properties` 的 `android.overridePathCheck=true` 放过。
- **Gradle 用户目录权限**：默认 `C:\Users\<用户>\.gradle` 可能不可写，本项目用项目内 `.gradle-home`/`.android-home`（已 gitignore）。`build-apk.cmd` 优先复用**用户级** `~\.gradle` 里的 gradle-8.9，A 机实测命中。
- **JDK 与 Capacitor 大版本强绑定**：Capacitor 7.x 要 JDK 21，本机只有 17 → 回退 6.2.1。**不要随手升 Capacitor。**
- **AndroidX 版本会反向卡 compileSdk/AGP**：activity 1.11.0 / core 1.17.0 要求 compileSdk 36 + AGP ≥8.9.1；已回退到 activity 1.10.1 / core 1.16.0 配 compileSdk 35 + AGP 8.7.3。`androidx.webkit` 已由 `capacitor-android` 传递依赖（本项目也显式声明了一行）。
- **沙箱内 Vite 的 spawn EPERM**：构建脚本统一加 `--configLoader native`。
- **npm 写用户级缓存被拒（EPERM）**：统一 `npm install --ignore-scripts --cache .npm-cache`。
- **`android:sync` 与 README 已对齐**：脚本现在是 `npm run build:web && cap sync android && node android/fix-java-version.mjs`；旧笔记里"脚本用 `cap copy`、README 用 `cap sync`"的不一致**已消除**。
- **`capacitor.config.ts` 的解析报错**（CLI 7.4.3 + Node 24）此前靠临时改名绕过；2026-10-01 A 机实测 `cap sync` **直接通过、未复现**，该绕法暂不需要。

### 2026-09-27 迁名相关（仍有效）

- **改 DSH 项目名必须「四处同改」**：①项目文件夹 ②`.dsh\sessions` 下的项目编码目录 ③**每个会话文件头部里的 `cwd`** ④`workspace.json`。缺第③处 → 应用启动抛 `corrupt session log` → 工作区服务起不来 → 界面项目/会话全空（**数据没丢，是服务没起来**）。已固化成安全版脚本并配 40 项断言自测。
- **会话仓的任何改动都必须在 DSH 完全退出时做**：应用运行时持有登记表与目录监听；曾因运行中移走两个已登记会话目录导致内核退出。
- **判断"能不能改名"只有一种可靠办法**：真改一次名再改回来。逐文件共享冲突探测既慢又会**漏掉被 mmap 映射的文件**。
- **空壳会话容易被误判成"打不开/丢内容"**：判定法 = 解出全部事件后看有没有 `user/message`/`assistant/message`，并检查事件 `seq` 是否连续。
- **迁名内核依赖 Node ≥ 22.15**（需要 `zlib.zstdCompressSync/zstdDecompressSync`）。
- **会话日志是"多帧拼接"的 zstd 容器**：绝不能"整体解压→改→整体重压"；只能逐帧扫描、**只重建第 1 帧**。
- **DSH 会话按「项目路径」编码存放**：`~\.dsh\sessions\<编码路径>\<会话 id>\session.jsonl.zstd`；编码规则已固化在 `_qingqu-migrate\lib\session-tool.mjs`，**不要手算**。
- **执行迁名时注意沙箱**：脚本要写 `~\.dsh\...` 与 `G:\ai\agent-brain`，都在 DSH 项目工作区之外。
- **迁名会让正在使用旧路径的会话当场失效**：中途失败**直接再跑一次即可**（v2 幂等）。

### 其他仍然有效的旧坑

- **小红书水印问题已定性、未解决**：公开页面只给 `H5_DTL`（大图）+ `H5_PRV`（缩略图），没有第二套无水印原图；视频 `masterUrl` 与 `backupUrls` 是同一文件的两个 CDN。用户已表态"就这样吧"，**不要反复重启这个话题**；除非用户再提，否则不做裁剪/AI 擦除。
- **`data\` 目录含敏感物**（`test-cookies.txt`、抓取页面与 state JSON、`qingqu.db`）：**绝不入库**；`audit-output` 里的样本图/视频也不宜再分发。
- **两份工作区副本**：D 盘与 G 盘各有一份同内容项目，**写入不互相同步**。**2026-10-01 更正**：`D:\AI(CODEX)` 在 **A 机不存在**，该条目对 A 机为空（原为 B 机情况）。
- **v2.2 的"图文/动图另有 ld+json SEO 兜底"从未实现**：爬虫 UA 的 SEO 页只有标题/作者/时长/封面，没有媒体直链。
- **⚠️ 已失效（2026-09-28）：抖音用 crawler UA 打详情接口**——现在无论用什么 UA 都 403。仅作历史记录保留。
- **没有 git 远程推送能力时不要假装成功**：要区分"仓库已建"与"代码已传"。
