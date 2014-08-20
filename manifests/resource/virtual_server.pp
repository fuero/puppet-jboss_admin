# == Defines jboss_admin::virtual_server
#
# A virtual host.
#
# === Parameters
#
# [*alias*]
#   The virtual server aliases
#
# [*default_web_module*]
#   The web module deployment name that will be mapped as the root webapp.
#
# [*enable_welcome_root*]
#   Whether or not the bundled welcome directory is used as the root web context.
#
# [*resource_name*]
#   A unique virtual host name
#
#
define jboss_admin::resource::virtual_server (
  $server,
  $alias                          = undef,
  $default_web_module             = undef,
  $enable_welcome_root            = undef,
  $resource_name                  = undef,
  $ensure                         = present,
  $path                           = $name
) {
  if $ensure == present {

  

    $raw_options = { 
      'alias'                        => $alias,
      'default-web-module'           => $default_web_module,
      'enable-welcome-root'          => $enable_welcome_root,
      'name'                         => $resource_name,
    }
    $options = delete_undef_values($raw_options)

    jboss_resource { $path:
      ensure  => $ensure,
      server  => $server,
      options => $options
    }


  }

  if $ensure == absent {
    jboss_resource { $path:
      ensure => $ensure,
      server => $server
    }
  }


}