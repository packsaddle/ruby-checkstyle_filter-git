require_relative 'helper'

module CheckstyleFilter
  module Git
    class FilterTest < Test::Unit::TestCase
      sub_test_case '.same_file?' do
        test 'same' do
          assert do
            Filter.same_file?('same', 'equal/../same')
          end
        end
        test 'not same' do
          assert do
            !Filter.same_file?('same', 'not/same')
          end
        end
      end

      sub_test_case '.file_element_file_in_git_diff?' do
        patches = ::GitDiffParser::Patches[
          ::GitDiffParser::Patch.new('', file: 'path/to/this_one'),
          ::GitDiffParser::Patch.new('', file: 'dammy_one')
        ]
        test 'included' do
          file = 'path/to/this_one'
          assert do
            Filter.file_in_patches?(file, patches)
          end
        end
        test 'not included' do
          file = 'not_included'
          assert do
            !Filter.file_in_patches?(file, patches)
          end
        end
      end

      sub_test_case '.file_element_error_line_no_in_patches?' do
        diff = File.read('./test/support/fixtures/git_diff_test.txt')
        patches = ::GitDiffParser.parse(diff)
        test 'included' do
          file = 'example/invalid.rb'
          line_no = 3 # error and diff included
          assert do
            Filter.file_element_error_line_no_in_patches?(file, patches, line_no)
          end
        end
        test 'not included' do
          file = 'lib/checkstyle_filter/git/cli.rb'
          line_no = 65 # error but not diff included
          assert do
            !Filter.file_element_error_line_no_in_patches?(file, patches, line_no)
          end
        end
      end

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
