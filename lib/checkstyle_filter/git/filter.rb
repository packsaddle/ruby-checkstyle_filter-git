require 'rexml/document'
require 'pathname'

module CheckstyleFilter
  module Git
    class Filter
      def self.filter(data, git_diff)
        patches = ::GitDiffParser.parse(git_diff)

        document = REXML::Document.new data
        document.elements.each('/checkstyle/file') do |file_element|
          file_name = file_element.attribute('name') && file_element.attribute('name').value
          file = file_relative_path_string(file_name)
          patch = patches.find_patch_by_file(file)
          if patch
            file_element.elements.each('error') do |error_element|
              line = error_element.attribute('line') && error_element.attribute('line').value.to_i
              unless patch.changed_line_numbers.include?(line)
                error_element.remove
              end
            end
          else
            file_element.elements.each('error') do |error_element|
              error_element.remove
            end
          end
        end

        document.to_s
      end

      def self.file_relative_path_string(file_name)
        if Pathname.new(file_name).absolute?
          Pathname.new(file_name).relative_path_from(Pathname.new(Dir.pwd)).to_s
        else
          Pathname.new(file_name).relative_path_from(Pathname.new('.')).to_s
        end
      end
    end
  end
end
