require 'thor'
require 'dotenv/load'
require 'homebus/config'

class AuthBase < Thor
  def self.banner(command, namespace = nil, subcommand = false)
    "#{basename} #{subcommand_prefix} #{command.usage}"
  end

  def self.subcommand_prefix
    self.name.gsub(%r{.*::}, '').gsub(%r{^[A-Z]}) { |match| match[0].downcase }.gsub(%r{[A-Z]}) { |match| "-#{match[0].downcase}" }
  end
end

class Homebus
  class CLI < Thor
    class Auth < AuthBase
      include Thor::Actions

      desc 'login SERVER_URL EMAIL_ADDRESS', 'Authorize client with Homebus server'
      def login(server_url, email_address)
        _init

        password = ask 'Password: ', echo: false
        puts password

        @homebus = Homebus.new(homebus_server: server_url)

        token = @homebus.login(email_address, password)

        unless token
          abort "Login failed"
        end

        @config.login_config[:homebus_instances].push({ provision_server: server_url, email_address: email_address, token: token, index: @config.login_config[:next_index] })
        @config.login_config[:next_index] += 1
        @config.save_login
      end

      desc 'logout [INDEX]', 'Deauthorize client at index INDEX (or default client if no INDEX is specified)'
      def logout(index = "-1")
        _init

        index = index.to_i
        if index == -1
          index = @config.login_config[:default_login]
        end

        login = @config.login_config[:homebus_instances][index]
        puts login
        if !login
          puts "No login info at index #{index}"
        end

        @homebus = Homebus.new(homebus_server: login[:provision_server])

        unless @homebus.logout(login[:token])
          abort "Logout failed"
        end

        @config.remove_default_login
        @config.save_login
      end

      desc 'default INDEX', 'Set default Homebus account to the account numbered by INDEX'
      def default(index)
        _init

        index = index.to_i

        if @config.login_config[:default_login] == index
          puts "Default account was already set to index #{index}"
          exit
        end

        if @config.login_config[:homebus_instances][index]
          @config.login_config[:default_login] = index
          @config.save

          puts "Default account set to #{index}"
          exit
        end

        puts "No account available at index #{index}"
        puts "Please use one of these available accounts"

        list
      end

      desc 'list', 'List available logins'
      def list
        _init
        puts '>>>> config', @config

        @config.login_config[:homebus_instances].each do |instance|
          if instance[:index] == @config.login_config[:default_login]
            putc '*'
          else
            putc ' '
          end

          puts "#{instance[:index]} - #{instance[:provision_server]} - #{instance[:email_address]}"
        end
      end

protected
      def _init
        @config = Homebus::Config.new
        @config.load
      end
    end
  end
end
