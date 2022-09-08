require 'thor'

require 'homebus-cli/util'

class Homebus::CLI::Project < Thor::Group
  include Thor::Actions

  argument :pathname, required: true, type: :string
  argument :classname, required: false, type: :string

  class_option :'ruby-version', default: `/usr/bin/env ruby -e 'puts RUBY_VERSION'`
  class_option :name, default: `git config --get user.name`.chomp
  class_option :github_username, default: `git config --get github.user`.chomp
  class_option :emailaddress, default: `git config --get user.email`.chomp
  class_option :mit, default: true, type: :boolean
  class_option :git, default: true, type: :boolean
  class_option :spec, default: true, type: :boolean
  class_option :conduct, type: :string

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
    top_files = %w/Gemfile Rakefile README.md .gitignore .ruby-version/
    top_files.each do |f|
      template("#{f}.tt", "#{pathname}/#{f}")
    end

    template("%pathname%.gemspec", "#{pathname}/#{pathname}.gemspec")

    if options[:conduct]
      template("CODE-OF-CONDUCT.md.tt", "#{pathname}/CODE-OF-CONDUCT.md")
    end
  end

  def lib_files
    lib_files = %w/app.rb options.rb version.rb/
    lib_files.each do |f|
      template("lib/#{f}.tt", "#{pathname}/lib/#{pathname}/#{f}")
    end
  end

  def exe_files
    dest_filename = "#{pathname}/exe/#{pathname}"
    template("exe/%pathname%.tt", "#{pathname}/exe/#{pathname}")
    chmod dest_filename, 0755
  end

  def bin_files
    dest_filename = "#{pathname}/bin/#{pathname}"
    template("bin/%pathname%.tt", dest_filename)
    chmod dest_filename, 0755
  end

  def spec_files
    if options[:spec]
      empty_directory "#{pathname}/spec"
      empty_directory "#{pathname}/.github"
      empty_directory "#{pathname}/.github/workflows"

      template "spec/%name%_spec.rb.tt", "#{pathname}/spec/#{pathname}_spec.rb"
      template "spec/spec_helper.rb.tt", "#{pathname}/spec/spec_helper.rb"
      template ".github/workflows/rspec.yml.tt", "#{pathname}/.github/workflows/rspec.yml"
      template ".rspec.tt", "#{pathname}/.rspec"

      old_dir = Dir.pwd
      Dir.chdir(pathname)
      `bundle lock --add-platform x86_64-linux`
      Dir.chdir(old_dir)
    end
  end

  def systemd_files
    template("systemd/%pathname%.service.tt", "#{pathname}/systemd/#{pathname}.service")
  end

  def license
    if options[:mit]
      copy_file 'MIT-LICENSE', "#{pathname}/MIT-LICENSE"
    end
  end

  def git
    if options[:git]
      old_dir = Dir.pwd
      Dir.chdir(pathname)
      `git init`
      `git add .`
      Dir.chdir(old_dir)
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

