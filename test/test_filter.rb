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
        patches = ::Git::Diff::Parser::Patches[
          ::Git::Diff::Parser::Patch.new('', file: 'path/to/this_one'),
          ::Git::Diff::Parser::Patch.new('', file: 'dammy_one')
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
    end
  end
end
