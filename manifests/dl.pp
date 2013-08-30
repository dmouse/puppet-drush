define drush::dl (
  $type       = 'module',
  $site_alias = $drush::defaults::site_alias,
  $options    = $drush::defaults::options,
  $arguments  = $drush::defaults::arguments,
  $drush_user = $drush::defaults::drush_user,
  $drush_home = $drush::defaults::drush_home,
  $log        = $drush::defaults::log
  ) {

  if $arguments { $real_args = $arguments }
  else { $real_args = "${name}" }

  # Always download drush extensions without a site alias.
  if $type == 'extension' { $real_alias = '@none' }
  else { $real_alias = "${site_alias}" }

  drush::run {"drush-dl:${name}":
    command    => 'pm-download',
    site_alias => $real_alias,
    options    => $options,
    arguments  => $real_args,
    drush_user => $drush_user,
    drush_home => $drush_home,
    log        => $log,
  }

  # Add an 'unless' argument depending on the project type.
  case $type {
    'module', 'theme': {
      Drush::Run["drush-dl:${name}"] {
        unless => "drush ${site_alias} pm-list | grep ${name}",
      }
    }
    'extension': {
      Drush::Run["drush-dl:${name}"] {
        unless => "[ -d '${drush_home}/.drush/${name}' ]",
      }
    }
  }

  if defined(Drush::Run["drush-en:${name}"]) {
    Drush::Run["drush-dl:${name}"] {
      before +> Exec["drush-en:${name}"],
    }
  }
}

