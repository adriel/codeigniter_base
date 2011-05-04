Why?
===============
I wanted an easy way to install the latest and greatest web server via source without needing to manually go though all the compiling steps.

Requirements
===============
* Debian based system (Only been tested on a vanilla install of Debian 6.0.1a)

What do the scripts do?
===============
**ci\_install\_source:** Coming soon

This will install `nginx/lighttpd`, `php5`, `php-apc`, `mongodb` by compiling them from their sources.


**ci\_install\_apt:** Currently only lightTPD

Incase the source method is broken for what ever reason use this.

This will install `nginx/lighttpd`, `php5`, `php-apc`, `mongodb` using the apt package manager (apt-get).

*update with exact versions

Notes
===============
* MongoDB still needs to be added to both scripts.

Change log
===============
Look in the comment history...