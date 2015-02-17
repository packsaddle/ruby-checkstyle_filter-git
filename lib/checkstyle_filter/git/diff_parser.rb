module CheckstyleFilter
  module Git
    class DiffParser
      def self.parse(contents)
        body = false
        file_name = ''
        patch = []
        lines = contents.lines
        line_count = lines.count
        parsed = []
        lines.each_with_index do |line, count|
          case line.chomp
          when /^diff/
            unless patch.empty?
              parsed << { file_name: file_name,
                          patch: ::Git::Diff::Parser::Patch.new(patch.join("\n")) }
              patch.clear
              file_name = ''
            end
            body = false
          when /^\-\-\-/
          when %r{^\+\+\+ b/(?<file_name>.*)}
            file_name = Regexp.last_match[:file_name]
            body = true
          when %r{^(?<body>[\ @\+\-\\].*)}
            patch << Regexp.last_match[:body] if body
            if !patch.empty? && body && line_count == count + 1
              parsed << { file_name: file_name,
                          patch: ::Git::Diff::Parser::Patch.new(patch.join("\n")) }
              patch.clear
              file_name = ''
            end
          end
        end
        parsed
      end
    end
  end
end
