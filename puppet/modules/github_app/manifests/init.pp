class laravel_app 
{

	package { 'git-core':
    	ensure => present,
    }

   	exec { 'install composer':
	    command => 'curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin',
	    require => Package['php5-cli'],
	    unless => "[ -f /usr/local/bin/composer ]"
	}

	exec { 'global composer':
		command => "sudo mv /usr/local/bin/composer.phar /usr/local/bin/composer",
		require => Exec['install composer'],
		unless => "[ -f /usr/local/bin/composer ]"
	}

	# Needed as the first time you SSH anywhere, you're asked to trust the connection
	# Puppet will freak out when it sees that message
	# This pre-emtively auths a request to the github.com host
	exec { 'allow github ssh key':
		command => "touch ~/.ssh/known_hosts && ssh-keyscan -H github.com >> ~/.ssh/known_hosts &> /dev/null"
	}

	# Check to see if there's a composer.json and app directory before we delete everything
	# We need to clean the directory in case a .DS_STORE file or other junk pops up before
	# the composer create-project is called
	exec { 'clean www directory': 
		command => "/bin/sh -c 'cd /var/www && find -mindepth 1 -delete'",
		unless => [ "test -f /var/www/composer.json", "test -d /var/www/app" ],
		require => Package['apache2']
	}

	# Clones down your app from github
	# Edit the commands to add your github urls/directory names
	exec { 'install app':
		cwd => "/var/www",
		command => "git clone YOUR_APP_GIT_URL_HERE",
		require => [Exec['global composer'], Package['git-core'], Exec['clean www directory'], Exec['allow github ssh key']],
		creates => "/var/www/YOUR_APP_DIRECTORY_HERE/composer.json",
		timeout => 1800,
	}

	exec { 'install packages':
        command => "/bin/sh -c 'cd /var/www/YOUR_APP_DIRECTORY_HERE && composer install'",
        require => [Package['git-core'], Package['php5'], Exec['global composer'], Exec['install app']],
        onlyif => [ "test -f /var/www/composer.json" ],
        creates => "/var/www/vendor/autoload.php",
        timeout => 900,
	}

	file { '/var/www/app/storage':
		mode => 0777
	}
}
