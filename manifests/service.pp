class dynamicroute53::service {
  if ! defined(Exec['systemd-daemon-reload']) {
    exec {'systemd-daemon-reload':
      command     => '/usr/bin/systemctl daemon-reload',
      refreshonly => true,
    }
  }

  file { '/usr/bin/update-dns-route53':
    ensure  => present,
    content => template('dynamicroute53/update-dns-route53.erb'),
    owner   => root,
    group   => root,
    mode    => '0754',
    notify  => Service['updatednsroute53']
  }

  file { '/usr/bin/delete-dns-route53':
    ensure  => present,
    content => template('dynamicroute53/delete-dns-route53.erb'),
    owner   => root,
    group   => root,
    mode    => '0754',
    notify  => Service['updatednsroute53']
  }

  file { '/etc/systemd/system/updatednsroute53.service':
    ensure  => present,
    source  => 'puppet:///modules/dynamicroute53/updatednsroute53.service',
    owner   => root,
    group   => root,
    mode    => '0754',
    require => [
      File['/usr/bin/update-dns-route53'],
      File['/usr/bin/delete-dns-route53']
    ],
    notify  => [
      Service['updatednsroute53'],
      Exec['systemd-daemon-reload'],
    ]
  }

  service { 'updatednsroute53':
    ensure  => running,
    require => File['/etc/systemd/system/updatednsroute53.service']
  }

}
