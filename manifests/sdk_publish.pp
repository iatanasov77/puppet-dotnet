#######################################################################################################################
# Build and publish dotnet sdk projects into /srv/... dir and create linux service and start it
# Tutorial: https://swimburger.net/blog/dotnet/how-to-run-aspnet-core-as-a-service-on-linux
#######################################################################################################################
define vs_dotnet::sdk_publish (
    String $application,
    String $projectName,
    String $projectPath,
    String $sdkUser             = 'vagrant',
    Integer $reverseProxyPort   = 5000
) {
    File { "Create DotNet Application Publish Path: ${projectPath}":
        ensure  => directory,
        path    => "/srv/${projectName}",
        mode    => "0777",
    } ->

    Exec { "Publish Dotnet Application: ${projectName}":
        command     => "dotnet publish -c Debug -o /srv/${projectName}/ --self-contained --runtime linux-x64", # && true
        path        => "/home/${sdkUser}/.dotnet/",
        cwd         => "${projectPath}",
        user        => "${sdkUser}",
        environment => [ 'DOTNET_CLI_HOME=/tmp' ],
        require     => Class['vs_dotnet::sdk_multiversion'],
    } ->
    
    File { "${projectName}.service":
        ensure  => file,
        path    => "/etc/systemd/system/${projectName}.service",
        content => template( 'vs_dotnet/project.service.erb' ),
        mode    => '0755',
        require     => Class['vs_dotnet'],
    } ->
    
    Service { "Start DotNet Application: ${projectName}":
        name    => "${projectName}",
        ensure  => 'running',
    }
}
