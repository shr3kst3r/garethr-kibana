class kibana::service {
  file { '/etc/init.d/kibana':
    ensure => link,
    target => '/lib/init/upstart-job',
  }

  file { '/etc/init/kibana.conf':
    ensure  => present,
    content => $operatingsystem ? {
      centos, redhat => template('kibana/etc/init/kibana-redhat.conf.erb'),
      debian, ubuntu => template('kibana/etc/init/kibana.conf.erb')
    }
  }

  case $operatingsystem {
    centos, redhat: {
      service { 'kibana':
        ensure     => running,
        hasstatus  => true,
        hasrestart => true,
        start      => '/sbin/initctl start kibana',
        stop       => '/sbin/initctl stop kibana',
        status     => '/sbin/initctl status kibana | grep "/running" 1>/dev/null 2>&1',
      }
    }
    debian, ubuntu: {
      service { 'kibana':
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        provider   => upstart,
        require    => [
          File['/etc/init.d/kibana'],
          File['/etc/init/kibana.conf'],
        ],
     }
  }

  File['/etc/init/kibana.conf'] ~> Service['kibana']
}
