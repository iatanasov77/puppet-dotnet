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
    yumrepo { 'packages-microsoft-com-prod': 
        name        => 'packages-microsoft-com-prod',
        descr       => "Mictosoft dotNet Repo for RHEL7",
        baseurl     => 'https://packages.microsoft.com/yumrepos/microsoft-rhel7.3-prod',
        gpgkey      => 'https://packages.microsoft.com/keys/microsoft.asc',
        *           => $yumrepo_defaults,
    } ->
    
    package { "dotnet-sdk-${sdk_version}":
        ensure  => present,
        require => [ Package['libunwind'], Package['libicu']],
    }
}