# DECISIONS — ds-harness-mobile

> 决策日志：定了什么、为什么、否决过什么。
> 本页由 B机 2026-09-24 首次通读代码与文档后**从仓库既有事实整理**（不是新增决策）；
> 每条都标了证据出处，未标「推断」的都是文档/代码/提交里写明的。

## 2026-08-17 · 移动端适配：注入响应式 CSS，而不是改 DSH 前端

- **定了**：不动电脑上的 DSH，只在 App 的 WebView 里注入 `assets/mobile-adapt.css`（幂等、按 id 去重）。
- **为什么**：DSH 前端不归本项目管，改上游会被升级冲掉。
- **附带硬规则**（`mobile-adapt.css` 文件头成文）：只用**稳定选择器**——`data-*` 属性、语义标签、
  ARIA role、DSH 自己的 CSS 变量；**绝不写带哈希的类名**（如 `.wSkVaW_*`），DSH 每次重打包都会重新生成。
- 证据：`README.md` 第八节、`b2ccb05`。

## 2026-09-10 · v2 独立成目录，原工程一行不动

- **定了**：0.2.x 的源码放 `v2/`，根目录的 0.1.1 工程与 APK 保持原样。
- **为什么**：留一条随时可回退的路。
- 证据：`v2/README.md` 开篇、`cb1e2f7`。

## 2026-09-10 · 同包名 + 同一把 keystore（覆盖安装，不做第二个 App）

- **定了**：`applicationId` 仍为 `com.dsh.mobile`，继续用根目录那把 `release.keystore`。
- **为什么**：手机上是"更新"而不是并列两个 App；用户数据与会话不丢。
- 证据：`v2/README.md` 版本行、`v2/app/build.gradle`。

## 2026-09-10 · SSL：从「无条件放行」收紧为「严格校验 + 逐主机人工确认并记住」

- **定了**：默认严格；遇到自签/异常证书弹窗显示主机名，确认后按主机记住。
- **为什么**：0.1.0 对**任何**证书错误直接 `proceed()`，而地址可能是公网域名 → 等于对中间人敞开。
- 代价/后果：走遗留 Caddy 自签门卫时首次连接**必然**弹一次（该证书 SAN 只有 `dsh-mobile`，
  与实际主机名不匹配），点「仍然继续并记住」即可。
- 证据：`v2/README.md` §2.0 第 1 条、`MainActivity.java` `handleSslError()`；被否决的做法在 `app/.../MainActivity.java:99`。

## 2026-09-10 · 关闭明文流量

- **定了**：manifest `usesCleartextTraffic="false"`，只支持 HTTPS。
- **为什么**：两条受支持路径（插件公网隧道 / Caddy 门卫）本来就都是 HTTPS。
- 代价/后果：`http://<tailscale主机>:3080` 这类 0.1.x 老地址在 0.2.x 用不了；要明文只能装回 0.1.0 的 APK。
- 证据：`v2/README.md` §2.0 第 2 条、`v2/.../AndroidManifest.xml`。
  > ⚠️ 已被 2026-09-25「允许明文 HTTP（推翻 2026-09-10 的"关闭明文流量"）」取代（此处仅存历史）。

## 2026-09-10 · 内置移动样式改为默认关闭

- **定了**：`mobile-adapt.css` 默认不注入，菜单「注入内置移动样式」可随时打开兜底。
- **为什么**：DSH 侧插件已自带竖屏触控适配层，重复注入只会互相覆盖。
- 证据：`v2/README.md` §2.0 第 3 条、`MainActivity.java` `isInjectCssEnabled()`。
  > 注（2026-09-25）：**结论仍有效**（这份样式仍默认关闭），但理由已变——不再是"插件已自带适配层"，
  > 而是"官方新版布局在窄屏下输入区本来就正常，硬套这份为旧版写的规则可能反而弄坏它"。见同日决策。

## 2026-09-10 · 扫码走「App 内 zxing」，不走系统相机的 https 深链

- **定了**：集成 `com.journeyapps:zxing-android-embedded`，由 App 自己扫码；深链只作辅助保留。
- **为什么**：0.2.0 曾注册 https 深链让系统相机把链接交给 App，但 **Android 12+ 对未做
  App Links 验证的域名（`dsh-market.com` 不归我们）不再弹「打开方式」选择器**，这条路不可靠。
- **附带决定**：不用 `IntentIntegrator`（其签名带 `androidx.fragment`），改用不含 AndroidX 的
  `ScanOptions.createScanIntent()` + `ScanIntentResult.parseActivityResult()` 直接驱动；
  全项目只为 `CaptureManager` 引入 `androidx.core`，不引 AppCompat、不改主题。
- 代价：APK 从 26 KB 涨到约 1.4 MB（为稳妥没开 R8）。
- 证据：`v2/README.md` §2.1/§2.0 第 6 条、`v2/app/build.gradle` 依赖注释。
  > ⚠️ 2026-09-10 起，0.2.0 的「系统相机扫 https 深链」作为主流程**已被 0.2.1 取代**（深链仅保留为辅助）。

## 2026-09-10 · `launchMode` 从 `singleTask` 改回 `singleTop`

- **定了**：manifest 用 `singleTop`。
- **为什么**：`singleTask` 会让 `startActivityForResult` 的结果回调失效，而**扫码和附件选择都依赖它**
  （属于静默故障：不崩，只是"扫完没反应"）。
