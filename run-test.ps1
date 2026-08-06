param(
  [Parameter(ValueFromRemainingArguments)]
  [string[]] $ExtraArgs
)

$ErrorActionPreference = 'Stop'

$testDir = Join-Path -Path $PSScriptRoot -ChildPath tests

$files = Get-ChildItem -Path $testDir -Filter test_*.lua

if ($files.Count -eq 0) {
  Write-Output -InputObject 'No test files matching tests/test_*.lua'
  exit 0
}

$failed = 0
foreach ($file in $files) {
  Write-Output -InputObject "=== $($file.Name) ==="
  & lua $file @ExtraArgs
  $status = $LastExitCode
  if ($status -ne 0) {
    ++$failed
  }
  Write-Output -InputObject ''
}

Write-Output -InputObject "$($files.Count) file(s), $failed failed"
if ($failed -eq 0) {
  exit 0
} else {
  exit 1
}
