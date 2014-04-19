class drush::git::drush (
  $git_branch = '',
  $git_tag    = '',
  $git_repo   = 'https://github.com/drush-ops/drush.git',
  $update     = false
  ) inherits drush::defaults {
  
  if $php_prefix == undef {
    $php_prefix = $::operatingsystem ? {
      /(?i:Ubuntu|Debian|Mint|SLES|OpenSuSE)/ => 'php5-',
      default                                 => 'php-',
    }
  }

  if !defined(Package["${php_prefix}cli"]) {
    package { "${php_prefix}cli": ensure => present }
  }

  drush::git { $git_repo :
    path       => '/usr/share',
    git_branch => $git_branch,
    git_tag    => $git_tag,
    update     => $update,
  }

  exec {'setup drush' :
    environment => ["COMPOSER_HOME=/root"],
    command     => '/usr/local/bin/composer install',
    cwd         => '/usr/share/drush',
    require     => [
      Class['composer'],
      Drush::Git[$git_repo],
    ],
    notify      => File['symlink drush'],
  }

  file {'symlink drush':
    ensure  => link,
    path    => '/usr/bin/drush',
    target  => '/usr/share/drush/drush',
    require => Exec['setup drush'],
    notify  => Exec['first drush run'],
  }

  # Needed to download a Pear library
  exec {'first drush run':
    command     => '/usr/bin/drush cache-clear drush',
    refreshonly => true,
    require     => [
      File['symlink drush'],
      Package["${php_prefix}cli"],
    ],
  }

}
