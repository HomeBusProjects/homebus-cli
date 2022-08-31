require 'thor'

require 'homebus-cli/auth'
require 'homebus-cli/project'
require 'dotenv/load'

class Homebus
  class CLI < Thor
    desc 'auth SUBCOMMAND ... ARGS', 'Manage Homebus authorizations'
    subcommand 'auth', Homebus::CLI::Auth

    register Homebus::CLI::Project, "new", "new PATHNAME", "Generate a new Ruby Homebus app named PATHNAME"

    desc 'xnew PATHNAME', 'Create new Homebus project named PATHNAME'
    option :classname, type: :string, aliases: :p
    def new_project(pathname)
      invoke Homebus::CLI::Project
    end

    def self.exit_on_failure?
      true
    end
  end
end
