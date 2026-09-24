# CONTEXT — ds-harness-mobile（DS Harness 手机版）

> 新会话 / 另一台机器开工前必读。项目定位或阶段大变时更新本文件。
> 本笔记的写法：标「约定」= 仓库里**成文**的硬约束；标「推断」= agent 的判断，未经用户确认。
> 最近更新：**2026-09-25 B机**（`WIN-20251127LIT`）

## 项目是什么

安卓 App（`com.dsh.mobile`，纯 Java + Android framework API 的 WebView 壳），把 DSH 的
Web GUI 装进手机。**手机只是"遥控屏幕"，真正跑命令、改文件的是电脑上的 DSH。**

**当前主线 = `v2/` 的 0.3.0**。这个项目的定位已经变过两次，别按旧印象办事：

| 版本 | 位置 | 手机怎么连上电脑 | 状态 |
| --- | --- | --- | --- |
| 0.1.1 | 仓库根 `app/` | 自建 Tailscale + Caddy 自签 HTTPS「门卫」，App 手填地址 | 冻结，**一行不动**（约定：它是退路） |
| 0.2.1 | `v2/` | 要求装第三方插件（`@linxin666/dsh-remote-web-ui`）出二维码/隧道 | 只有源码，从未构建发版 |
| **0.3.0** | `v2/` | **零插件**：官方令牌配对 + 仓库自带中继 + Tailscale | **当前主线**（2026-09-25 构建交付） |

**为什么能从"依赖插件"变成"零插件"**：插件引以为卖点的"配对"，官方本来就有——`dsh web`
启动即打印**带一次性令牌**的地址，访问它 → 303 + 种下 **30 天**的签名 cookie，此后 `/api`
凭这个 cookie 放行。缺的只有"把回环地址变成手机够得着的地址"，而这一层由本仓库自写的约 70 行
Node 中继补上。插件的另一面风险已从推断变成事实：它跑在 DSH 进程里、权限等同 DSH 本身，
且要由一个人追着快速迭代的平台跑（实测桌面版日志里已有两个插件因接口名对不上而加载失败）。

## 怎么跑

### A. 日常使用（手机连电脑）

1. **电脑**：确认桌面版 DSH（或 `dsh web`）在跑，然后双击仓库根目录的 `启动手机访问.cmd`
   （等价于 `node tools/dsh-mobile-pair.mjs`）。它会：读桌面版日志取口令 → 在本机验证口令 →
   起中继（**只绑 Tailscale 接口**）→ 在终端画出二维码。
2. **手机**：打开 App → 菜单「扫码配对」→ 对着二维码扫。首次会有一个「内测声明」弹窗，点继续。
3. 之后 **30 天内**直接进 GUI（cookie 已存在手机里）。中继关掉手机就连不上，但配对不会失效，
   重新跑一次脚本即可。

要点：
- 电脑与手机都要装 **Tailscale** 并登录同一账号（它就是那条"只有你自己的设备能走的暗线"，
  传输由 WireGuard 加密，所以**不需要 https 证书**）。
- 中继只绑尾网地址，局域网里其它设备摸不到（实测：局域网 IP 连不上）。
- 端口被占会自动顺延（8787 → 8788 …）。
- 排查看 `%TEMP%\dsh-mobile-relay.log`：只记"有没有带 cookie、状态码、字节数"，**不记口令与 cookie 内容**。

**遗留路径（不推荐但仍在）**：Caddy 自签门卫（`Caddyfile` + `make-certs.ps1`）走 HTTPS，
证书校验仍然严格，首次连接要人工确认一次。

### B. 开发

- 工具链：**JDK 17**、Android SDK（`compileSdk 34` / `minSdk 24`）、AGP 8.5.2 / Gradle 8.7。
- **`v2/` 需要自己的 `local.properties`**（一行 `sdk.dir=…`，不入库）；本机 `ANDROID_HOME` 是空的。
- 构建（在 `v2/` 里）：`.\gradlew.bat assembleRelease`（有 keystore 才签名）或 `assembleDebug`。
- 「约定」签名：`com.dsh.mobile` + 仓库根那把 `release.keystore`（不入库，换机自带），
  否则新包盖不上手机上的旧版。
- **不用真机就能看手机界面**：`node tools/dev/phone-view.mjs` —— CDP 驱动无头 Chrome，
  手机视口 + 全新浏览器状态打开真实界面，可注入 assets 里的 CSS/JS 预览改动效果，
  并把屏幕文字 / 截图 / localStorage 抓回来。用前设 `VIEW_URL`（配对地址）与 `VIEW_OUT`（输出目录）。

### 关键文档

- `tools/` 下每个文件头部都写了"它为什么存在、怎么用"（中继、配对、预览器、二维码 vendor 说明）。
- 代码即文档：`v2/app/.../MainActivity.java` 类注释写了历代差异；
  `v2/app/src/main/assets/mobile-shell.css` 头部写明了外壳层的两条实现约束。
- `v2/README.md` —— 0.2.1 时代的用户向说明。**注意：它仍以"必须装第三方插件"为主线，
  与 0.3.0 的零插件架构不符**（待重写，见 NEXT）。
- 根 `README.md` —— 0.1.1 的 Caddy 教程，同样**没有 v2/0.3.0 的入口**。
- 远程仓库 https://github.com/ljr282341583/ds-harness-mobile （私有）。

## 约定 / 硬约束（违反即回退）

1. 「约定」`com.dsh.mobile` + **同一把 `release.keystore`** 不许换（换了手机上会变成第二个 App / 盖不上）。
2. 「约定」v1 工程（仓库根 `app/`）保持一行不动 = 退路；所有改动进 `v2/`。
3. 「约定」不依赖任何第三方 DSH 插件：二维码、令牌、cookie 全用官方机制。仓库里唯一的第三方代码是
   `tools/vendor/qrcode-generator`（MIT，只在电脑侧画二维码，**不进 DSH 进程**）。
4. 「约定」不改 DSH 前端：手机体验靠 App 注入的外壳层（`mobile-shell.*`）实现，且它必须守两条——
   **开合状态跟着官方 `data-sidebar-collapsed` 走**；**侧栏 `fixed` 后三列要显式钉 `grid-column`**。
5. 「约定」不把监听地址改成 `0.0.0.0`（官方 CLI 明确拒绝；`--patch` 能绕，但属于绕过厂商安全闸）。
6. 明文 HTTP 自 0.3.0 起放行：传输安全由 Tailscale 承担；HTTPS 路径的证书校验**没有**放宽。
7. 密钥 / 证书 / APK / `local.properties` 一律不入库，也不写进大脑仓库。
