Import-Module dbatools

# Slack text width with the formatting we use maxes out ~80 characters...
$Width = 120
$CommandsToExport = @()

function Get-Whoami {
    <#
    .SYNOPSIS
        returns the account running the bot
    .EXAMPLE
        !bob who
    #>
    [cmdletbinding(DefaultParameterSetName = 'id')]
    [PoshBot.BotCommand(
        CommandName = 'whoamipb',
        Aliases = ('who','Get-whoami'),
        Permissions = 'read'
    )]
    param()
    $o = $env:USERNAME | Out-string
    New-PoshBotCardResponse -Type Normal -Text $o
}
$CommandsToExport += 'Get-Whoami'

function Test-SlackSqlConnection {
    <#
    .SYNOPSIS
        tests connection to Sql Instance
    .EXAMPLE
        !Test-SlackSqlConnection server1
    #>
    [cmdletbinding(DefaultParameterSetName = 'id')]
    [PoshBot.BotCommand(
        CommandName = 'testsqlconnection',
        Aliases = ('td'),
        Permissions = 'read'
    )]
    param(
        [parameter(position = 1,
                   parametersetname = 'id')]
        [string]$sqlinstance
    )

    $results = Test-DbaConnection -SqlInstance $sqlinstance
    if ($results.ConnectSuccess -eq $true) {
        New-PoshBotCardResponse -Type Normal -Text "Connection test to $sqlinstance succeeded" -Title 'Output of Test-SqlConnection' -ThumbnailUrl 'https://www.streamsports.com/images/icon_green_check_256.png'
    }
    else {
        New-PoshBotCardResponse -Type Error -Text "Connection test to $sqlinstance failed" -Title 'Output of Test-SqlConnection' -ThumbnailUrl 'http://p1cdn05.thewrap.com/images/2015/06/don-draper-shrug.jpg'
    }
}
$CommandsToExport += 'Test-SlackSqlConnection'


function Get-SlackDatabase {
    <#
    .SYNOPSIS
        Finds a database
    .EXAMPLE
        !getdatabase db1
    #>
    [cmdletbinding(DefaultParameterSetName = 'id')]
    [PoshBot.BotCommand(
        CommandName = 'getdatabase',
        Aliases = ('gdb'),
        Permissions = 'read'
    )]
    param(
        [parameter(position = 1,
                   parametersetname = 'id')]
        [string]$database
    )

    $Results = Get-DbaDatabase -SqlInstance localhost\sql2016 | Where-Object {$_.name -like "*$database*"}
    if ($results.count -gt 0){
        $out = $results | select-Object name, status, size | Format-Table -AutoSize | Out-String -Width 80
        New-PoshBotCardResponse -Type Normal -Text $out -Title 'Databases found'
    }
    else {
        New-PoshBotCardResponse -Type Error -Text $out -Title 'No Databases found' -ThumbnailUrl 'https://media.giphy.com/media/TU76e2JHkPchG/giphy.gif'
    }
}
$CommandsToExport += 'Get-SlackDatabase'

Function Copy-SlackDatabase {
    <#
    .SYNOPSIS
        Copies a database
    .EXAMPLE
        !copydatabase
    #>
    [cmdletbinding(DefaultParameterSetName = 'id')]
    [PoshBot.BotCommand(
        CommandName = 'copydatabase',
        Aliases = ('cpd'),
        Permissions = 'read'
    )]
    param(
        [parameter(position = 1,
                   parametersetname = 'id')]
        [string]$database
    )
    $results = Copy-DbaDatabase -Source localhost\sql2016 -Destination localhost\sql2016 -Database $database -BackupRestore -NetworkShare c:\temp -prefix (Get-Random)
    if ($results.status -eq "Successful"){
        New-PoshBotCardResponse -Type Normal -Text "database $database copied successfully" -Title "Copy $database results" -ThumbnailUrl 'https://www.streamsports.com/images/icon_green_check_256.png'
    }
    else {
        $o = $results | Select-Object status -Unique
        New-PoshBotCardResponse -Type Error -Text "database $database copy did not complete. Status was $o" -Title "Copy $database results" -ThumbnailUrl 'http://p1cdn05.thewrap.com/images/2015/06/don-draper-shrug.jpg'

    }
}
$CommandsToExport += 'Copy-SlackDatabase'

function Get-SqlError {
    [cmdletbinding(DefaultParameterSetName = 'default')]
    [PoshBot.BotCommand(
        CommandName = 'loginerror',
        Aliases = ('gle'),
        Permissions = 'read'
    )]
    param(
        [parameter(position = 1,
        parametersetname = 'default')]
        [string]$sqlInstance
    )
    $results = Get-DbaErrorLog -SqlInstance $sqlinstance -After (Get-Date).AddHours(-1) | Out-String -Width $Width
    New-PoshBotCardResponse -Type Normal -Text $results -Title "Last hour of errors from $sqlinstance"
}

$CommandsToExport += "Get-SqlError"


