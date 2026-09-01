require 'fileutils'

# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir/latest/
module XDGSpec
  extend self
  
  def config_dir
    ENV['XDG_CONFIG_HOME'] || File.join(Dir.home, '.config')
  end

  # not part of the XDG Spec but helpful
  def local_bin
    File.join(Dir.home, '.local', 'bin')
  end
  
  def data_dir
    ENV['XDG_DATA_HOME'] || File.join(Dir.home, '.local', 'share')
  end

  def state_dir
    ENV['XDG_STATE_HOME'] || File.join(Dir.home, '.local', 'state')
  end
  
  def cache_dir
    ENV['XDG_CACHE_HOME'] || File.join(Dir.home, '.cache')
  end

  def ensure_dir!(path)
    FileUtils.mkdir_p(path) unless Dir.exist?(path)
    path
  end
end
