module CheckstyleFilter
  module Git
    class Filter
      def self.filter(data, git_diff)
        parsed = ::Git::Diff::Parser.parse(git_diff)

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

        document.to_s
      end

      def self.file_element_file_in_git_diff?(file_name, patches)
        require 'pathname'
        diff_files = patches.map(&:file)
        diff_files
          .map { |file| Pathname.new(file).expand_path }
          .include?(Pathname.new(file_name).expand_path)
      end

      def self.file_element_error_line_no_in_modified?(file_name, patches, line_no)
        require 'pathname'
        diff_patches = patches
                       .select do |patch|
          Pathname.new(patch.file).expand_path \
              == Pathname.new(file_name).expand_path
        end
        return false if diff_patches.empty?

        modified_lines = Set.new
        diff_patches.map do |patch|
          patch.changed_lines.map do |line|
            modified_lines << line.number
          end
        end

        modified_lines.include?(line_no)
      end
    end
  end
end
