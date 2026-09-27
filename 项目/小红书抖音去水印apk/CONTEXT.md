# CONTEXT — qingqu-media-saver（轻取 / QingQu）

> 新会话 / 另一台机器开工前必读。项目定位或阶段大变时更新本文件。
> 建档：2026-09-27 B机
> 曾用名：小红书抖音去水印apk（2026-09-27 方案 B 迁名为 qingqu-media-saver，使「DSH 文件夹名 = 代码仓库名 = 本笔记文件夹名」三者同名）

## 项目是什么

面向 Android 的**小红书 / 抖音公开作品媒体保存工具**，产品名「轻取」。粘贴公开作品的分享链接，解析出原图 / 原视频 / 动态照片，直接存进手机系统相册。

项目内**并存两套架构**：

| 架构 | 位置 | 状态 |
| --- | --- | --- |
| **纯本地 Android 版** | DSH 项目文件夹内的 `版本开发\纯本地APK版\` | **当前主线**，v2.2。解析/下载/历史全在手机本地，不需要服务器 |
| 服务器版（React + Express + SQLite + yt-dlp） | `版本归档\服务器版-v1.0\`（DSH 文件夹根目录也仍是一份服务器版代码） | 归档，v1.0。理解解析思路的参考实现，不继续开发 |

- 代码仓库（**私有**）：https://github.com/ljr282341583/qingqu-media-saver
- 包名 `com.qingqu.mediasaver`；版本 v2.2（versionCode 3）；minSdk 24 / compile+target 35
- **当前主证路径（本机）**：`G:\ai\deepseek harness output\workspace\projects\qingqu-media-saver`（迁名前为 `…\projects\小红书抖音去水印apk`）
- 另存在一份同内容副本：`D:\AI(CODEX)\ds harness output\AI工作空间\projects\小红书抖音去水印apk`（两者哈希曾一致，但**写入不互相同步**，改前先确认在改哪一份；该副本的迁名未处理）

> 三方同名（成文约定）：DSH 文件夹名 = 代码仓库名 = 本笔记文件夹名 = `qingqu-media-saver`。
> 迁名脚本与备份在 `G:\ai\_qingqu-migrate\`：`migrate-project-name.ps1` / `rollback-project-name.ps1`。
> **若你看到的 DSH 文件夹仍是 `小红书抖音去水印apk`，说明迁移脚本尚未执行**——先执行（见 NEXT 第 1 条）再继续。

## 怎么跑

### 纯本地版（主线）

```powershell
cd <项目>\版本开发\纯本地APK版
npm install --ignore-scripts --cache .npm-cache
npm run build:web                 # tsc -b && vite build --configLoader native
npx cap copy android              # 见 NEXT「已知坑」：若报 .ts 解析错误需先临时移开 capacitor.config.ts
android\build-apk.cmd             # 内部用缓存 Gradle 8.9 + 项目内 GRADLE_USER_HOME
```

产物：`android\app\build\outputs\apk\debug\app-debug.apk`（构建后另存为 `轻取-vX.Y-纯本地-debug.apk`）。

### 服务器版（归档，仅在需要复现解析思路时跑）

```powershell
cd <项目>\版本归档\服务器版-v1.0
npm install
npm run dev        # Web :5173 + API :8787（vite 代理 /api → 8787）
npm run build ; npm start   # 由 Express 单端口同时提供 API 与 dist
```

关键环境变量见 `.env.example`：`PORT` / `DB_PATH` / `YTDLP_PATH` / `REQUIRE_YTDLP`。

## 关键文档

- 仓库 `README.md` — **权威**：功能、快速上手、支持的链接类型、构建步骤、常见构建问题、水印说明、版本历史。
- `版本开发\纯本地APK版\版本说明.md` — 纯本地版功能与验证记录。
- `版本开发\纯本地APK版\audit-output\xhs\审计结论.md` — 小红书候选资源审计结论（水印问题的证据基础）。
- `版本归档\服务器版-v1.0\版本说明.md` — 服务器版归档说明。
- `版本开发\纯本地APK版\tools\` — 4 个验证脚本（解析冒烟、候选审计、样本下载、排序测试），依赖 `..\..\data\qingqu.db`；未入库。

## 技术要点（改动前必知）

- **纯本地版没有后端**：前端 `src/api.ts` 通过 `registerPlugin('MediaParser')` 调 Android 原生插件；插件全在 `android\app\src\main\java\com\qingqu\mediasaver\MediaParserPlugin.java`（Java，非 Kotlin），暴露 `parse / save / readClipboard / getHistory / clearHistory / deleteHistory` 与 `downloadProgress` 事件。
- **解析路径**：抖音走公开详情接口（需 crawler UA）+ 图文 SEO ld+json 兜底；小红书走公开 H5 页面的 `window.__INITIAL_STATE__` → `noteData.data.noteData`。短链手动跟随 3xx（≤6 跳），保留 `did/iid/u_code/mid/from_aid/ts` 分享参数。
- **候选排序（v2.2 引入）**：图片按 `origin/WB_DFT/RAW > H5_DTL > urlDefault > urlPre`，含 `wm/watermark/crd_wm` 的降权到最后；视频在 h264/h265/av1/h266 中按分辨率→码率→体积择优，同样避开显式水印标记。结果页按 `sourceQuality` 显示来源状态。
- **动态照片**：图片与配套 MP4 靠 `sourceIndex` 配对，前端按勾选的照片索引筛 `livePhotos`。
- **保存**：Android 10+ 走 MediaStore（`IS_PENDING` 转正，失败删半成品），落到相册「轻取」目录；Android 7–9 落到应用外部专属目录（不申请整盘权限）。
- **历史记录**：本机 SharedPreferences 存最近 50 条 JSON，非 SQLite；服务器版才用 SQLite。
- **工具链锁定**：Capacitor core/android **6.2.1**（7.x 要求 JDK 21，本机只有 JDK 17）；AGP 8.7.3 + Gradle 8.9；androidx 已回退到 activity 1.10.1 / core 1.16.0 以适配 JDK 17。
- 构建脚本 `android\build-apk.cmd` **硬编码了本机路径**（Administrator 用户目录下的 Android SDK 与 Gradle 8.9 缓存），换机器/换用户必须改。

## 约定

- 文档与界面中文。
- 只处理**平台公开返回**的内容；不绕过登录、验证码、私密设置、访问控制或 DRM。水印能否去除取决于平台是否提供干净资源，不做像素级擦除（会让输出不再是原图/原视频）。
- 红线继承大脑仓库总约定：密钥/token/密码/**内网地址**不进笔记；项目 `data\` 里有 `test-cookies.txt` 与抓取页面，**永不入库**。
- 版本发布后同步更新仓库 README 的版本历史与新 APK 文件名。
