# NEXT — ds-harness-mobile 当前断点

> 只保留"现在接着干"需要的信息。本页写于 2026-09-24，机器 = **B机**（`WIN-20251127LIT`）。

## 进行中

- 无。2026-09-24 本机只做了"拉齐 + 通读 + 验证能构建"，**没有改过任何项目代码**。

## 当前状态（2026-09-24 实测）

- **远端是最新源，本地已拉齐**：本地原停在 `8a0d0a7`（0.1.1），**落后远端 4 个提交**；
  已 `git fetch` + `git pull --ff-only` 到 `main` `870c666`，工作区干净、本地无分叉。
- 落后的 4 个提交就是 **v2 的全部来源**：
  `cb1e2f7` 0.2.1 内置扫码配对、源码独立到 `v2/` → `e8b4309` release 签名做存在性判断 +
  换机说明 → `216a2d2` 写明二维码来自第三方插件 → `870c666` A机 2026-09-14 的 `auto:` 提交
  （只扩了根 `.gitignore`，与 v2 无关）。
  ⚠️ 也就是说：**2026-09-14 之后本项目没有任何代码改动**，但 A机 的 v2 工作当时没有同步到 B机。
- **0.2.1 目前只是源码，没有任何成品包**：
  - GitHub Releases 只有 `v0.1.0` / `v0.1.1`（各挂一个 `DS-Harness-Mobile.apk`）；
    仓库里也没有任何 `.apk`（被 `.gitignore` 挡掉）。
  - 本机原有的两个 APK 实测（aapt2）都是 **0.1.1 / versionCode 2**，是 2026-08-18 的产物。
  - → 想在手机上跑 0.2.1，**必须自己构建**。
- **本机首次构建 v2 通过**（新增了 `v2/local.properties`，见下）：
  - `assembleDebug` → `v2\app\build\outputs\apk\debug\app-debug.apk`，1,794,148 B。
  - `assembleRelease` → `app-release-unsigned.apk`，1,411,557 B（**未签名**，因为是新目录还没有 keystore）；
    与 `v2/README.md` 声称的"约 1.4 MB"吻合。release 构建的 `lintVitalRelease` 也过了。
  - 本机新增的唯一非源码文件：`v2/local.properties`（一行 `sdk.dir=...`，已被 `v2/.gitignore` 忽略，
    `git status` 仍然干净）。
- **本机环境**：DSH `0.1.5-rc.1`（正是 v2 文档假设的版本）；但 `~/.dsh/profiles/web` 里
  **没有装** `@linxin666/dsh-remote-web-ui` / `dsh-web-all` → **扫码配对主路径在本机无法端到端验证**，
  要验证得先装插件（或改走 Caddy 门卫那条路）。
- 无自动化测试、无 CI（仓库里没有 `.github/`）；验证手段 = 构建 + 真机人工冒烟。

## 下一步

1. **做出能在手机上覆盖安装的 0.2.1 签名包**（当前手上只有未签名产物）：
   把**仓库根**的 `release.keystore` 拷到 `v2/`（同一把钥匙、同一别名，
   `v2/app/build.gradle` 已按存在性判断自动用它签名）→ `.\gradlew.bat assembleRelease`
   → 产物 `app-release.apk` → `adb install -r`。**keystore 不入库，换机必须自带。**
2. **真机冒烟（这项从没有人做过）**：装 0.2.1 后走一遍
   ①扫码配对 ②手填地址 ③附件选择 ④返回键。
   重点看 **0.2.0 把 `launchMode` 从 `singleTask` 改成 `singleTop`** 之后，
   `startActivityForResult` 的回调是否真的正常（扫码与附件选择都依赖它，改错了不会崩、
   只会"扫完没反应"，属于静默故障）。
3. （可选）发 `v0.2.1` tag/Release 并把 APK 挂上去，让手机端不必靠电脑现构建。
   注意 versionCode `3` > `2`：**降级回 0.1.1 必须先卸载**。
4. **文档/代码漂移三处（都已核对，属真实现象，不是推断）**：
   - `MainActivity.java` 的 `UA_SUFFIX` 仍写 `DSHarnessMobile/0.2.0`，而 versionName 已是 0.2.1；
   - `onNewIntent` 上方注释还写「launchMode=singleTask」，manifest 实际是 `singleTop`；
   - `v2/README.md` 第六节的结构图写的是作者本机的独立文件夹名 `ds-harness-mobile-v2\`，
     仓库里的路径其实是 `v2/`。
5. （低价值清账）**根 `README.md` 里完全没有 v2 的入口**（grep 不到 `v2`/`0.2`/`扫码`/`二维码`），
   新读者只会看到 0.1.1 那套 Caddy 教程。建议加一段"0.2.1 见 `v2/README.md`"。
6. 接力：另一台机器 `git pull`（项目仓库 + 大脑仓库）后，对 agent 说
   "先读大脑仓库里 ds-harness-mobile 的笔记再继续"。

## 已知坑

- **自签证书的 SAN 只有 `dsh-mobile`，跟实际连接的 Tailscale 主机名不匹配** → 走 Caddy 门卫时
  **首次连接必然**弹「证书无法验证」，要人工点「仍然继续并记住」（v2 会按主机记住，之后不再问）。
  0.1.1 反而看不到这个弹窗，因为它是**无条件放行任何证书错误**（这正是 v2 要修的安全洞）。
- **`v2/` 缺 `local.properties` 就直接 `BUILD FAILED`**，报错只说
  "SDK location not found…define ANDROID_HOME or sdk.dir"，不会告诉你"去建个 local.properties"；
  本机 `ANDROID_HOME` 是**空的**，所以必须靠该文件（根目录那份是 v1 的，v2 不共用）。
- **缺 `release.keystore` 时构建不报错**，只静默产出 `app-release-unsigned.apk`
  → 装到手机上会因签名不符失败，**极易被误判成 App 的 bug**（构建日志里只有一行中文提示）。
- **明文 HTTP 被禁**：`http://<tailscale主机>:3080` 这类 0.1.x 老地址在 0.2.x 一定失败
  （报 `ERR_CLEARTEXT_NOT_PERMITTED`，App 有专门的提示文案）。要用明文只能装回 0.1.0 的包。
- **Android 12+ 不会把 `https://<id>.dsh-market.com` 链接交给本 App**（域名不归我们、
  没过 App Links 验证），所以**必须用 App 内的「扫码配对」，不要用系统相机扫**。
- **配对令牌是一次性的**：任一设备配对成功即失效；配第二台要回电脑点「刷新二维码」。
- **电脑侧面板出不来二维码**通常不是 App 的问题：① 没装那个第三方插件（官方 DSH 没这功能）；
  ② 绑的是回环且没开公网地址（要开「局域网访问」或「自动公网隧道」）；
  ③ 在局域网地址而不是 `127.0.0.1` 打开的界面里铸令牌（面板仅限本机）。
- **换机会"丢"签名与证书**：`release.keystore` / `*.pem` / `*.apk` / `local.properties`
  全被 `.gitignore` 挡着，这是设计如此——不是仓库损坏，照 `v2/README.md` 第七节自带或重生成。
- **本机没装那个插件**，所以本机跑不出二维码：验证扫码链路前先
  `dsh plugin --profile web add @linxin666/dsh-remote-web-ui` 并重启 `dsh web`。
- 工作区路径含空格/括号（`G:\ai\deepseek harness output\workspace\projects\ds-harness-mobile`）
  → `v2/gradle.properties` 开了 `android.overridePathCheck=true`（构建时会打一行 experimental 警告，正常）。
