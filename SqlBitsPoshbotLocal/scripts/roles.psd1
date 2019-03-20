@{
  mis_admin = @{
    Description = ""
    Name = 'mis_admin'
    Permissions = @('demo.dbachatops:write','demo.dbachatops:read','poshbot.example:read')
  }
  Admin = @{
    Description = 'Bot administrator role'
    Name = 'Admin'
    Permissions = @('Builtin:show-help','Builtin:manage-schedules','Builtin:manage-permissions','Builtin:view-group','Builtin:manage-plugins','Builtin:manage-roles','Builtin:view','Builtin:view-role','Builtin:manage-groups')
  }
  readonly = @{
    Description = 'Readonly view of poshbot status'
    Name = 'readonly'
    Permissions = @('Builtin:view')
  }
}
