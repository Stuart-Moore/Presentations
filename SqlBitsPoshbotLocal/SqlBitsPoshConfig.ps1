Import-Module PoshBot

# Define Bot Configuration
$Token = 'Oh3ZmHlxQiBURoGjdLhnPDIq'
$BotName = 'BitsSlackTest' # The name of the bot we created
$BotAdmin = 'Stuart Moore' # My account name in Slack
$PoshbotPath = 'c:\github\Presentations\SqlBitsPoshBot'
$PoshbotConfig = Join-Path $PoshbotPath config.psd1
$PoshbotPlugins = Join-Path $PoshbotPath plugins
$PoshbotLogs = Join-Path $PoshbotPath logs

$botParams = @{
    Name = 'Bitstestbot'
    BotAdmins = @('stuart.moore','UBJ75CW01')
    CommandPrefix = '!'
    LogLevel = 'Info'
    BackendConfiguration = @{
        Name = 'SlackBackend'
        Token = 'you need to get your own token from slack'
    }
    LogDirectory = $PoshbotLogs
    PluginDirectory = $PoshbotPlugins
    ConfigurationDirectory = $PoshbotPath
    AlternateCommandPrefixes = 'sqlbot', 'bob'
}
# Set up folders for logging and plugins, save the config
#$null = mkdir $PoshbotPath, $PoshbotPlugins, $PoshbotLogs -Force
$pbc = New-PoshBotConfiguration @BotParams -
Save-PoshBotConfiguration -InputObject $pbc -Path $PoshbotConfig -force


$backend = New-PoshBotSlackBackend -Configuration $BotParams.BackendConfiguration
$bot = New-PoshBotInstance -Configuration $BotParams -Backend $backend
$bot | Start-PoshBot -Verbose
