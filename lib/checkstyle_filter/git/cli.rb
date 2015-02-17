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
        parsed = ::CheckstyleFilter::Git::DiffParser.parse(git_diff)

        # TODO: split to class
        require 'rexml/document'
        document = REXML::Document.new data
        document.elements.each('/checkstyle/file') do |file_element|
          file_name = file_element.attribute('name').value
          file_element.elements.each('error') do |error_element|
            next unless file_element_file_in_git_diff?(file_name, parsed)
            if true # file_element_error_line_no is in git diff
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

      no_commands do
        def file_element_file_in_git_diff?(file_name, parsed_git_diff)
          require 'pathname'
          diff_files = parsed_git_diff.map{|one| one[:file_name]}
          diff_files
            .map{|file| Pathname.new(file).expand_path}
            .include?(Pathname.new(file_name).expand_path)
        end
      end
    end
  end
end
