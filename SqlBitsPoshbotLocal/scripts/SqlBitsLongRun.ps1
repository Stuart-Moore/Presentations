Import-Module PSSlack

Start-Sleep -Seconds 120

$webhook = 'https://hooks.slack.com/services/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'
Send-SlackMessage -Uri $webhook -Parse full -Text 'Test job just finished'

New-SlackMessageAttachment -Color $([System.Drawing.Color]::green) `
                           -Title 'Long running job has finished' `
                           -Text "I've waited for 2 minutes" `
                           -Pretext 'Everything is groovy' `
                           -AuthorName 'Sql Bot' `
                           -FallBack 'Job finished' |
    New-SlackMessage -Channel 'general' `
                     -IconEmoji :bomb: |
    Send-SlackMessage -Uri $webhook