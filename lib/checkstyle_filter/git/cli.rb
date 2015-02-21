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
        parsed = ::Git::Diff::Parser.parse(git_diff)

        # TODO: split to class
        require 'rexml/document'
        document = REXML::Document.new data
        document.elements.each('/checkstyle/file') do |file_element|
          file_name = file_element.attribute('name').value
          next unless file_element_file_in_git_diff?(file_name, parsed)
          file_element.elements.each('error') do |error_element|
            line = error_element.attribute('line') && error_element.attribute('line').value.to_i
            if file_element_error_line_no_in_modified?(file_name, parsed, line)
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
        def file_element_file_in_git_diff?(file_name, patches)
          require 'pathname'
          diff_files = patches.map(&:file)
          diff_files
            .map { |file| Pathname.new(file).expand_path }
            .include?(Pathname.new(file_name).expand_path)
        end

        def file_element_error_line_no_in_modified?(file_name, parsed_git_diff, line_no)
          require 'pathname'
          diff_pairs = parsed_git_diff
                       .select do |diff|
            Pathname.new(diff[:file_name]).expand_path == Pathname.new(file_name).expand_path
          end
          return false if diff_pairs.empty?
          modified_lines = Set.new
          diff_pairs.map do |diff_pair|
            diff_pair[:patch].changed_lines.map do |line|
              modified_lines << line.number
            end
          end
          modified_lines.include?(line_no)
        end
      end
    end
  end
end
