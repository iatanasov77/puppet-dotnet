#######################################################################################################################
# Build and publish dotnet sdk projects into /srv/... dir and create linux service and start it
# Tutorial: https://swimburger.net/blog/dotnet/how-to-run-aspnet-core-as-a-service-on-linux
#######################################################################################################################
define vs_dotnet::sdk_publish (
    String $projectName,
    String $projectPath,
    String $sdkUser             = 'vagrant',
    Integer $reverseProxyPort   = 5000
) {

    Exec { "Dotnet SDK Publish ${projectPath}":
        command     => "dotnet publish -c Debug -o /srv/${projectName}/ --self-contained --runtime linux-x64",
        path        => "/home/${sdkUser}/.dotnet/",
        cwd         => "${projectPath}",
        user        => "${sdkUser}",
        require     => Class['vs_dotnet'],
    }
    
    File { "${projectName}.service":
        ensure  => file,
        path    => "/etc/systemd/system/",
        content => template( 'vs_dotnet/project.service.erb' ),
        mode    => '0755',
        require     => Class['vs_dotnet'],
    }
}
