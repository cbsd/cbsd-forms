class { 'loginconf': }
class { 'nginx': }
class { 'php': }

$packages = [ "security/ca_root_nss", "ftp/wget" ]

package { $packages:
	ensure => "latest",
}

class { '::mysql::server':
	root_password           => '#mysql_server_root_password#',
	remove_default_accounts => true,
	override_options        => $override_options
}

file { ['/tmp/mysql.sock' ]:
	ensure => link,
	target => "/var/db/mysql/mysql.sock",
}

class { 'wordpress': }
