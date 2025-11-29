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
    case $facts['os']['name'] {
        'RedHat', 'CentOS', 'OracleLinux', 'Fedora', 'AlmaLinux': {
            if Integer( $facts['os']['release']['major'] ) == 7 {
                $baseUrl    = 'https://packages.microsoft.com/yumrepos/microsoft-rhel7.9-prod'
            } elsif Integer( $facts['os']['release']['major'] ) == 8 {
                $baseUrl    = 'https://packages.microsoft.com/yumrepos/microsoft-rhel8.2-prod'
            } else {
                fail( "Unsupported RHEL version '${facts['os']['release']['major']}'" )
            }
        }
        
        default: { fail( "Unsupported OS '${facts['os']['name']}'" ) }
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
    } ->
    exec { "Trust HTTPS development certificate for Root User":
        command     => 'dotnet dev-certs https --trust',
        environment => "HOME=${facts['root_home']}",
    } ->
    exec { "Trust HTTPS development certificate for Vagrant User":
        command     => 'dotnet dev-certs https --trust',
        user        => 'vagrant',
        environment => ['HOME=/home/vagrant'],
    }
}