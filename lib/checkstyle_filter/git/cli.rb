require 'thor'

module CheckstyleFilter
  module Git
    class CLI < Thor
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
          _file_name = file_element.attribute('name').value
          file_element.elements.each('error') do |error_element|
            if true # file_element error line_no is in git diff
              _line = error_element.attribute('line') && error_element.attribute('line').value.to_i
              _column = error_element.attribute('column') && error_element.attribute('column').value.to_i
              _severity = error_element.attribute('severity') && error_element.attribute('severity').value
              _message = error_element.attribute('message') && error_element.attribute('message').value
              _source = error_element.attribute('source') && error_element.attribute('source').value
              _invalid = error_element.attribute('invalid') && error_element.attribute('invalid').value # invalid param
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
