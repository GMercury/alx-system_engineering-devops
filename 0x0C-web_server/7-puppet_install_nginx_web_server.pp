# Install & configure NGINX on a new Ubuntu 16.04 server

$default_conf_match = '^\s*root\s+/var/www/html;\s*$'
$default_conf_line = "\
	root /var/www/html;
	rewrite ^/redirect_me https://www.youtube.com/watch?v=QH2-TGUlwu4 permanent;
	error_page 404 /custom_404.html;
	location = /custom_404.html {
		root /usr/share/nginx/html;
		internal;
	}
"

$index_html = "\
<html>
  <head>
    <title>Holberton School</title>
  </head>
  <body>
    <p>Holberton School for the win!</p>
  </body>
</html>
"

$custom_404 = "\
<html>
  <head>
    <title>Page Not Found</title>
  </head>
  <body>
    <p>Ceci n'est pas une page</p>
  </body>
</html>
"

exec { 'apt update':
  path => '/usr/sbin:/usr/bin:/sbin:/bin',
}

package { 'nginx':
  require => Exec['apt update'],
}

service { 'nginx':
  ensure     => 'running',
  enable     => true,
  hasrestart => true,
}

file_line { 'default_conf':
  path    => '/etc/nginx/sites-available/default',
  line    => $default_conf_line,
  match   => $default_conf_match,
  require => Package['nginx'],
  notify  => Service['nginx'],
}

file { '/var/www/html/index.html':
  ensure  => present,
  replace => 'no',
  content => $index_html,
  require => Package['nginx'],
}

file { '/usr/share/nginx/html/custom_404.html':
  ensure  => present,
  replace => 'no',
  content => $custom_404_html,
  require => Package['nginx'],
}

exec { "ufw allow 'Nginx HTTP'":
  path    => '/usr/sbin:/usr/bin:/sbin:/bin',
  require => Package['nginx'],
}
