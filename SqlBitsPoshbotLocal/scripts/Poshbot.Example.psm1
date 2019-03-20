Import-Module ActiveDirectory

# Slack text width with the formatting we use maxes out ~80 characters...
$Width = 120
$CommandsToExport = @()

function Get-VariableViaSlack {
    <#
    .SYNOPSIS
        Get variables in the poshbot command context
    .EXAMPLE
        !var
    #>
    [cmdletbinding()]
    [PoshBot.BotCommand(
        CommandName = 'var',
        Aliases = ('Get-Variable', 'gv'),
        Permissions = 'read'
    )]
    param()

    # Ideally you would handle selecting a specific variable name, smaybe using ConvertTo-FlatObject to view depth in Slack

    # This will give us a table within Slack's char limit
    $o = Get-Variable | Format-Table -AutoSize -Wrap | Out-String -Width $Width

    # Most output we write to slack will use a card response
    # Check the various parameters to see what you can do with it!
    New-PoshBotCardResponse -Type Normal -Text $o
}
$CommandsToExport += 'Get-VariableViaSlack'


function Get-ADUserViaSlack {
    <#
    .SYNOPSIS
        Get AD User info
    .EXAMPLE
        !user wframe
    .EXAMPLE
        !user wframe --Properties *
    .EXAMPLE
        !user --LDAPFilter (displayname=*warren*)
    #>
    [cmdletbinding(DefaultParameterSetName = 'id')]
    [PoshBot.BotCommand(
        CommandName = 'user',
        Aliases = ('u', 'Get-ADUser'),
        Permissions = 'read'
    )]
    param(
        [parameter(position = 1,
                   parametersetname = 'id')]
        [string]$Identity,

        [parameter(position = 1,
                   parametersetname = 'filter')]
        [Alias('l')]
        [string]$LDAPFilter,

        [parameter(position = 2)]
        [Alias('p')]
        [string[]]$Properties,

        [validateset('list','table')]
        [Alias('f')]
        [string]$Format = 'list'
    )

    # We're going to borrow PSBoundParameters when we make our Get-ADUser call,
    # so we'll manipulate it as we go

    # Handle default properties we might care about
    if(-not $PSBoundParameters.ContainsKey('Properties')) {
        $PSBoundParameters.add('Properties', $('sAMAccountName', 'enabled', 'mail', 'company', 'department', 'title'))
    }

    # User didn't specify format.  Pick a table if 7 or less props, and prop isn't '*'
    if(-not $PSBoundParameters.ContainsKey('Format') -and @($PSBoundParameters.Properties).Count -lt 7 -and @($PSBoundParameters.Properties) -notcontains '*') {
         $Format = 'table'
    }
    # remove this, don't need it for get-aduser call
    [void]$PSBoundParameters.Remove('Format')

    # Format as list or table...
    if($Format -eq 'list') {
        $o = Get-ADUser @PSBoundParameters | Select-Object -Property $PSBoundParameters['Properties'] | Format-List | Out-String -Width $Width
    }
    else {
        $o = Get-ADUser @PSBoundParameters | Select-Object -Property $PSBoundParameters['Properties'] | Format-Table -AutoSize -Wrap | Out-String -Width $Width
    }
    New-PoshBotCardResponse -Type Normal -Text $o
}


function Test-SlackConnection {
    <#
    .SYNOPSIS
        ping an  machine
    .EXAMPLE
        !p box1
    #>
    [cmdletbinding(DefaultParameterSetName = 'id')]
    [PoshBot.BotCommand(
        CommandName = 'ping',
        Aliases = ('p', 'Test-SlackConnection'),
        Permissions = 'read'
    )]
    param(
        [parameter(position = 1,
                   parametersetname = 'id')]
        [string]$Machine
    )
    $o = Test-Connection -ComputerName $Machine | Format-Table -AutoSize | Out-String -Width $width
    New-PoshBotCardResponse -Type Normal -Text $o
}

$CommandsToExport += 'Test-SlackConnection'

Export-ModuleMember -Function $CommandsToExport