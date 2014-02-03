#!/usr/bin/ruby
SCRIPT_VERSION="Version 0.01"
AUTHOR="Benjamin Rizkowsky (ben@thebrainvault.org) 2014"
URL="https://github.com/benoahriz/docker_check"
################################################################################
# Nagios plugin to monitor the status of docker on the local machine             
# Author: Benjamin Rizkowsky (http://thebrainvault.org/)                     
################################################################################
require 'open3'
require 'optparse'
require 'logger'
logger = Logger.new(STDERR)
logger = Logger.new(STDOUT)
logger.progname = 'docker_check'
logger.level = Logger::WARN

options = {}
opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: docker_check.rb [OPTIONS]"
  opt.separator  ""
  opt.separator  "Commands"
  opt.separator  "check"
  opt.separator  ""
  opt.separator  "Options"
  opt.on("-t","--timeout","timeout") do
    puts "timout"
  end
  opt.on("-c","--critical","critical") do
    puts "critical threshold"
  end
  opt.on("-H","--hostname","hostname") do
    puts "hostname option"
  end
  opt.on("-v","--verbose","verbose") do
    logger.level = Logger::DEBUG
    puts "Debug is now on!"
  end
  opt.on("-V","--version","version") do
    puts SCRIPT_VERSION
    puts AUTHOR
  end
  opt.on("-h","--help","help") do
    puts opt_parser
  end
end
opt_parser.parse!

case ARGV[0]
when "check"
  logger.debug "Running check methods"
else
  puts opt_parser
end
#Constants
#pid file location
pidfile="/var/run/docker.pid"
#Helper Functions
#which method borrowed from https://github.com/github/hub/blob/master/lib/hub/context.rb
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
#command method borrowed from https://github.com/github/hub/blob/master/lib/hub/context.rb
# depends on the above which method 
def command?(name)
  !which(name).nil?
end

logger.debug "The docker command reports it exists and value is = #{command?('docker')}"
logger.debug "The which method found the path #{which('docker')}"
if command?('docker')
  logger.debug "Docker command exists in the path. Hurray!"
    if File.exists?(pidfile)
      dockerpid = File.read(pidfile).to_i
      logger.debug "Sweet I found the docker process #{dockerpid}"
        if Process::kill 0, dockerpid
           logger.debug "The docker process is responding to kill 0."
        else 
         logger.warn  "I can't send that PID a signal"
        end
      else
      logger.warn "I couldnt find a PID file."
    end
else
  logger.warn "Docker wasnt found. Sorry."
end

def docker_info()
cmd = 'docker info'
Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
  docker_info_stdout=stdout.read
  docker_info_stderr=stderr.read
  containers = docker_info_stdout.grep(/Containers/).to_s.split(':',2).last
  return containers
end
end

puts docker_info

docker_is_running=`ps aux |grep '/usr/bin/[d]ocker'`
 case docker_is_running.chomp <=> '1' 
 when 1
   puts "OK - #{docker_is_running.chomp!} "
   exit 0
 #when 0
 #  puts "WARNING - #{docker_is_running.chomp!} "
 #  exit 1
 when 0 
   puts "CRITICAL - #{docker_is_running.chomp!}"
   exit 2
 else
   puts "UNKNOWN - #{docker_is_running.chomp!} "
   exit 3
end

