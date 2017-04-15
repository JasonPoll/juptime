# juptime
JUptime - Silly little ruby script for sending a screenshot and some basic system info to some hipchat destination.

# Usage
* clone it
* gem install hipchat
* configure it with your own personal hipchat API v2 token
* `ruby hipchat_uptime.rb`

You may want to cron it, something like:
```
*/15 * * * * cd /path/to/juptime && /path/to/bin/rvm $(cat .ruby-version)@$(cat .ruby-gemset) do ruby hipchat_uptime.rb > /your/log/path/juptime_cron.log
```
