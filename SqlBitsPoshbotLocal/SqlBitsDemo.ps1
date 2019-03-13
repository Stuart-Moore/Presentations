<#
intro the basics of slack

@channel - all active (online) channel members - OK
@here - all channel members - OKis
@everyrone - everyone in the general channel. Pretty much everyone as it's the default - You won't be popular!

@user to ping a particular user or pull them into a conversation

Use Direct Messages for long running 1-1 conversations that don't need everyone (can be 1-x)

Use channels to split up topics if not everyone wants to see them
#>

# long running webhook
C:\github\Presentations\SqlBitsPoshBot\SqlBitsLongRun.ps1

# Adding to existing scripts - alerting when db goes offline
C:\github\Presentations\SqlBitsPoshBot\DatabaseWatch.ps1

#Using a bot
#command prefix (L32 config.psd1)
!help

#give it a name
bob help

#commands can have aliases:
bob man

bob Get-CommandHistory
#vs
bob history

#can also chat directly via dm to avoid spamming the main channel
bob help

# Switch to non admin stuart
bob help
bob status

#permission denied
#Back to Normal account

bob help status

bob help new-role
bob new-role -name ‘readonly’ -description ‘Readonly view of poshbot status’

bob add-rolepermission readonly Builtin:view

bob new-group readonlygroup
bob add-grouprole readonlygroup readonly

#Due to a change in poshbot that hides the real username we need to look it up
$token = 'you need to get your own token from slack'
Get-SlackUser -Token $Token | Select-Object name, displayname

bob add-groupuser readonlygroup eeymsmo

#Back to Non admin stuart
bob status

#work through the psd1 files

#adding Ps custom functions

bob who

# Adding in some dbatools stuff
bob testsqlconnection localhost\sql2016

bob getdatabase SlackWarning

bob gadb localhost\sql2016 *

bob copydatabase SlackWarning

bob cpd Slackwarning

bob get SqlErrror localhost\sql2016

bob getpug

bob getmockdata

