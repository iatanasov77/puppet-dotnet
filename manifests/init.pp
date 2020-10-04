class vs_dotnet (
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
    
    class { '::vs_dotnet::sdk':
        yumrepo_defaults    => $yumrepo_defaults,
        sdk_version         => $sdkVersion
    }
    
    -> class { '::vs_dotnet::sdk_multiversion':
        sdkUser => $sdkUser,
        sdks    => [$sdkVersion] + $sdks,
    }
    
    if $mono {
        class { '::vs_dotnet::mono':
            yumrepo_defaults  => $yumrepo_defaults,
        }
    }
}