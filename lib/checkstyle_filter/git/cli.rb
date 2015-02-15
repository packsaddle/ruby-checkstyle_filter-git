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

        # TODO: split to class
        require 'rexml/document'
        document = REXML::Document.new data
        document.elements.each('/checkstyle/file') do |file_element|
          file_element.elements.each('error') do |error_element|
            if true # file_element error line_no is in git diff
              error_element.remove
            end
          end
        end

        puts document.to_s
      end

      desc 'version', 'Show the CheckstyleFilter/Git version'
      map %w(-v --version) => :version

      def version
        puts "CheckstyleFilter/Git version #{::CheckstyleFilter::Git::VERSION}"
      end
    end
  end
end
