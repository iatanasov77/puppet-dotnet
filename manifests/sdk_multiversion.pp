#######################################################################################################################
# Install and use multiple dotnet sdk versions
# Tutorial: https://www.hanselman.com/blog/SideBySideUserScopedNETCoreInstallationsOnLinuxWithDotnetinstallsh.aspx
#######################################################################################################################
class dotnet::sdk_multiversion (
    String $sdkUser    = 'vagrant',
    Array $sdks         = [],
) {
    wget::fetch { 'Install dotnet-install.sh':
        source      => "https://dot.net/v1/dotnet-install.sh",
        destination => "/usr/share/dotnet/",
        timeout     => 0,
        verbose     => true,
        mode        => '0777',
        cache_dir   => '/var/cache/wget',
    } ->
    file { '/usr/local/bin/dotnet-install':
        ensure  => link,
        target  => '/usr/share/dotnet/dotnet-install.sh',
        mode    => '0777',
    }
        
    file_line { "DOTNET MULTIVERSION CONTAINER":
        ensure  => present,
        line    => "export PATH=/home/${sdkUser}/.dotnet:\$PATH",
        path    => "/home/${sdkUser}/.bash_profile",
    }
    
    $sdks.each |$version| {
        exec { "Installing DotNet SDK version ${version} ...":
            command     => "/usr/local/bin/dotnet-install --channel ${version}",
            environment => [ "HOME=/home/${sdkUser}" ],
            user        => $sdkUser,
            require     => File['/usr/local/bin/dotnet-install'],
        }
    }
}
