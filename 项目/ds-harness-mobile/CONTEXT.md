# CONTEXT — ds-harness-mobile（DS Harness 手机版）

> 新会话 / 另一台机器开工前必读。项目定位或阶段大变时更新本文件。
> 本笔记的写法：标「约定」= 仓库里**成文**的硬约束；标「推断」= agent 的判断，未经用户确认。

## 项目是什么

安卓 App（`com.dsh.mobile`，纯 Java + Android framework API 的 WebView 壳），把 DSH 的
Web GUI 装进手机。**手机只是"遥控屏幕"，真正跑命令、改文件的是电脑上的 DSH。**
全部逻辑集中在一个文件：`MainActivity.java`（0.2.1 版 686 行）。

仓库里同时躺着**两代**，这是理解本项目的关键（不是历史垃圾，两条路都能用）：

| 位置 | 版本 | 形态 | 电脑端怎么被连上 |
| --- | --- | --- | --- |
| 仓库根 `app/` | **0.1.1** | 手填地址的 WebView 壳 + 内置自适应 CSS | 自己搭 Tailscale + Caddy 自签 HTTPS「门卫」 |
| `v2/` | **0.2.1** | 内置扫码配对 + SSL/明文安全收紧 | 装第三方插件出二维码与公网隧道（**也可不用插件**，见下） |

- 「约定」v2 是**当前主线**：它是 0.1.0 的更新版，**源码独立成目录、原工程与原 APK 一行未动**，
  随时可回退（`v2/README.md` 开篇明说）。
- v2 为什么存在：DSH 侧的第三方插件 `@linxin666/dsh-remote-web-ui`（含在全家桶
  `@linxin666/dsh-web-all` 里）已经把 0.1.0 手搓的活干了（Cloudflare 隧道、固定域名中继、
  竖屏触控适配层、二维码准入），所以 v2 改做**「扫码 → 配对 → 进 GUI」整条链路**，
  顺手收掉 v1 的安全隐患。
- 「约定」**二维码是那个插件产生的，不是 DSH 自带**——官方 `dsh web` 只有
  `--host` / `--port` / `--no-open` / `--trusted-host`，没有配对、没有二维码、没有隧道。

## 怎么跑

### A. 用户侧：手机连电脑（两条路，任选）

**路 1 —— 有插件（0.2.1 主路径，扫码）**
1. 电脑装插件：`dsh plugin --profile web add @linxin666/dsh-web-all`（或只装 `@linxin666/dsh-remote-web-ui`），重启 `dsh web`。
2. **在电脑本机**打开 `http://127.0.0.1:3080`，点侧栏底部设置按钮旁的**手机图标（远程访问）**，
   面板里铸出大二维码（面板只认回环，用局域网地址打开会显示「仅限本机使用」）。
3. 手机 App 首启点「扫码配对」（之后在右上角菜单 ⋮），对准二维码 → 自动配对进 GUI。
4. 之后直接进 GUI（App 把配对链接的**源**记成默认地址；该域名不变，重启不用重扫）。

**路 2 —— 没插件（0.2.1 照样可用，手填地址 + 自带兜底样式）**
- 推荐 **Caddy 门卫**：`Caddyfile` + `make-certs.ps1`（不依赖 openssl，用 .NET 现造
  `cert.pem`/`key.pem`）+ Caddy 反代 `127.0.0.1:3080` 并把 `Host`/`Origin` 改写成回环
  （这是穿过 harness `/api` 围栏的关键）。App 菜单「更改服务器地址」填
  `https://<电脑主机名>:8443`，首次弹一次证书确认点「仍然继续并记住」，
  **并且要手动打开菜单「注入内置移动样式」**（没有插件就没有插件的适配层）。
- 备选：`cloudflared tunnel --url http://127.0.0.1:3080` + `dsh web --trusted-host <域名>`。
  **代价**：没有插件就没有准入控制，谁拿到这个地址谁就能完整操控电脑（改文件/跑命令）。
- 只走内网不行：0.2.x **禁用了明文 HTTP**，而 `dsh web` 默认是 HTTP → 必须套 HTTPS 反代。

### B. 开发侧：改代码 → 打包

- 工具链：**JDK 17**、Android SDK（`compileSdk 34` / `minSdk 24` / `targetSdk 34`）、
  AGP 8.5.2 / Gradle 8.7（wrapper 自带 jar）。
- **`v2/` 需要自己的 `local.properties`**（内容一行 `sdk.dir=<SDK路径>`，不入库）。
  本机 `ANDROID_HOME` 是空的，AGP 只认 `local.properties`——缺了直接 BUILD FAILED。
- 构建（在 `v2/` 里跑）：
  - `.\gradlew.bat assembleDebug` → `app\build\outputs\apk\debug\app-debug.apk`（debug 签名，可装）
  - `.\gradlew.bat assembleRelease` → 有 `v2/release.keystore` 时出**已签名** `app-release.apk`；
    没有时**不报错**，只出 `app-release-unsigned.apk`
- 「约定」签名：`applicationId com.dsh.mobile` + **同一把 `release.keystore`**（根目录那把），
  所以新包能直接覆盖安装、不会变成两个 App。别名与口令写在 `v2/app/build.gradle` 里
  （口令是硬编码的，别再外传；大脑仓库不记口令）。
- 「约定」不入库清单（`.gitignore`）：`*.apk`、`release.keystore`、`*.pem`、`local.properties`、
  构建目录。**换机时"丢"签名和证书是设计如此**，不是仓库损坏。

### 关键文档

- `v2/README.md` —— **0.2.1 的主文档**，也是全项目信息密度最高的一篇：为什么有 v2、
  二维码的前置条件、无插件三条退路、故障对照表、换机继续开发步骤。
- 根 `README.md` —— **0.1.1 的用户向说明书**（Caddy 门卫 + Tailscale 那套，大白话教程）。
- `v2/app/.../MainActivity.java` 类注释 —— 0.1.0 → 0.2.1 的全部差异清单（比 README 更准）。
- `v2/app/src/main/assets/mobile-adapt.css` —— 兜底自适应样式，文件头写了**选择器稳健性规则**
  （只用 `data-*` / 语义标签 / ARIA / CSS 变量，绝不写哈希类名），改样式前必读。
- 远程仓库 https://github.com/ljr282341583/ds-harness-mobile （**私有**，需登录；本机 `gh` 已登录作者账号）。
- 跨机断点**以本大脑目录为准**。

## 约定 / 硬约束（违反即回退）

1. `com.dsh.mobile` + 同一把 `release.keystore` 不许换（换了手机上是第二个 App / 盖不上）。
2. v1 工程（仓库根 `app/`）保持一行不动 = 退路；要改就在 `v2/` 改。
3. 不许假设插件存在：没装插件时 A 方案的 Caddy 门卫 + 内置样式必须是完整可用的替代。
4. 明文 HTTP 默认关（`usesCleartextTraffic="false"`）；要放开属于需要明确决策的改动。
5. 密钥/证书/APK/`local.properties` 一律不入库，也不写进大脑仓库。
6. 工作区路径含空格与括号 → `v2/gradle.properties` 里的 `android.overridePathCheck=true`
   是为此开的，别删（「推断」：AGP 默认拒绝非 ASCII 路径，本机路径实际只是含空格，但保留无副作用）。
