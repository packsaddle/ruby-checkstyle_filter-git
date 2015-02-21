require 'rexml/document'
require 'pathname'

module CheckstyleFilter
  module Git
    class Filter
      def self.filter(data, git_diff)
        patches = ::Git::Diff::Parser.parse(git_diff)

        document = REXML::Document.new data
        document.elements.each('/checkstyle/file') do |file_element|
          file_name = file_element.attribute('name').value
          next unless file_element_file_in_git_diff?(file_name, patches)
          file_element.elements.each('error') do |error_element|
            line = error_element.attribute('line') && error_element.attribute('line').value.to_i
            if file_element_error_line_no_in_modified?(file_name, patches, line)
              error_element.remove
            end
          end
        end

        document.to_s
      end

      def self.file_element_file_in_git_diff?(file_name, patches)
        patches
          .map(&:file)
          .map { |file| Pathname.new(file).expand_path }
          .include?(Pathname.new(file_name).expand_path)
      end

      def self.file_element_error_line_no_in_modified?(file_name, patches, line_no)
        diff_patches = patches
                       .select { |patch| same_file?(patch.file, file_name) }
        return false if diff_patches.empty?

        modified_lines = Set.new
        diff_patches.map do |patch|
          patch.changed_lines.map do |line|
            modified_lines << line.number
          end
        end

        modified_lines.include?(line_no)
      end

      def self.same_file?(one, other)
        Pathname.new(one).expand_path == Pathname.new(other).expand_path
      end
    end
  end
end
