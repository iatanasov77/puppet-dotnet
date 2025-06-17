class vs_dotnet::sdk (
    $yumrepo_defaults,
    $sdk_version
) {
    #####################################
    # Dependencies
    #####################################
    if ! defined(Package['libunwind']) {
        package { 'libunwind':
            ensure => present,
        }
    }
    
    if ! defined(Package['libicu']) {
        package { 'libicu':
            ensure => present,
        }
    }
    
    #####################################
    # Install DotNet Core
    #####################################
    case $::operatingsystem {
        'RedHat', 'CentOS', 'OracleLinux', 'Fedora', 'AlmaLinux': {
            if Integer( $::operatingsystemmajrelease ) == 7 {
                $baseUrl    = 'https://packages.microsoft.com/yumrepos/microsoft-rhel7.9-prod'
            } elsif Integer( $::operatingsystemmajrelease ) == 8 {
                $baseUrl    = 'https://packages.microsoft.com/yumrepos/microsoft-rhel8.2-prod'
            } else {
                fail( "Unsupported RHEL version '${::operatingsystemmajrelease}'" )
            }
        }
        
        default: { fail( "Unsupported OS '${::operatingsystem}'" ) }
    }
    
    yumrepo { 'packages-microsoft-com-prod': 
        name        => 'packages-microsoft-com-prod',
        descr       => "Mictosoft dotNet Repo for RHEL",
        baseurl     => $baseUrl,
        gpgkey      => 'https://packages.microsoft.com/keys/microsoft.asc',
        *           => $yumrepo_defaults,
    } ->
    
    package { "dotnet-sdk-${sdk_version}":
        ensure  => present,
        require => [ Package['libunwind'], Package['libicu']],
    }
}