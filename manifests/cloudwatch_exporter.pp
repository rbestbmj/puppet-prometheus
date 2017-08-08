class prometheus::cloudwatch_exporter (
  $arch                 = $::prometheus::params::arch,
  $bin_dir              = $::prometheus::params::bin_dir,
  $config_content       = $::prometheus::params::cloudwatch_exporter_config_content,
  $download_extension   = $::prometheus::params::cloudwatch_exporter_download_extension,
  $download_url         = undef,
  $download_url_base    = $::prometheus::params::cloudwatch_exporter_download_url_base,
  $extra_groups         = $::prometheus::params::cloudwatch_exporter_extra_groups,
  $group                = $::prometheus::params::cloudwatch_exporter_group,
  $init_style           = $::prometheus::params::init_style,
  $install_method       = $::prometheus::params::install_method,
  $manage_group         = true,
  $manage_service       = true,
  $manage_user          = true,
  $os                   = $::prometheus::params::os,
  $package_ensure       = $::prometheus::params::cloudwatch_exporter_package_ensure,
  $package_name         = $::prometheus::params::cloudwatch_exporter_package_name,
  $port                 = $::prometheus::params::cloudwatch_exporter_port,
  $purge_config_dir     = true,
  $restart_on_change    = true,
  $service_enable       = true,
  $service_ensure       = 'running',
  $service_name         = 'cloudwatch_exporter',
  $user                 = $::prometheus::params::cloudwatch_exporter_user,
  $version              = $::prometheus::params::cloudwatch_exporter_version,
) inherits prometheus::params {

  $real_download_url   = pick($download_url,"${download_url_base}/${version}/${package_name}-${version}-jar-with-dependencies.${download_extension}")

  validate_bool($purge_config_dir)
  validate_bool($manage_user)
  validate_bool($manage_service)
  validate_bool($restart_on_change)
  validate_hash($config_content)

  $notify_service = $restart_on_change ? {
    true    => Service[$service_name],
    default => undef,
  }

  $options = "${port} /etc/cloudwatch_exporter/cloudwatch.yml"

  file { "/etc/cloudwatch_exporter":
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  } ->
  file { "/etc/cloudwatch_exporter/cloudwatch.yml":
    ensure  => file,
    content => template('prometheus/cloudwatch.yml.erb'),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }

  prometheus::daemon { 'cloudwatch_exporter':
    install_method     => $install_method,
    version            => $version,
    download_extension => $download_extension,
    os                 => $os,
    arch               => $arch,
    real_download_url  => $real_download_url,
    bin_dir            => $bin_dir,
    notify_service     => $notify_service,
    package_name       => $package_name,
    package_ensure     => $package_ensure,
    manage_user        => $manage_user,
    user               => $user,
    extra_groups       => $extra_groups,
    group              => $group,
    manage_group       => $manage_group,
    purge              => $purge_config_dir,
    options            => $options,
    init_style         => $init_style,
    service_ensure     => $service_ensure,
    service_enable     => $service_enable,
    manage_service     => $manage_service,
    type               => 'java',
  }

}