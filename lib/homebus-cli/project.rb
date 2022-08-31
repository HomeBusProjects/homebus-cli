require 'thor'

require 'homebus-cli/util'

class Homebus::CLI::Project < Thor::Group
  include Thor::Actions

  argument :pathname, required: true, type: :string
  argument :classname, required: false, type: :string

  class_option :'ruby-version', default: `/usr/bin/env ruby -e 'puts RUBY_VERSION'`
  class_option :username, default: `git config --get user.name`.chomp
  class_option :emailaddress, default: `git config --get user.email`.chomp
  class_option :mit, default: false, type: :boolean
  class_option :git, default: false, type: :boolean
  
  def self.source_root
    File.dirname(__FILE__) + '/templates'
  end

  def init
    puts "classname... #{classname}"
    unless classname
      puts 'setting classname'
      puts Homebus::CLI::Project._make_classname(pathname)
      self.classname = Homebus::CLI::Project._make_classname(pathname)
    end
  end

  def create_directory
    empty_directory(pathname)
  end

  def create_subdirectories
    subdirectories = %w[bin exe lib]
    subdirectories.push "lib/#{pathname}"
    subdirectories.each do |dir|
      empty_directory("#{pathname}/#{dir}")
    end
  end

  def top_level
    top_files = %w/Gemfile README.md .gitignore .ruby-version/
    top_files.each do |f|
      template("#{f}.tt", "#{pathname}/#{f}")
    end

    template("%pathname%.gemspec", "#{pathname}/#{pathname}.gemspec")
  end

  def lib_files
    lib_files = %w/app.rb options.rb version.rb/
    lib_files.each do |f|
      template("lib/#{f}.tt", "#{pathname}/lib/#{pathname}/#{f}")
    end
  end

  def license
    if options[:mit]
      copy_file 'MIT-LICENSE', "#{pathname}/MIT-LICENSE"
    end
  end

  def git
    if options[:git]
      Dir.chdir(pathname)
      `git init`
      `git add .`
    end
  end

private
  def self._make_classname(pathname)
    classname = ''

    pathname.split(/\-+/).each do |str|
      classname += str.capitalize
    end

    return classname
  end
end

