#!/usr/bin/env ruby

require './options'
require './app'

cli = CliHomebusApp.new({})

verb = ARGV.shift
unless verb
  puts 'usage: homebus-cli login <https://servername> <email-address>'
  exit -1
end

case verb
when 'login'
  cli.login
when 'logout'
  cli.logout
when 'show'
  cli.show
when 'reset'
  cli.reset
else
  puts "unknown action #{verb}"
end