function Get-AdvSlackDatabase {
    <#
    .SYNOPSIS
        Finds a database
    .EXAMPLE
        !copydatabase db1
    #>
    [cmdletbinding(DefaultParameterSetName = 'id')]
    [PoshBot.BotCommand(
        CommandName = 'getadatabase',
        Aliases = ('gadb'),
        Permissions = 'read'
    )]
    param(
        [parameter(position = 1,
        parametersetname = 'id')]
        [string]$instance,
        [parameter(position = 2,
        parametersetname = 'id')]
        [string]$database

    )

    $Results = Get-DbaDatabase -SqlInstance $instance | Where-Object {$_.name -like "*$database*"}
    if ($results.count -gt 0){
        $out = $results | select-Object name, status, size | Format-Table -AutoSize | Out-String -Width 80
        New-PoshBotCardResponse -Type Normal -Text $out -Title 'Databases found on $instance'
    }
    else {
        New-PoshBotCardResponse -Type Error -Text 'No databases found'-Title 'No Databases found' -ThumbnailUrl 'https://media.giphy.com/media/TU76e2JHkPchG/giphy.gif'
    }
}
$CommandsToExport += 'Get-AdvSlackDatabase'

function Get-Pug {
    [PoshBot.BotCommand(
        CommandName = 'getpug',
        Aliases = ('pugbomb'),
        Permissions = 'read'
    )]
    param()
    $results = ConvertFrom-Json -InputObject (Invoke-WebRequest http://pugme.herokuapp.com/random).content
    New-PoshBotCardResponse -ImageUrl $results.pug
}
$CommandsToExport += 'Get-Pug'
function Get-MockData {
    [cmdletbinding(DefaultParameterSetName = 'id')]
    [PoshBot.BotCommand(
        CommandName = 'getmockdata',
        Aliases = ('gmd'),
        Permissions = 'read'
    )]
    param()
    $filename  = Join-Path -Path $env:TEMP -ChildPath "$(get-random)-mockdata.csv"
    Invoke-RestMethod -uri "https://api.mockaroo.com/api/generate.csv?key=b2bdf610&schema=mocktest&count=100" -OutFile $filename
    New-PoshBotFileUpload -Path $filename -Title 'Mocked data'
}
$CommandsToExport += 'Get-MockData'
function Test-WebInfra {
    <#
    .SYNOPSIS
        Tests web infrastucture
    .EXAMPLE
        !test-web
    #>
    [cmdletbinding(DefaultParameterSetName = 'id')]
    [PoshBot.BotCommand(
        CommandName = 'testweb',
        Aliases = ('tw', 'test-webinfra'),
        Permissions = 'read'
    )]
    param(
        [parameter(position = 1,
                   parametersetname = 'id')]
        [string]$talky
    )
    $width = 120
    $issues = 0
    $errors = ""
    1..5 | For-Each{

        $o = Test-Connection "web-$_." -ErrorAction SilentlyContinue -ErrorVariable errvar | Format-Table -AutoSize | Out-String -Width $width
        if ("" -ne $errvar) {
            if ($talky){
                New-PoshBotCardResponse -Type Error -Text "Couldn't connect to web-$_" -ThumbnailUrl 'http://p1cdn05.thewrap.com/images/2015/06/don-draper-shrug.jpg'
            }
            $errors += "`n Couldn't connect to web-$_ `n $errvar"
            $issues++
        }
        else{
            if ($talky){
                New-PoshBotCardResponse -type Normal -Text $o -ThumbnailUrl 'https://www.streamsports.com/images/icon_green_check_256.png'
            }
        }

    }

    $SqlConn = Test-DbaConnection -SqlInstance webdb -ErrorAction SilentlyContinue -ErrorVariable sqlerrvar
    # | Format-Table -AutoSize | Out-String -Width $width
    #New-PoshBotCardResponse -Type Normal -Text $o
    New-PoshBotCardResponse -type Normal -Text $o
    if ($sqlConn.ConnectSuccess -eq $true){
        if ($talky){
            New-PoshBotCardResponse -type Normal -Text "Connected to webdb fine" -ThumbnailUrl 'https://www.streamsports.com/images/icon_green_check_256.png'
        }
    }
    else {
        New-PoshBotCardResponse -Type Error -Text "Couldn't connect to webdb" -ThumbnailUrl 'http://p1cdn05.thewrap.com/images/2015/06/don-draper-shrug.jpg'
        $issues ++
        $errors += "`n Couldn't connect to webdb `n $sqlerrvar"
    }

    if ($issues -eq 0) {
        New-PoshBotCardResponse -type Normal -Text "All looks good" -ThumbnailUrl 'https://www.streamsports.com/images/icon_green_check_256.png'
    }
    else {
        New-PoshBotCardResponse -Type Error -Text "oops, the following is broken: `n $errors" -ThumbnailUrl 'http://p1cdn05.thewrap.com/images/2015/06/don-draper-shrug.jpg'

    }
}
$CommandsToExport += 'Test-WebInfra'

function restart-WebInfra {
    <#
    .SYNOPSIS
        restarts web infrastucture
    .EXAMPLE
        !restart-web
    #>
    [cmdletbinding(DefaultParameterSetName = 'id')]
    [PoshBot.BotCommand(
        CommandName = 'restartweb',
        Aliases = ('rw', 'restart-webinfra'),
        Permissions = 'write'
    )]
    param(
        [parameter(position = 1,
                   parametersetname = 'id')]
        [string]$talky,
        [parameter(position = 2,
                   parametersetname = 'id')]
        [string]$nowait
    )
    $width = 120
    $issues = 0
    $errors = ""

    1..5 | ForEach-Object {
        Restart-Computer -ComputerName "web-$_" -Force
        if ($talky){
            New-PoshBotCardResponse -Type Normal -Text "restarting web-$_"
        }
        if(!$nowait){
            start-sleep -seconds 30
        }
    }
}
$CommandsToExport += 'Restart-WebInfra'


Export-ModuleMember -Function $CommandsToExport