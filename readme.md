Why?
===============
**webserver_source:**
I wanted an easy way to install the latest and greatest web server via source without needing to manually go though all the compiling steps.

**webserver_apt:**
Incase the source method is broken.

ci_install_apt.sh 
===============
This will install `nginx/lighttpd`, `php5`, `php-apc`, `mongodb` using the apt package manager (apt-get).

ci_install_source.sh 
===============
This will install `nginx/lighttpd`, `php5`, `php-apc`, `mongodb` via source

*update with exact versions

History
===============
**v0.1**
- Initial release