class vs_dotnet::mono (
    $yumrepo_defaults
) {
    case $::operatingsystem {
        'RedHat', 'CentOS', 'OracleLinux', 'Fedora', 'AlmaLinux': {
            if Integer( $::operatingsystemmajrelease ) == 7 {
                $baseUrl    = 'https://download.mono-project.com/repo/centos7-stable/'
            } elsif Integer( $::operatingsystemmajrelease ) == 8 {
                $baseUrl    = 'https://download.mono-project.com/repo/centos8-stable/'
            } else {
                fail( "Unsupported RHEL version '${::operatingsystemmajrelease}'" )
            }
        }
        
        default: { fail( "Unsupported OS '${::operatingsystem}'" ) }
    }
    
    yumrepo { 'mono-stable': 
        name        => 'mono-stable',
        descr       => "MonoProject Repo for RHEL",
        baseurl     => $baseUrl,
        gpgkey      => 'https://download.mono-project.com/repo/xamarin.gpg',
        *           => $yumrepo_defaults,
    } ->
    
    package { 'mono-complete':
        ensure  => present
    } ->
    
    # https://www.mono-project.com/docs/web/mod_mono/
    if Integer( $::operatingsystemmajrelease ) == 7 {
        package { 'mod_mono':
            ensure  => present
        }
    } else {
        package { 'xsp':
            ensure  => present
        } ->
        package { 'mod_mono':
            ensure  => present
        }
    }
    
    file { '/etc/httpd/conf.modules.d/mono.load':
        mode    => '644',
        content => 'LoadModule mono_module /etc/httpd/modules/mod_mono.so',
        require     => [ Package['mod_mono'] ],
    }
}