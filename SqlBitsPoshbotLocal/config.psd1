@{
  ApprovalConfiguration = @{
    Commands = @()
    ExpireMinutes = 30
  }
  DisallowDMs = $False
  ModuleManifestsToLoad = @()
  LogDirectory = 'C:\github\Presentations\SqlBitsPoshBot\logs'
  Name = 'Bitstestbot'
  BotAdmins = @('stuart.moore')
  AlternateCommandPrefixSeperators = @(':',',',';')
  CommandHistoryMaxLogSizeMB = 10
  FormatEnumerationLimitOverride = -1
  LogLevel = 'Info'
  SendCommandResponseToPrivate = @()
  ChannelRules = @{
    IncludeCommands = @('*')
    Channel = '*'
    ExcludeCommands = @()
  }
  ConfigurationDirectory = 'c:\github\Presentations\SqlBitsPoshBot'
  MaxLogsToKeep = 5
  AddCommandReactions = $True
  CommandHistoryMaxLogsToKeep = 5
  MaxLogSizeMB = 10
  PluginDirectory = 'c:\github\Presentations\SqlBitsPoshBot\plugins'
  MuteUnknownCommand = $False
  PluginConfiguration = @{

  }
  AlternateCommandPrefixes = @('sqlbot','bob')
  CommandPrefix = '!'
  BackendConfiguration = @{
    Token = 'you need to get your own token from slack'
    Name = 'SlackBackend'
  }
  PluginRepository = @('-')
  LogCommandHistory = $True
}
