$ErrorActionPreference = 'SilentlyContinue'
$raw = [Console]::In.ReadToEnd()
if (-not $raw) { exit 0 }
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }
$cmd = $data.tool_input.command
if (-not $cmd) { exit 0 }                       # not a command-running tool; skip
$flat = ($cmd -replace '\r?\n', ' ')            # flatten multi-line commands to one log line

$proj = if ($data.cwd) { Split-Path $data.cwd -Leaf } else { 'misc' }
$proj = ($proj -replace '[^\w\.-]', '_')        # sanitize for filesystem

$sidRaw = ($data.session_id -replace '[^\w]', '')
$sid = if ($sidRaw.Length -ge 8) { $sidRaw.Substring(0,8) } elseif ($sidRaw) { $sidRaw } else { 'nosid' }

# Log into the project's .claude/logs. The script lives in .claude/hooks/,
# so its parent (.claude) + logs is the project log dir.
$claudeDir = if ($PSScriptRoot) { Split-Path $PSScriptRoot -Parent }
             elseif ($data.cwd) { Join-Path $data.cwd '.claude' }
             else { Join-Path $env:USERPROFILE '.claude' }
$logDir = Join-Path $claudeDir 'logs'
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$file = '{0}_{1}_{2}.log' -f $proj, (Get-Date -Format 'yyyy-MM-dd'), $sid
$log  = Join-Path $logDir $file

$line = '[{0}] [{1}] {2} :: {3}' -f (Get-Date -Format 'HH:mm:ss'), $data.tool_name, $data.cwd, $flat
Add-Content -LiteralPath $log -Value $line -Encoding UTF8
exit 0
