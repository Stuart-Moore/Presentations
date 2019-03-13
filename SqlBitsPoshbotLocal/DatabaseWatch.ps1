Import-Module PSSlack
Import-Module dbaTools

$webhook = 'https://hooks.slack.com/services/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'

while (1){
    $results = Get-DbaDatabase -SqlInstance localhost\sql2016 -Database slackwarning
    if ($Results.Status -ne 'Normal') {
        New-SlackMessageAttachment -Color $([System.Drawing.Color]::red) `
                           -Title 'Database down!' `
                           -Text "SlackWarning is not healthy" `
                           -Pretext 'Fix it!!!!!!' `
                           -AuthorName 'Sql Bot' `
                           -Fallback 'DB SlackWarning down!' |
        New-SlackMessage -Channel 'general' `
                        -IconEmoji :bomb: |
        Send-SlackMessage -Uri $webhook
        $recovered = 1
    }
    elseif ($recovered -eq 1){
        New-SlackMessageAttachment -Color $([System.Drawing.Color]::green) `
                           -Title 'Database Up' `
                           -Text "SlackWarning looks healthy again" `
                           -Pretext 'Everything is groovy' `
                           -AuthorName 'Sql Bot' `
                           -Fallback 'SlackWarning back up' |
        New-SlackMessage -Channel 'general' `
                        -IconEmoji :+1: |
        Send-SlackMessage -Uri $webhook

        $recovered = 0
    }
    Start-sleep -Seconds 30
}

