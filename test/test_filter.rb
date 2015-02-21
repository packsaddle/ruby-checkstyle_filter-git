require_relative 'helper'

class FilterTest < Test::Unit::TestCase
  sub_test_case '.same_file?' do
    test 'same' do
      assert do
        CheckstyleFilter::Git::Filter.same_file?('same', 'equal/../same')
      end
    end
    test 'not same' do
      assert do
        !CheckstyleFilter::Git::Filter.same_file?('same', 'not/same')
      end
    end
  end
end
