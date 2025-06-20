define vs_dotnet::ms_sql::database (
    String $rootPassword,
    String $dbName,
    String $backupFile,
) {
    exec { "MsSql Database Backup for ${dbName}":
        command => "/usr/bin/cp ${backupFile} /var/DotNetBackup/${dbName}.bac",
        user    => 'vagrant',
        require => [ File['dotnet_backup_path'], Class['vs_dotnet::ms_sql::install'] ],
    } ->
    
    exec { "Restore MsSql Database ${dbName}":
        command     => "sqlcmd -S localhost -U SA -P '${rootPassword}' -Q \"RESTORE DATABASE [${dbName}] FROM DISK='/var/DotNetBackup/${dbName}.bac'\"",
        path        => '/opt/mssql-tools/bin',
        logoutput   => true,
        timeout     => 0,
        user        => 'vagrant',
        environment => ['HOME=/home/vagrant'],
        require     => [ File['dotnet_backup_path'], Class['vs_dotnet::ms_sql::install'] ],
    }
}