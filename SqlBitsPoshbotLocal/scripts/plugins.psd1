@{
  'poshbot.example' = @{
    '0.0.1' = @{
      Version = '0.0.1'
      Name = 'poshbot.example'
      AdhocPermissions = @()
      ManifestPath = 'c:\github\Presentations\SqlBitsPoshBot\plugins\poshbot.example\poshbot.example.psd1'
      CommandPermissions = @{
        var = @('poshbot.example:read')
        groups = @('poshbot.example:read')
        user = @('poshbot.example:read')
        ping = @('poshbot.example:read')
      }
      Enabled = $True
    }
  }
  'demo.dbachatops' = @{
    '0.0.1' = @{
      Version = '0.0.1'
      Name = 'demo.dbachatops'
      AdhocPermissions = @()
      ManifestPath = 'c:\github\Presentations\SqlBitsPoshBot\plugins\demo.dbachatops\demo.dbachatops.psd1'
      CommandPermissions = @{
        var = @('demo.dbachatops:read')
        testweb = @('demo.dbachatops:read')
        restartweb = @('demo.dbachatops:read')
      }
      Enabled = $True
    }
  }
}
