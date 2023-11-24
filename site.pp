# site.pp

# Install required packages
package { ['vim', 'curl', 'git']:
  ensure => 'installed',
}

# Create user 'monitor'
user { 'monitor':
  ensure     => 'present',
  home       => '/home/monitor',
  managehome => true,
  shell      => '/bin/bash',
}

# Create directory /home/monitor/scripts
file { '/home/monitor/scripts/':
  ensure  => 'directory',
  owner   => 'monitor',
  group   => 'monitor',
  mode    => '0755',
  recurse => true,
}

# Download memory check script from GitHub
exec { 'download_memory_check_script':
  command => 'wget -O /home/monitor/scripts/memory_check https://raw.githubusercontent.com/KMLori21/SEO-Exercise1-2/main/memory_check.sh',
  creates => '/home/monitor/scripts/memory_check',
  require => File['/home/monitor/scripts/'],
}
#https://raw.githubusercontent.com/KMLori21/SEO-Exercise1-2/main/memory_check.sh

# Create directory /home/monitor/src
file { '/home/monitor/src/':
  ensure  => 'directory',
  owner   => 'monitor',
  group   => 'monitor',
  mode    => '0755',
  recurse => true,
}

# Create soft link named my_memory_check
file { '/home/monitor/src/my_memory_check':
  ensure => 'link',
  target => '/home/monitor/scripts/memory_check',
  owner  => 'monitor',
  group  => 'monitor',
}

# Create crontab entry to run my_memory_check every 10 minutes
cron { 'run_memory_check':
  command => '/home/monitor/src/my_memory_check',
  user    => 'monitor',
  minute  => '*/10',
}

# Bonus tasks

# Set time zone to PHT
class { 'timezone':
  timezone => 'Asia/Manila',
}

# Set hostname to bpx.server.local
class { 'hostname':
  hostname => 'bpx.server.local',
}
