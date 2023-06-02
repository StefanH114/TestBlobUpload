[Cmdletbinding()]
Param(
    [Parameter(Mandatory = $true)][string]$SettingsFileName
)

$settings = ConvertFrom-Json (Get-Content "$PSScriptRoot\$SettingsFileName" | Out-String)
[array]$files = gci $PSScriptRoot -Include ('*.html', '*.css') -Recurse 
$ignoreFiles = @("bootstrap.min.css")
$newVersion = [Guid]::NewGuid()
foreach($file in $files) {
    if ($ignoreFiles -contains $file.Name) { continue }
    $content = ((Get-Content $file.FullName -Raw -Encoding UTF8) -replace "(.+)\.(css|js)\?cbv=([0-9A-Fa-f\-]{36})""", "`$1.`$2?cbv=$newVersion""")
    $content = $content.Replace("[[CustomUiBasePath]]", $settings.CustomUiBasePath)
    $content = $content.Replace("[[B2CTenantName]]", $settings.B2CTenantName)
    $content | Set-Content $file.FullName -Encoding UTF8
}