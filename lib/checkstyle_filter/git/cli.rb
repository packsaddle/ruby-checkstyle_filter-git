require 'thor'

module CheckstyleFilter
  module Git
    class CLI < Thor
      require 'checkstyle_filter/git'

      def self.exit_on_failure?
        true
      end

      desc 'diff', 'Filter using `git diff`'
      option :data
      def diff(_commit_ish = 'origin/master')
        data = \
          if options[:data]
            options[:data]
          elsif !$stdin.tty?
            ARGV.clear
            ARGF.read
          end

        abort if !data || data.empty?
        puts data
      end

      desc 'version', 'Show the CheckstyleFilter/Git version'
      map %w(-v --version) => :version

      def version
        puts "CheckstyleFilter/Git version #{::CheckstyleFilter::Git::VERSION}"
      end
    end
  end
end
