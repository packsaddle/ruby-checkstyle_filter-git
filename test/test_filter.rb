require_relative 'helper'

module CheckstyleFilter
  module Git
    class FilterTest < Test::Unit::TestCase
      sub_test_case '.filter' do
        diff = File.read('./test/support/fixtures/git_diff_test.txt')
        before_filter = File.read('./test/support/fixtures/checkstyle_before_filter.xml')
        after_filter = File.read('./test/support/fixtures/checkstyle_after_filter.xml')
        test 'filtered' do
          assert do
            parse(Filter.filter(before_filter, diff)) == parse(after_filter)
          end
        end
      end

      def parse(xml)
        ::Nori
          .new(parser: :rexml)
          .parse(xml)
      end
    end
  end
end
