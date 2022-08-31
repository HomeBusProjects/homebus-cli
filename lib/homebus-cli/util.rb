require_relative 'version'

class Homebus
  class CLI
    class Util
      def self.gem_libdir
        t = [ "#{File.dirname(File.expand_path($0))}/../lib/homebus-cli/version.rb",
              "#{Gem.dir}/gems/homebus-cli-#{HomebusCLI::VERSION}/lib/homebus-cli/version.rb" ]

        t.each { |i| return i if File.readable?(i) }

        raise "both paths are invalid: #{t}"
      end
    end
  end
end
