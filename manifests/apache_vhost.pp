class vs_dotnet::apache_vhost (
    String $hostName,
    String $documentRoot,
    Integer $reverseProxyPort   = 5000
) {
    apache::vhost { "${hostName}":
        port            => '80',
        serveradmin     => "webmaster@${hostName}",
        docroot         => "${documentRoot}", 
        override        => 'all',
        log_level       => 'debug',
        
        serveraliases   => [
            "www.${hostName}",
        ],
        
        directories     => [
            {
                path            => "${documentRoot}",
                allow_override  => ['All'],
                'Require'       => 'all granted',
            }
        ],
        
        custom_fragment => "
            ProxyPreserveHost On
            ProxyPass / http://127.0.0.1:${reverseProxyPort/
            ProxyPassReverse / http://127.0.0.1:${reverseProxyPort/
        ",
    }
}
