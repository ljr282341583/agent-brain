<#
.SYNOPSIS
  在每台机器上一键铺好「大脑笔记指路条」（AGENTS.local.md）。

.DESCRIPTION
  干什么：在每个项目文件夹里放一个 AGENTS.local.md，里面写清「本项目的大脑笔记在哪」。
  效果：DSH 每次开会话就自动把那段指路条摆到 agent 眼前，
        不用再打「先读大脑仓库里本项目的笔记再继续」。

  为什么必须是脚本：AGENTS.local.md 是**本机文件、不入 git**（`.local` 就是这个意思），
  所以在 B 机 / 第三台机上不会自己出现 —— 这台机器铺完，换机器再跑一次本脚本即可。

  路径怎么找（不写死盘符）：
    1) 大脑仓库根：先读 %USERPROFILE%\.agent-brain；没有再依次探测
       G:\ai\agent-brain、D:\ai\agent-brain、E:\ai\agent-brain、%USERPROFILE%\agent-brain。
    2) 工作空间与项目文件夹：读 DSH 自己的项目登记表
       <DSH_HOME>\storages\workspace.json，取其中所有「父目录叫 projects」的路径。
       所以换机器不用改参数。

  幂等：可重复跑。内容没变就报「未变」，不会瞎改。

.PARAMETER BrainRoot
  手动指定大脑仓库根（跳过自动探测）。

.PARAMETER WorkspaceJson
  手动指定 DSH 项目登记表路径（默认 <DSH_HOME>\storages\workspace.json）。

.PARAMETER Force
  内容即使没变也重写一遍。

.EXAMPLE
  pwsh -File .\铺大脑指路条.ps1 -WhatIf    # 只看会动哪些文件，不写
  pwsh -File .\铺大脑指路条.ps1            # 真铺
#>
[CmdletBinding(SupportsShouldProcess)]
param(
  [string]$BrainRoot,
  [string]$WorkspaceJson,
  [switch]$Force
)

$ErrorActionPreference = 'Stop'
$Utf8 = New-Object System.Text.UTF8Encoding($false)

# ============================================================
# 指路条模板（单引号 here-string：$ 与反引号都是字面量，
# 只有 {{占位符}} 会被替换，避免转义踩坑）
# ============================================================

$TplWithNotes = @'
# 大脑笔记（本机指路条，不入库）

本项目跨机思路与断点**以大脑仓库为准**。开工前先读，别凭印象办事：

- `{{BRAINROOT}}\项目\{{BRAIN}}\CONTEXT.md` —— 项目是什么、当前阶段、硬约束
- `{{BRAINROOT}}\项目\{{BRAIN}}\NEXT.md` —— **当前断点，必读**
- 同目录 `DECISIONS.md` 按需查（定过什么、否决过什么，别重复被否的方案）
- 同目录 `JOURNAL\` 只在追历史时翻，**不要整篇读**

收尾时用 session-handoff skill：写 JOURNAL、更新 NEXT、推送「项目仓库 + 大脑仓库」。
本机大脑仓库路径以 `%USERPROFILE%\.agent-brain` 为准。
{{NOTE}}
'@

$TplNoNotes = @'
# 大脑笔记（本机指路条，不入库）

大脑仓库 `{{BRAINROOT}}\项目\` 下**还没有本项目的文件夹**。
开工前先问用户一句：要不要给本项目建档（CONTEXT / DECISIONS / NEXT / JOURNAL 四件套）；
建好后把目录名补进本文件。

- 本机大脑仓库根：以 `%USERPROFILE%\.agent-brain` 为准（本机为 `{{BRAINROOT}}`）
- 工作空间级规范：`{{WORKSPACE}}\AGENTS.md`
{{NOTE}}
'@

$TplWorkspace = @'
# 工作空间级指路条（本机，不入库）

- 本工作空间的规范在同目录 `AGENTS.md`
- 各项目的跨机笔记在大脑仓库：`{{BRAINROOT}}\项目\<项目名>\`
- 进某个项目干活前：先读 `项目\<项目名>\CONTEXT.md` 与 `NEXT.md`
- 一个项目干完：用 session-handoff skill 收尾（写笔记 + 推送两个仓库）
'@

# ------------------------------------------------------------
# 需要特殊待遇的项目。没列在这里的，一律按「文件夹名 = 大脑笔记目录名」自动判断。
# ------------------------------------------------------------
$Overrides = @{
  'DSH双机协作' = @{
    Brain = 'DSH双击协作'
    Note  = '（注意：大脑仓库里这个笔记目录叫「双**击**协作」，而项目文件夹叫「双**机**协作」，是历史遗留的不一致。）'
  }
  'ds-harness-desktop' = @{
    Note = '（仓库内的 AGENTS.md 仍是本项目唯一主指引，本文件只补一条指路。）'
  }
  '随便1' = @{
    Note = '（本文件夹是杂项工具箱/试手区，不是单一项目。）'
  }
  '剪视频' = @{
    Note = '（本文件夹目前是空的，这个项目还没动手。）'
  }
  '小红书抖音去水印' = @{
    Custom = @'
# 大脑笔记（本机指路条，不入库）

本文件夹是「轻取」的前身工作区（旧名「小红书抖音去水印」）。

- 该项目的大脑笔记现已归到 `{{BRAINROOT}}\项目\qingqu-media-saver\` —— **先读那里的 CONTEXT.md 与 NEXT.md**
- 【推断，未拍板】本文件夹的内容可能已被 `qingqu-media-saver\版本归档\服务器版-v1.0\` 取代；动手前先问用户这个目录还有没有效。
'@
  }
}

# ============================================================
# 工具函数
# ============================================================

function New-Pointer {
  param([string]$Template, [hashtable]$Context)
  $t = $Template
  foreach ($k in $Context.Keys) { $t = $t.Replace('{{' + $k + '}}', [string]$Context[$k]) }
  return ($t.TrimEnd() + "`n")
}

