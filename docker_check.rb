#!/usr/bin/ruby
#first check to make sure docker exists
#xxdocker_exist true or false
#pid file location
pidfile="/var/run/docker.pid"

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

puts command?('docker')
puts which('docker')
if command?('docker')
  puts "Docker exists. Hurray!"
    if File.exists?(pidfile)
      dockerpid = File.read(pidfile).to_i
      puts dockerpid
        if Process::kill 0, dockerpid
           puts "process is running"
        else
          puts "I can't send that PID a signal"
        end
      else
      puts "I couldnt find a PID file."
    end
else
  puts "Docker wasnt found. Sorry."
end
def docker_info()


end
