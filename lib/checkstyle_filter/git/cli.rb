require 'thor'

module CheckstyleFilter
  module Git
    class CLI < Thor
      require 'checkstyle_filter/git'

      desc 'version', 'Show the CheckstyleFilter/Git version'
      map %w(-v --version) => :version

      def version
        puts "CheckstyleFilter/Git version #{::CheckstyleFilter::Git::VERSION}"
      end
    end
  end
end
