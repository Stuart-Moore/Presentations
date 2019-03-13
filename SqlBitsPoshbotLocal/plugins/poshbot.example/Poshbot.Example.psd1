@{
    # Point to your module psm1 file...
    RootModule = 'PoshBot.Example.psm1'
    
    # Be sure to specify a version
    ModuleVersion = '0.0.1'
    
    Description = 'PoshBot module for a variety of commands'
    Author = 'Warren Frame'
    CompanyName = 'Community'
    Copyright = '(c) 2017 Warren Frame. All rights reserved.'
    PowerShellVersion = '5.0.0'
    
    # Generate your own GUID
    GUID = '3d0a33cd-bef0-4cf0-99e3-fff9aba222b8'
    
    # We require poshbot...
    RequiredModules = @('PoshBot')
    
    # Ideally, define these!
    FunctionsToExport = '*'
    
    PrivateData = @{
        # These are permissions we'll expose in our poshbot module
        Permissions = @(
            @{
                Name = 'read'
                Description = 'Run commands that query Acme systems'
            }
            @{
                Name = 'write'
                Description = 'Run commands that may write things to Acme systems'
            }
        )
    } # End of PrivateData hashtable
    }