function Resolve-BrainRoot {
  param([string]$Explicit)
  if ($Explicit) {
    if (-not (Test-Path (Join-Path $Explicit '项目'))) { throw "「$Explicit」不是大脑仓库根（里面没有「项目」文件夹）。" }
    return (Resolve-Path $Explicit).Path
  }
  $marker = Join-Path $env:USERPROFILE '.agent-brain'
  if (Test-Path $marker) {
    $p = ([System.IO.File]::ReadAllText($marker, $Utf8)).Trim()
    if ($p -and (Test-Path (Join-Path $p '项目'))) { return (Resolve-Path $p).Path }
    Write-Warning "「$marker」里写的路径不可用：$p"
  }
  $candidates = @('G:\ai\agent-brain', 'D:\ai\agent-brain', 'E:\ai\agent-brain', (Join-Path $env:USERPROFILE 'agent-brain'))
  foreach ($c in $candidates) {
    if (Test-Path (Join-Path $c '项目')) { return (Resolve-Path $c).Path }
  }
  throw '找不到大脑仓库。请用 -BrainRoot 指定，或把路径写进 %USERPROFILE%\.agent-brain。'
}

function Resolve-Targets {
  param([string]$JsonPath)
  if (-not $JsonPath) {
    $dshHome = if ($env:DSH_HOME) { $env:DSH_HOME } else { Join-Path $env:USERPROFILE '.dsh' }
    $JsonPath = Join-Path $dshHome 'storages\workspace.json'
  }
  if (-not (Test-Path $JsonPath)) { throw "找不到 DSH 项目登记表：$JsonPath（可用 -WorkspaceJson 指定）" }

  $j = [System.IO.File]::ReadAllText($JsonPath, $Utf8) | ConvertFrom-Json
  $all = @()
  foreach ($w in $j.tables.workspaces.PSObject.Properties) {
    if ($w.Value.path) { $all += $w.Value.path }
  }

  $projects = @()
  $roots = @()
  foreach ($p in ($all | Sort-Object -Unique)) {
    if (-not (Test-Path $p)) { continue }
    $parent = Split-Path $p -Parent
    if ((Split-Path $parent -Leaf) -eq 'projects') {
      $root = Split-Path $parent -Parent
      $projects += [pscustomobject]@{ Path = $p; Name = (Split-Path $p -Leaf); WorkspaceRoot = $root }
      $roots += $root
    }
  }

  # 登记表之外补一轮：磁盘上带 .git 的真项目也算。例：ds-harness-desktop 从没进过登记表，
  # 但它是活跃仓库 —— 工作空间根那个会话读它下面的文件时，靠「嵌套发现」把指路条加载进来。
  # 跳过 _ 开头的系统保留目录（_归档 / _项目模板）。
  $seen = @($projects | ForEach-Object { $_.Path })
  foreach ($root in ($roots | Sort-Object -Unique)) {
    $projDir = Join-Path $root 'projects'
    if (-not (Test-Path $projDir)) { continue }
    foreach ($d in (Get-ChildItem $projDir -Directory)) {
      if ($d.Name.StartsWith('_')) { continue }
      if ($seen -contains $d.FullName) { continue }
      if (Test-Path (Join-Path $d.FullName '.git')) {
        $projects += [pscustomobject]@{ Path = $d.FullName; Name = $d.Name; WorkspaceRoot = $root }
        $seen += $d.FullName
      }
    }
  }

  return [pscustomobject]@{
    WorkspaceRoots = ($roots | Sort-Object -Unique)
    Projects       = ($projects | Sort-Object -Unique -Property Path)
    Source         = $JsonPath
  }
}

