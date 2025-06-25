define vs_dotnet::apache_vhost (
    String $hostName,
    String $documentRoot,
    Integer $reverseProxyPort   = 5000,
    Boolean $ssl                = false,
    String $sslHost             = 'myprojects.lh',
) {
    apache::vhost { "${hostName}":
        servername      => "${hostName}",
        serveraliases   => [
            "www.${hostName}",
        ],
        
        port            => 80,
        serveradmin     => "webmaster@${hostName}",
        docroot         => "${documentRoot}", 
        override        => ['All'],
        log_level       => 'debug',
        
        directories     => [
            {
                path            => "${documentRoot}",
                allow_override  => ['All'],
                'Require'       => 'all granted',
            }
        ],
        
        custom_fragment => vs_devenv::apache_vhost_reverse_proxy( $reverseProxyPort ),
    }
}

