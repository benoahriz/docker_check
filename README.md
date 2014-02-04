docker_check
============
```
Version 0.01
AUTHOR Benjamin Rizkowsky (ben@thebrainvault.org) 02/03/2014
https://github.com/benoahriz/docker_check

----------------------
Description
----------------------

ruby based nagios plugin to check the on the status of docker

Some references.
https://www.monitoring-plugins.org/doc/guidelines.html

http://www.kernel-panic.it/openbsd/nagios/nagios6.html

https://blog.centreon.com/good-practices-how-to-develop-monitoring-plugin-nagios/

----------------------
Installation
----------------------
git clone https://github.com/benoahriz/docker_check

----------------------
Command Line Arguments
----------------------
Example: ./docker_check.rb check [OPTIONS]

Commands
check

Options
    -v, --verbose                    verbose
    -V, --version                    version
    -h, --help                       help

----------------------
Requirements
----------------------
require 'open3'
require 'optparse'
require 'logger'

----------------------
Todo
----------------------
add proper timeouts to each method.
add better formatting of 'docker info' to comply with nagios plugin standards
revamp or get rid of the docker_info() method in favor of the api

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
```

