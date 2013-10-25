# == Class: logstash::web
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'logstash::web': }
#
#
class logstash::web (
  $ensure       = "present",
  $status       = "enabled",
  $bind_address = "0.0.0.0",
  $port         = 9292
) {

  #### Service management

  # set params: in operation
  if $ensure == 'present' {

    case $status {
      # make sure service is currently running, start it on boot
      'enabled': {
        $service_ensure = 'running'
        $service_enable = true
      }
      # make sure service is currently stopped, do not start it on boot
      'disabled': {
        $service_ensure = 'stopped'
        $service_enable = false
      }
      # make sure service is currently running, do not start it on boot
      'running': {
        $service_ensure = 'running'
        $service_enable = false
      }
      # do not start service on boot, do not care whether currently running or not
      'unmanaged': {
        $service_ensure = undef
        $service_enable = false
      }
      # unknown status
      # note: don't forget to update the parameter check in init.pp if you
      #       add a new or change an existing status.
      default: {
        fail("\"${status}\" is an unknown service status value")
      }
    }

  # set params: removal
  } else {

    # make sure the service is stopped and disabled (the removal itself will be
    # done by package.pp)
    $service_ensure = 'stopped'
    $service_enable = false

  }

  case $::operatingsystem {
    'RedHat', 'CentOS', 'Fedora', 'Scientific', 'Amazon': {
      $initscript = template("${module_name}/etc/init.d/logstash-web.init.RedHat.erb")
    }
    'Debian', 'Ubuntu': {
      $initscript = template("${module_name}/etc/init.d/logstash-web.init.Debian.erb")
    }
    default: {
      fail("\"${module_name}\" provides no default init file
      for \"{::operatingsystem}\"")
    }

  }

  # Place built in init file
  file { '/etc/init.d/logstash-web':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => $initscript,
    before  => Service[ 'logstash-web' ],
    notify  => Service[ 'logstash-web' ],
  }

  if ($status != 'unmanaged') {

    service { 'logstash-web':
      ensure => $service_ensure,
      enable => $service_enable
    }

  }

}
