require 'pathname'

task default: 'docker:build'

namespace :docker do
  image_name = 'feduxorg/centos-postgresql'
  container_name = 'centos-postgresql1'

  desc 'Build docker image'
  task :build, :nocache do |_, args|
    nocache = args[:nocache]
    proxy = '172.17.0.1'
    docker_file = 'files/latest/Dockerfile'

    cmdline = []
    cmdline << 'docker'
    cmdline << 'build'
    cmdline << '--no-cache=true' if nocache
    cmdline << "--build-arg http_proxy=http://#{proxy}:3128" if ENV.key? 'http_proxy'
    cmdline << "--build-arg https_proxy=https://#{proxy}:3128" if ENV.key? 'https_proxy'
    cmdline << "--build-arg HTTP_PROXY=http://#{proxy}:3128" if ENV.key? 'HTTP_PROXY'
    cmdline << "--build-arg HTTPS_PROXY=https://#{proxy}:3128" if ENV.key? 'HTTPS_PROXY'
    cmdline << "-t #{image_name}"

    Dir.glob(File.expand_path('files/**/*')).each do |p|
      local = cmdline.dup

      local << " -t #{image_name}:#{File.basename(File.dirname(p))} "
      local << "-f #{docker_file}"
      local << File.dirname(docker_file)

      sh local.join(' ')
    end
  end

  desc 'Run docker container'
  task :run, :command do |_, task_args|
    command = task_args[:command]

    cwd = Pathname.new(Dir.getwd)
    tmp_dir = cwd + Pathname.new('tmp')
    data_dir = tmp_dir + Pathname.new('data')
    FileUtils.mkdir_p data_dir

    args =[]
    args << '-it'
    args << '--rm'
    args << "--name #{container_name}"
    args << "-v /sys/fs/cgroup:/sys/fs/cgroup"
    args << "-v #{data_dir}:/srv/db"

    cmdline = []
    cmdline << 'docker'
    cmdline << 'run'
    cmdline.concat args
    cmdline << image_name
    cmdline << command if command

    sh cmdline.join(' ')
  end
end

task :clean do
  sh 'sudo rm -rf tmp/*'
end
