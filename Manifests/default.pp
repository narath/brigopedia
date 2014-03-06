# Puppet Voxeo manifest
$mediawiki_package = "mediawiki-1.22.2.tar.gz"
$mediawiki_path = "http://download.wikimedia.org/mediawiki/1.22"
$ldapAuthentication_extension_url = "https://codeload.github.com/wikimedia/mediawiki-extensions-LdapAuthentication/legacy.tar.gz/REL1_22"
$dependencies = ["httpd", "php", "php-mysql", "php-gd", "php-xml", "php-ldap", "mysql", "git", "php-pear-Mail"]
# $dependencies = ["httpd", "php", "php-mysql", "php-gd", "php-xml", "php-ldap", "mysql", "mysql-server", "git", "php-pear-Mail"]

Exec {
path => [
  '/usr/local/bin',
  '/opt/local/bin',
  '/usr/bin', 
  '/usr/sbin', 
  '/bin',
  '/sbin'],
  logoutput => true
}

class update {
  exec { 'yum update':
    command => 'yum -y update'
  }
}

class enable-ssh {
    package { 'openssh-server':
        ensure => installed,
        notify  => Service['sshd'], 
    }
    service { 'sshd':
        ensure => running,
        enable => true,
        hasstatus => true,
        hasrestart => true,
    }
}

class install-mediawiki {
  package { $dependencies: 
    ensure => "installed",
  }
  ->
  exec { 'download mediawiki':
     command => "wget -P /tmp/ '${mediawiki_path}/${mediawiki_package}'",
     creates => "/tmp/${mediawiki_package}",
  }
  ->
  # exec { 'Copy mediawiki to /tmp folder.':
  #   command => "cp /vagrant/artifacts/${mediawiki_package} /tmp"
  # }
  # ->
  file { "/tmp/${mediawiki_package}":
    source  => "/tmp/${mediawiki_package}",
    owner   => 'root',
    group   => 'root',
    mode    => '740',
  }
  ->
  file { "/opt/mediawiki":
      ensure => "directory",
      owner  => "apache",
      group  => "apache",
      mode   => 755,
  }
  ->
  exec { 'Unpack mediawiki':
     command => "tar xfz /tmp/${mediawiki_package} -C /opt/mediawiki",
     creates => '/home/mediawiki/mediawiki-1.22.2/COPYING',
     timeout => 0,
  }
  ->
  exec { 'Chown mediawiki':
     command => "chown -R apache:apache /opt/mediawiki/mediawiki-1.22.2",
     timeout => 0,
  }
  ->
  file { "/var/www":
      ensure => "directory",
      owner  => "root",
      group  => "root",
      mode   => 755,
  }
  ->
  file { '/var/www/mediawiki':
     ensure => 'link',
     target => '/opt/mediawiki/mediawiki-1.22.2',
  }
  ->
  exec { 'Chown apache':
     command => "chown -R apache:apache /var/www/mediawiki",
     timeout => 0,
  }
  ->
  file { "/tmp/brigopedia-config":
      ensure => "directory",
      owner  => "apache",
      group  => "apache",
      mode   => 755,
  }
  ->
  exec { 'Clone brigopedia-config repo.':
    command => "git clone https://github.com/stephenlorenz/brigopedia-config.git /tmp/brigopedia-config"
  }
  ->
  exec { 'Make backup of original httpd.conf.':
    command => "cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.orig"
  }
  ->
  exec { 'Copy mediawiki httpd.conf to /etc/httpd/conf folder.':
    command => "cp /tmp/brigopedia-config/httpd.conf /etc/httpd/conf"
  }
  ->
  exec { 'Add brigopedia to /etc/hosts.':
    command => "grep -q 'brigopedia' /etc/hosts || echo '127.0.0.1         brigopedia.partners.org' >> /etc/hosts"
  }
  ->
  service { "httpd":
    ensure => "running",
    enable => true,
  }
  ->
  exec { 'download mediawiki ldapAuthentication extension':
     command => "wget -P /tmp/ '${ldapAuthentication_extension_url}'",
     creates => "/tmp/wikimedia-mediawiki-extensions-LdapAuthentication-2.0c-31-g300d43f.tar.gz",
  }
  ->
    exec { 'Unpack mediawiki ldapAuthentication extension':
     command => "tar -xzf /tmp/brigopedia-config/wikimedia-mediawiki-extensions-LdapAuthentication-2.0c-31-g300d43f.tgz -C /opt/mediawiki/mediawiki-1.22.2/extensions",
     timeout => 0,
  }
  ->
  exec { 'Rename ldapAuthentication':
     command => "mv /opt/mediawiki/mediawiki-1.22.2/extensions/wikimedia-mediawiki-extensions-LdapAuthentication-300d43f /opt/mediawiki/mediawiki-1.22.2/extensions/LdapAuthentication",
     timeout => 0,
  }
  ->
  exec { 'Chown mediawiki2':
     command => "chown -R apache:apache /opt/mediawiki/mediawiki-1.22.2",
     timeout => 0,
  }
  ->
  exec { 'Enable Mediawiki to connect to remote database':
     command => "setsebool -P httpd_can_network_connect_db 1",
     timeout => 0,
  }
  ->
  exec { 'Enable Mediawiki to connect to remote smtp service':
     command => "setsebool -P httpd_can_network_connect 1",
     timeout => 0,
  }
  # ->
  # exec { 'Run mediawiki update script to create ldapAuthentication extension database tables':
  #    command => "/usr/bin/php /opt/mediawiki/mediawiki-1.22.2/maintenance/update.php --quick",
  #    timeout => 0,
  # }

}

# firewall { "009000 Http(s) Ports":
#   proto => "tcp",
#   port => [80, 443],
#   action => "accept",
# }

include enable-ssh
include install-mediawiki