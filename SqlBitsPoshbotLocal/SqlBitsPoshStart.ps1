Import-Module poshbot
$pbc = Get-PoshBotConfiguration -Path c:\github\Presentations\SqlBitsPoshBot\config.psd1
Start-PoshBot -Configuration $pbc -ErrorVariable err