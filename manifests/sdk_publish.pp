#######################################################################################################################
# Build and publish dotnet sdk projects into /srv/... dir and create linux service and start it
# Tutorial: https://swimburger.net/blog/dotnet/how-to-run-aspnet-core-as-a-service-on-linux
#######################################################################################################################
define vs_dotnet::sdk_publish (
    String $application,
    String $description     = 'ASP.NET Core web template',
    String $projectName,
    String $projectPath,
    String $sdkUser         = 'vagrant',
    String $aspnetCoreUrls
) {
    File { "Create DotNet Application Publish Path: ${projectPath}":
        ensure  => directory,
        path    => "/srv/${projectName}",
        owner   => "${sdkUser}",
        require => Class['vs_dotnet::sdk_multiversion'],
    } ->

    Exec { "Publish Dotnet Application: ${projectName}":
        command     => "dotnet publish -c Debug -o /srv/${projectName}/",
        path        => "/home/${sdkUser}/.dotnet/",
        cwd         => "${projectPath}",
        timeout     => 0,
        user        => "${sdkUser}",
        environment => ["HOME=/home/${sdkUser}"],
    } ->
    
    File { "${projectName}${application}.service":
        ensure  => file,
        path    => "/etc/systemd/system/${projectName}${application}.service",
        content => template( 'vs_dotnet/project.service.erb' ),
        mode    => '0644',
    } ->
    
    Service { "Start DotNet Application: ${projectName}":
        name    => "${projectName}",
        ensure  => 'running',
        enable  => true,
    }
}
