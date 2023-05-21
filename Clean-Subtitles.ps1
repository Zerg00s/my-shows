function Clean-Subtitles {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,

        [Parameter(Mandatory=$true)]
        [string]$OutputFilePath
    )

    # Read content from the file
    $content = Get-Content -Path $FilePath

    # Remove timestamps, [music] and [музыка], lines with nothing but a number, and extra spaces
    $modifiedContent = $content -replace '\d\d:\d\d:\d\d,\d\d\d --> \d\d:\d\d:\d\d,\d\d\d' -replace '\[music\]|\[музыка\]' -replace '(?m)^\d+\r?$' -replace '  +' -replace '(?m)^\s+|\s+$'

    # Remove leading/trailing newline characters
    $modifiedContent = $modifiedContent.Trim()

    # Remove duplicate lines
    $Lines = @()
    $previousLine = ""
    $modifiedContent.Split("`n") | ForEach-Object {
        $currentLine = $_
        if ($currentLine -ne $previousLine) {
            if ($previousLine -ne "") {
                $Lines += $previousLine 
            }
            $previousLine = $currentLine
        }
    } | Out-Null

    #Concatenate the array of lines
    $Lines = $Lines -join "`n"
    $LinesConcatenated =  $Lines -replace '\n'," "

    # Save the modified content back to the file
    Write-Host "Writing modified content to file: $OutputFilePath"
    Set-Content -LiteralPath $OutputFilePath -Value $LinesConcatenated -Encoding UTF8 
}
