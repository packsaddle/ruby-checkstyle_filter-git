require 'thor'
require 'open3'

module CheckstyleFilter
  module Git
    class CLI < Thor
      def self.exit_on_failure?
        true
      end

      desc 'diff', 'Filter using `git diff`'
      option :data
      option :file
      def diff(commit_ish = nil)
        data = \
          if options[:data]
            options[:data]
          elsif options[:file]
            File.read(options[:file])
          elsif !$stdin.tty?
            ARGV.clear
            ARGF.read
          end

        abort if !data || data.empty?

        command = ['git', 'diff', '--no-color', commit_ish].compact
        git_diff, _, _ = Open3.capture3(*command)
        puts ::CheckstyleFilter::Git::Filter.filter(data, git_diff)
      end

      desc 'exec', 'Exec command `"git diff --no-color origin/master | iconv -f EUCJP -t UTF8"`'
      def exec(command)
        data = if !$stdin.tty?
                 ARGV.clear
                 ARGF.read
               end

        abort if !data || data.empty?

        git_diff, _, _ = Open3.capture3(command)
        puts ::CheckstyleFilter::Git::Filter.filter(data, git_diff)
      end

      desc 'version', 'Show the CheckstyleFilter/Git version'
      map %w(-v --version) => :version

      def version
        puts "CheckstyleFilter/Git version #{::CheckstyleFilter::Git::VERSION}"
      end
    end
  end
end
