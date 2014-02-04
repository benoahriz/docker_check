#!/usr/bin/ruby
SCRIPT_VERSION="Version 0.01"
AUTHOR="Benjamin Rizkowsky (ben@thebrainvault.org) 02/03/2014"
URL="https://github.com/benoahriz/docker_check"
################################################################################
# Nagios plugin to monitor the status of docker on the local machine
# Author: Benjamin Rizkowsky (http://thebrainvault.org/)
################################################################################
require 'open3'
require 'optparse'
require 'logger'

def logger
  @logger ||= Logger.new(STDOUT)
end
logger.progname = 'DOCKER CHECK'
logger.level = Logger::WARN

options = {}
opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: docker_check.rb [OPTIONS]"
  opt.separator  ""
  opt.separator  "Commands"
  opt.separator  "check"
  opt.separator  ""
  opt.separator  "Options"
#  Saved these options in case we need them later.
#  opt.on("-t","--timeout","timeout") do
#    puts "timout"
#  end
#  opt.on("-c","--critical","critical") do
#    puts "critical threshold"
#  end
#  opt.on("-H","--hostname","hostname") do
#    puts "hostname option"
#  end
  opt.on("-v","--verbose","verbose") do
    logger.level = Logger::DEBUG
    puts "Debug is now on!"
  end
  opt.on("-V","--version","version") do
   puts AUTHOR
   puts SCRIPT_VERSION
  end
  opt.on("-h","--help","help") do
    puts opt_parser
  end
end
opt_parser.parse!

#moved this check case to the bottom.
#case ARGV[0]
#when "check"
#  logger.debug "Running check methods"
#  nagios_check
#else
#  puts opt_parser
#end

#'which' method borrowed from https://github.com/github/hub/blob/master/lib/hub/context.rb
#looks for executable files in the path that match the argument
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each { |ext|
      exe = "#{path}/#{cmd}#{ext}"
      return exe if File.executable? exe
      }
    end
return nil
end
#'command' method borrowed from https://github.com/github/hub/blob/master/lib/hub/context.rb
# depends on the above which method
def command?(name)
  !which(name).nil?
end
#Just a couple of tests.
#logger.debug "The docker command reports it exists and value is = #{command?('docker')}"
#logger.debug "The which method found the path #{which('docker')}"

#Method to check to see if Docker is running and then provide the correct exit code for Nagios.
def docker_is_running()
#PID file location
pidfile="/var/run/docker.pid"
if command?('docker')
  logger.debug "Docker command exists in the path. Hurray!"
    if File.exists?(pidfile)
      dockerpid = File.read(pidfile).to_i
      logger.debug "Sweet I found the docker process #{dockerpid}"
        if Process::kill 0, dockerpid
           logger.debug "The docker process is responding to kill 0. It appears things are running."
           return 0
        else
         logger.warn "Warning! PID file exists but I can't send that PID a signal"
         return 1
        end
      else
      logger.error "Error! Docker exists in the path but I couldnt find a PID file."
      return 2
    end
else
  logger.error "Error! Docker wasnt found. Sorry. Maybe its not installed?"
  return 2
end
end
=begin
Terrible parser of the 'docker info' command.  Attempted to sanitize output somewhat for a single line of output for nagios performance data
todo:  Use the api instead to gather this information.  Or if available xml or json output.
todo:  add debug
todo:  store values to array with keypairs.
Using the docker vagrant machine from the tutorial I got different output than what is contained in the documentation.
http://docs.docker.io/en/latest/commandline/cli/#info
This method should deal with the difference by just not showing the other data.  A class and api for output or xml or json output would be much more desirable.
Example output from local docker.
--------------
Containers: 1
Images: 4
Driver: aufs
 Root Dir: /var/lib/docker/aufs
 Dirs: 6
-------------
Example from documentation on the website.
------------
$ sudo docker info
Containers: 292
Images: 194
Debug mode (server): false
Debug mode (client): false
Fds: 22
Goroutines: 67
LXC Version: 0.9.0
EventsListeners: 115
Kernel Version: 3.8.0-33-generic
------------
=end
def docker_info()
  cmd = 'docker info'
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        docker_info_stdout=stdout.read
        containers = docker_info_stdout.grep(/Containers/).to_s.split(':',2).last
        images = docker_info_stdout.grep(/Images/).to_s.split(':',2).last
        driver = docker_info_stdout.grep(/Driver/).to_s.split(':',2).last
        root_dir = docker_info_stdout.grep(/Root Dir/).to_s.split(':',2).last
        dirs = docker_info_stdout.grep(/Dirs/).to_s.split(':',2).last
      return "Containers:#{containers.to_i} Images:#{images.to_i} Driver:#{driver.to_s.delete!("\n"," ")} Root Dir:#{root_dir.to_s.delete!("\n")} Dirs:#{dirs.to_s.delete!("\n")}"
end
end

#Standard nagios checks
def nagios_check()
case docker_is_running
 when 0
   puts "OK - #{docker_info}"
   exit 0
 when 1
   puts "WARNING"
   exit 1
 when 2
   puts "CRITICAL"
   exit 2
 else
   puts "UNKNOWN"
   exit 3
end
end

#moved this case down since I wanted to leave the nagios checks on the bottom.
case ARGV[0]
when "check"
  logger.debug "Running check methods"
  nagios_check
else
  puts opt_parser
end
