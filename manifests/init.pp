class dotnet (
    $sdkVersion     = '3.1',
    String $sdkUser = 'vagrant',
    Array $sdks     = [],
    Boolean $mono   = false,
) {
    ######################################################
    # Docs:
    # -----
    # https://www.mono-project.com/docs/web/fastcgi/
    # https://github.com/dotnet/efcore
    #
    # EntityFramework: https://github.com/dotnet/efcore
    ######################################################
    
    if ! defined(Package['yum-plugin-priorities']) {
        package { 'yum-plugin-priorities':
            ensure => 'present',
        }
    }
    
    $yumrepo_defaults = {
        'ensure'   => 'present',
        'enabled'  => true,
        'gpgcheck' => true,
        'priority' => 50,
        'require'  => [ Package['yum-plugin-priorities'] ],
    }
    
    class { '::dotnet::sdk':
        yumrepo_defaults    => $yumrepo_defaults,
        sdk_version         => $sdkVersion
    }
    
    -> class { '::dotnet::sdk_multiversion':
        sdkUser => $sdkUser,
        sdks    => [$sdkVersion] + $sdks,
    }
    
    if $mono {
        class { '::dotnet::mono':
            yumrepo_defaults  => $yumrepo_defaults,
        }
    }
}