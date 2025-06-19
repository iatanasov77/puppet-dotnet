class vs_dotnet::ms_sql::install (
    Hash $config    = {},
) {
    ##################################################################
    # Install MS Sql Server
    ##################################################################
    case $::operatingsystem {
        'RedHat', 'CentOS', 'OracleLinux', 'Fedora', 'AlmaLinux': {
            if Integer( $::operatingsystemmajrelease ) == 8 {
                $baseUrl        = "https://packages.microsoft.com/config/rhel/8/mssql-server-${config['version']}.repo"
                $prodRepoUrl    = "https://packages.microsoft.com/config/rhel/8/prod.repo"
            } else {
                fail( "Unsupported RHEL version '${::operatingsystemmajrelease}'" )
            }
        }
        
        default: { fail( "Unsupported OS '${::operatingsystem}'" ) }
    }
    
    exec { "Adding MS SQL Server Repo ${config['version']}":
        command     => "/usr/bin/curl ${baseUrl} -o /etc/yum.repos.d/mssql-server-${config['version']}.repo",
    } ->
    
    exec { "Adding MS Prod Repo":
        command     => "/usr/bin/curl ${prodRepoUrl} -o /etc/yum.repos.d/msprod.repo",
    } ->
    
    package { 'mssql-server':
        ensure  => present,
    } ->
    
    exec { 'Install mssql-tools':
        command     => 'dnf -y install mssql-tools',
        environment => ['ACCEPT_EULA=y'],
    } ->
    
    package { 'unixODBC-devel':
        ensure  => present,
    } ->
    
    file { '/etc/profile.d/append-mssql-tools-path.sh':
        mode    => '644',
        content => 'PATH=$PATH:/opt/mssql-tools/bin',
    } ->
    
    exec { 'Install DotNet-EF Tool':
        command => 'dotnet tool install --global dotnet-ef',
        user    => 'vagrant',
        environment => ['HOME=/home/vagrant'],
    }
    
    ##################################################################
    # Setup MS Sql Server
    ##################################################################
    exec { 'Setup MS Sql':
        command     => '/opt/mssql/bin/mssql-conf setup',
        require     => [ Exec['Install mssql-tools'] ],
        environment => ['ACCEPT_EULA=y','MSSQL_PID=Developer',"MSSQL_SA_PASSWORD=${config['rootPassword']}"],
    }
}