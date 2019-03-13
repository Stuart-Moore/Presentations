@{
    # Point to your module psm1 file...
    RootModule = 'demo.dbachatops.psm1'

    # Be sure to specify a version
    ModuleVersion = '0.0.1'

    Description = 'Examples of poshbot interactivity'
    Author = 'Stuart Moore'
    CompanyName = 'Community'
    Copyright = '(c) 2018.'
    PowerShellVersion = '5.0.0'

    # Generate your own GUID
    GUID = '3d0a33cd-bef0-4cf0-99e3-fff9aba222c3'

    # We require poshbot...
    RequiredModules = @('PoshBot','dbatools')

    # Ideally, define these!
    FunctionsToExport = '*'

    PrivateData = @{
        # These are permissions we'll expose in our poshbot module
        Permissions = @(
            @{
                Name = 'read'
                Description = 'Run commands that query SQL instances'
            }
            @{
                Name = 'write'
                Description = 'Run commands that may write things to SQL instances'
            }
        )
    } # End of PrivateData hashtable
    }