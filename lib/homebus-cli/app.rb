require 'json'
require 'uri'
require 'net/http'

require 'homebus'

class HomebusCLI::App < Homebus::App
  def initialize(options = {})
    @options = Hash.new

    @name = "homebus-cli-#{`uname`.chomp}-#{`whoami`.chomp}"

    @config = Homebus::Config.new
    @config.load
  end

  # homebus-cli.rb login email server
  # prompts for password
  def login
    server = ARGV[0]
    email_address = ARGV[1]

    if ARGV.length < 2 || !server.match(/http[s]?:\/\//i) || !email_address.include?('@')
      puts 'usage: login server(https://homebus.org) email-address'
      exit
    end

    puts 'Password: ' 
    password = $stdin.gets.chomp

    @homebus = Homebus.new(homebus_server: ARGV[0])

    token = @homebus.login(email_address, password)

    unless token
      abort "Login failed"
    end

    @config.login_config[:homebus_instances].push({ provision_server: server, email_address: email_address, token: token, index: @config.login_config[:next_index] })
    @config.login_config[:next_index] += 1
    @config.save_login
  end

  def logout
    login_config = @config.default_login

    @homebus = Homebus.new(homebus_server: login_config[:provision_server])

    unless @homebus.logout(login_config[:token])
      abort "Logout failed"
    end

    @config.remove_default_login
    @config.save_login
  end
end