- 证据：`v2/.../AndroidManifest.xml` 注释、`v2/README.md` §2.1 末段。
  > ⚠️ 0.2.0 的 `singleTask` 已被本条取代。

## 2026-09-10 · release 签名做存在性判断

- **定了**：`v2/app/build.gradle` 先判断 `release.keystore` 是否存在；不存在也照常构建，只是产物未签名。
- **为什么**：keystore 不入库，换台电脑直接构建会因缺文件失败；日常改代码用 `assembleDebug` 就够。
- 代价/后果：**产物未签名时构建是"绿"的**，装到手机上才会因签名不符失败 → 易误判成 App 的 bug。
- 证据：`v2/app/build.gradle`、`v2/README.md` §7。

## 2026-09-25 · 彻底不用第三方插件：官方令牌配对 + 自写中继

- **决定**：手机访问不再依赖 `@linxin666/dsh-remote-web-ui`。架构 = 回环 harness 原样不动
  ＋ 自写约 70 行 Node 中继（改写 `Host`/`Origin` 穿过 `/api` 围栏）＋ 官方启动令牌做成二维码。
- **理由**：插件引以为卖点的"配对"，官方本来就有——`dsh web` 启动即打印带令牌的地址
  （`printUrl` 默认 true），访问它得到 30 天的签名 cookie，之后 `/api` 凭 cookie 放行；
  缺的只有"把回环变成手机够得着的地址"这一层。而插件**跑在 DSH 进程里、权限等同 DSH 本身**，
  且由一个人追着快速迭代的平台跑：实测桌面版日志里 `dshmarket` 与 `@nanmicoder/dsh-auto-mode`
  在 0.1.7-rc.2 下**加载失败**（导出的接口名对不上）——这就是风险从推断变成事实。
- **否决**：① 用 `--patch` 把 bind 改成 `0.0.0.0`（会暴露给整个局域网，且属于绕过厂商安全闸）；
  ② 装插件并锁旧版 `0.3.24`（治标，作者一停更就卡住）。
- 证据：`tools/dsh-mobile-relay.mjs`、`tools/dsh-mobile-pair.mjs`；本机端到端实测
  （无 cookie→401、带令牌→303+Set-Cookie、带 cookie→200；外部 Origin 直连→403、经中继→通过）。

## 2026-09-25 · 允许明文 HTTP（推翻 2026-09-10 的「关闭明文流量」）

- **决定**：manifest 改回 `usesCleartextTraffic="true"` ＋ `res/xml/network_security_config.xml`
  放行明文；主路径改成 Tailscale 内网。
- **理由**：传输安全由 Tailscale（WireGuard）承担，于是**自签证书那一套彻底不需要**
  （连带消除了"证书不受信任"弹窗）；而电脑地址是运行时输入、形态不一（尾网域名/尾网 IP/局域网 IP），
  编译期无法用 `<domain>` 精确枚举，只能整体放行。
- **边界**：HTTPS 路径的证书校验**没有放宽**（`handleSslError` 仍默认严格、自签需人工确认一次）。
- 证据：`v2/app/src/main/AndroidManifest.xml`、`v2/app/src/main/res/xml/network_security_config.xml`。

## 2026-09-25 · 手机体验：改官方布局的外壳层，不另做一套界面

- **决定**：新增 `mobile-shell.css` + `mobile-shell.js`（App 每次注入）。窄屏把侧栏做成**覆盖式抽屉**，
  并补可拖动悬浮入口、左缘右滑唤出、点遮罩收起；**不动 DSH 前端**。
- **为什么**：实测官方在 390px 下把侧栏写成硬 280px 栅格列，主区只剩 110px（标题被压成竖排）；
  而输入区官方已经处理好了——所以只治这一处，不整体重做。
- **两条实现约束**（踩坑得来）：① 开合状态**跟着官方 `data-sidebar-collapsed` 走**，开合一律
  "点官方那个按钮"，不自造状态；② 侧栏一旦 `position: fixed`，其余栅格列会**自动前移**，
  必须把三列显式钉在 `grid-column: 1/2/3`，只改 `grid-template-columns` 会导致主区宽 0。
- **否决**：把内置 `mobile-adapt.css` 默认打开（量过：官方 0.1.7 窄屏下输入区已正常，
  硬套旧规则可能弄坏；该文件保持可选）。
- 证据：`v2/app/src/main/assets/mobile-shell.{css,js}`、`MainActivity.java` 的 `injectMobileShell()`。

## 2026-09-25 · 交付 0.3.0 签名包

- **决定**：`versionCode 4` / `versionName 0.3.0`，产物 `v2/DS-Harness-Mobile-0.3.0.apk`。
- **为什么**：0.2.1 从未构建也从未发版（手机上还是 0.1.1），而外壳层与明文放行都得有新包才能上机。
- **边界**：与手机上 0.1.1 **同一把签名** → 可直接覆盖升级；同包名不产生第二个 App。
- 证据：`v2/app/build.gradle`；apksigner 实测两包证书 SHA-256 一致。

## 待定（尚未成为决策）

- 要不要把 `v2/` 提升成仓库根（现在两代并存，根 `README.md` 里没有 v2 的入口）。
  「推断」：这是文档导航问题，不是架构问题；先补一段指向 `v2/README.md` 的说明成本最低。
- 构建口令硬编码在 `v2/app/build.gradle` 里（仓库私有）。是否移到 `local.properties`/环境变量，
  尚未有人拍板。