function Add-GitExclude {
  param([string]$Dir)
  $gitDir = Join-Path $Dir '.git'
  if (-not (Test-Path $gitDir -PathType Container)) { return '无 git 仓库' }
  $ex = Join-Path $gitDir 'info\exclude'
  if (-not (Test-Path $ex)) { return '无 exclude 文件' }
  $cur = [System.IO.File]::ReadAllText($ex, $Utf8)
  if ($cur -match '(?m)^\s*AGENTS\.local\.md\s*$') { return '已含' }
  if ($PSCmdlet.ShouldProcess($ex, '追加 AGENTS.local.md')) {
    [System.IO.File]::AppendAllText($ex, "`n# DSH 大脑笔记指路条（本机，不入库）`nAGENTS.local.md`n", $Utf8)
    return '已追加'
  }
  return '（WhatIf 未写）'
}

# ============================================================
# 主流程
# ============================================================

$brain = Resolve-BrainRoot -Explicit $BrainRoot
$t = Resolve-Targets -JsonPath $WorkspaceJson

Write-Host ''
Write-Host "大脑仓库根   : $brain" -ForegroundColor Cyan
Write-Host "项目登记表   : $($t.Source)" -ForegroundColor Cyan
Write-Host "工作空间根   : $($t.WorkspaceRoots -join ' | ')" -ForegroundColor Cyan
Write-Host "待处理项目   : $($t.Projects.Count) 个" -ForegroundColor Cyan
Write-Host ''

# ---- 组装待写任务 ----
$jobs = @()
foreach ($r in $t.WorkspaceRoots) {
  $jobs += [pscustomobject]@{
    Path   = Join-Path $r 'AGENTS.local.md'
    Kind   = '工作空间级'
    Label  = $r
    Content = (New-Pointer $TplWorkspace @{ BRAINROOT = $brain })
  }
}

foreach ($p in $t.Projects) {
  $ov = $Overrides[$p.Name]
  if ($ov -and $ov.Custom) {
    $content = New-Pointer $ov.Custom @{ BRAINROOT = $brain; WORKSPACE = $p.WorkspaceRoot }
  }
  else {
    $brainDir = if ($ov -and $ov.Brain) { $ov.Brain } else { $p.Name }
    $note = if ($ov -and $ov.Note) { $ov.Note } else { '' }
    if (Test-Path (Join-Path $brain "项目\$brainDir")) {
      $content = New-Pointer $TplWithNotes @{ BRAINROOT = $brain; BRAIN = $brainDir; NOTE = $note }
    }
    else {
      $content = New-Pointer $TplNoNotes @{ BRAINROOT = $brain; WORKSPACE = $p.WorkspaceRoot; NOTE = $note }
    }
  }
  $jobs += [pscustomobject]@{
    Path    = Join-Path $p.Path 'AGENTS.local.md'
    Kind    = '项目级'
    Label   = $p.Path
    Content = $content
  }
}

# ---- 写 ----
$report = @()
foreach ($j in $jobs) {
  $exists = Test-Path $j.Path
  $state = '新建'
  if ($exists) {
    $old = [System.IO.File]::ReadAllText($j.Path, $Utf8)
    if ($old -eq $j.Content) { $state = if ($Force) { '强制覆盖' } else { '未变' } }
    else { $state = '更新' }
  }
  $effective = $state
  if ($state -in @('新建', '更新', '强制覆盖')) {
    if ($PSCmdlet.ShouldProcess($j.Path, $state)) {
      [System.IO.File]::WriteAllText($j.Path, $j.Content, $Utf8)
    }
    else { $effective = '（WhatIf 未写）' }
  }
  $git = Add-GitExclude -Dir (Split-Path $j.Path -Parent)
  $report += [pscustomobject]@{
    类型 = $j.Kind
    项目 = if ($j.Kind -eq '项目级') { Split-Path $j.Path -Parent | Split-Path -Leaf } else { '(工作空间根)' }
    文件 = $effective
    git  = $git
  }
}

Write-Host ''
$report | Format-Table -AutoSize

Write-Host '指路条是**本机文件、不入 git**。换机器（B 机 / 第三台）克隆完大脑仓库后，'
Write-Host '把本脚本再跑一次即可；跑完随便开一个项目会话，看开头有没有 Instructions from: AGENTS.local.md。'
